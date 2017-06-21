#!/bin/bash

if [[ $(id -u) != 0 ]]; then
	echo "[!] somente root faz isso ai filhao.";
	exit 1;
fi

# ---=========================================--- #
# 		CONFIGURACAO DE DNS 
# ---=========================================--- #
HOST_ZONE_NAME="watchers"
PRIMARY_ZONE="watchers.com.br"  # zona primaria

NS=("ip1" "ip2"); # servidores NS
MX=("ip3"); # servidores MX
POP3=("ip4"); # servidores pop3
WWW=("ip5");  # www.dominio -> ip
CUSTOM=("custom1:ip_custom");
CNAMES=("nick:cname");

# ---=========================================--- #
#		CONFIGURACAO DO APACHE
# ---=========================================--- #
SITE_DIR="/var/websites"
SITES=("watchers");
RESTRICTED_CONTENT=("data:data:pass.pwd:user:pass"); #site_folder:apache_folder:htaccess_filename:user:password
SERVER_ADMIN="andre\.marques@fatec\.sp\.gov\.br";

chkerr()
{
	if [[ $? != 0 ]]; then
		echo "Erro fatal.";
		exit 1;
	fi
}

echo "[+] Instalando bind9 e apache2 ...";
apt-get install bind9 apache2 apache2-utils -y > /dev/null 2>&1
chkerr;

echo "[+] BIND9: Checando e configurando bind9 ...";
if [[ ! -d /etc/bind/domains/${HOST_ZONE_NAME} ]]; then
	 mkdir -p /etc/bind/domains/${HOST_ZONE_NAME}
	 chown root:bind /etc/bind/domains/${HOST_ZONE_NAME}
fi

if [[ ! -f /etc/bind/named.conf.local ]]; then
	echo "[!] Sem named conf?";
	exit 1;
else
	if [[ ! -f /etc/bind/named.conf.local.backup ]]; then
		echo "[+] Fazendo backup de named.conf.local.backup ...";
		cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup;
		chkerr;
	fi
fi

echo "[+] BIND9: Criando zona primaria ..."
CONFIG_FILE="/etc/bind/domains/${HOST_ZONE_NAME}/db.${PRIMARY_ZONE}";
echo -e "zone \"${PRIMARY_ZONE}\" IN {\n\ttype master;\n\tfile \"$CONFIG_FILE\";\n\t};" >> /etc/bind/named.conf.local;

echo "[+] BIND9: Criando configuracao de dominio ..."
if [[ -f $CONFIG_FILE ]]; then
	rm $CONFIG_FILE;
fi

echo "\$TTL 345600
@	IN SOA ns1.${PRIMARY_ZONE}. hostmaster.${PRIMARY_ZONE} (
		$(date +%Y%m%d)01; serial number
		28800; refresh seconds
		7200; retry seconds
		604800; expire seconds
		86400 ); negative cache TTL seconds

	NS ns1.${PRIMARY_ZONE}.
	NS ns2.${PRIMARY_ZONE}." >> $CONFIG_FILE;

# Generate all configuration for mx servers
i=1;
for mx_server in ${MX[@]}; do
	echo -e "\tIN MX ${i}0	smtp${i}.${PRIMARY_ZONE}." >> $CONFIG_FILE;
	i=$((i+1));
done

echo "\n${PRIMARY_ZONE}.	A	${NS[0]}" >> $CONFIG_FILE;

i=1;
for ns_server in ${NS[@]}; do
	echo -e "ns${i}\tA\t${ns_server}" >> $CONFIG_FILE;
	i=$((i+1));
done

for webserver in ${WWW[@]}; do
	echo -e "www	A	${webserver}" >> $CONFIG_FILE;
done

for pop3_sv in ${POP3[@]}; do
	echo -e "pop3	A	${pop3_sv}" >> $CONFIG_FILE;
done

for each_custom in ${CUSTOM[@]}; do
	first=$(echo $each_custom | cut -f1 -d:);
	second=$(echo $each_custom | cut -f2 -d:);
	echo -e "$first\tA\t$second" >> $CONFIG_FILE;
done

for each_cname in ${CNAMES[@]}; do
	first=$(echo $each_cname | cut -f1 -d:);
	second=$(echo $each_cname | cut -f1 -d:);
	echo -e "$first\tCNAME\t$second" >> $CONFIG_FILE;
done


echo "[+] BIND9: Configuracao concluida em $CONFIG_FILE";

echo "[+] BIND9: Reiniciando bind9 para efetuar as alteracoes ...";
systemctl restart bind9


if [[ ${#SITES[@]} == 0 ]]; then
	echo "[!] Sem sites de apache para configurar.";
	exit 0;
else
	echo "[*] APACHE2: Tenho ${#SITES[@]} site(s) para configurar ...";
	echo "[!] APACHE2: Desabilitando site padrao ...";
	a2dissite 000-default > /dev/null 2>&1
	if [[ -f /var/www/html/index.html ]]; then
		rm /var/www/html/index.html
	fi
fi

if [[ ! -d /etc/apache2 ]]; then
	echo "[!] Sem apache?";
	exit 1;
fi

echo -e "[+] APACHE2: Criando pastas de site ...";
if [[ ! -d $SITE_DIR ]]; then
	mkdir -p $SITE_DIR;
	chown www-data.www-data $SITE_DIR/ -R
	ESCAPED_SITE_DIR=$(echo $SITE_DIR | sed 's/\//\\\//g');
	sed -i "s/\/var\/www/$ESCAPED_SITE_DIR/g" /etc/apache2/apache2.conf
	i=0;

	echo "[+] APACHE2: Habilitando modulo de SSL do apache2 ...";
	a2enmod ssl > /dev/null 2>&1
	if [[ ! -d /etc/apache2/ssl ]]; then
		mkdir -p /etc/apache2/ssl
		chown root.root /etc/apache2/ssl
		chmod 700 /etc/apache2/ssl
	fi

	for SITE in ${SITES[@]}; do
		mkdir $SITE_DIR/$SITE;
		chown -R www-data.www-data $SITE_DIR/$SITE
		echo -e "[+] APACHE2: Configurando site $SITE ...";
		CONF_FILE="/etc/apache2/sites-available/$SITE.conf";
		DOCUMENT_ROOT=$SITE_DIR/$SITE

		echo -e "[+] APACHE2: Criando areas de acesso restrito ...";
		site_folder=$(echo ${RESTRICTED_CONTENT[0]} | cut -f1 -d:);
		apache_folder=$(echo ${RESTRICTED_CONTENT[0]} | cut -f2 -d:);
		htfile=$(echo ${RESTRICTED_CONTENT[0]} | cut -f3 -d:);
		ctn_user=$(echo ${RESTRICTED_CONTENT[0]} | cut -f4 -d:);
		ctn_pass=$(echo ${RESTRICTED_CONTENT[0]} | cut -f5 -d:);
		mkdir $SITE_DIR/$SITE/$site_folder
		mkdir /etc/apache2/$apache_folder
		echo "$ctn_pass" | htpasswd -i -c /etc/apache2/$apache_folder/$htfile $ctn_user > /dev/null 2>&1
		echo "[+] APACHE2: Area restrita '/$site_folder' criada com o usuario '$ctn_user' e senha '$ctn_pass'";

		echo "<VirtualHost *:80>
	ServerAdmin ${SERVER_ADMIN}
	DocumentRoot ${DOCUMENT_ROOT}
	Redirect / https://127.0.0.1
</VirtualHost>

<VirtualHost *:443>
	ServerAdmin ${SERVER_ADMIN}
	DocumentRoot ${DOCUMENT_ROOT}
	ServerName www.${PRIMARY_ZONE}
	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/acces.log combined
	SSLEngine on
	SSLCertificateFile /etc/apache2/ssl/${SITE}/${SITE}.crt
	SSLCertificateKeyFile /etc/apache2/ssl/${SITE}/${SITE}.key

	<Directory \"${SITE_DIR}/${SITE}/${site_folder}\">
		AuthType Basic
		AuthName \"Acesso Restrito\"
		AuthUserFile /etc/apache2/$apache_folder/$htfile
		Require valid-user
	</Directory>
</VirtualHost>" > $CONF_FILE;

		echo -e "[+] APACHE2: Criando default page ...";
		echo -e "Hello World" > $SITE_DIR/$SITE/index.html
		chown www-data.www-data $SITE_DIR/$SITE/index.html

		mkdir -p /etc/apache2/ssl/$SITE
		
		echo "[+] APACHE2: Gerando certificado SSL self-signed ...";
		openssl req -subj "/CN=${PRIMARY_ZONE}/O=${ZONE_HOST_NAME}/C=BR" -x509 -nodes -days $((365*3)) -newkey rsa:2048 -keyout /etc/apache2/ssl/$SITE/$SITE.key -out /etc/apache2/ssl/$SITE/$SITE.crt > /dev/null 2>&1
		chown root.root /etc/apache2/ssl/$SITE/$SITE.key
		chown root.root /etc/apache2/ssl/$SITE/$SITE.crt
		chmod 600 /etc/apache2/ssl/$SITE/$SITE.key
		chmod 600 /etc/apache2/ssl/$SITE/$SITE.crt

		echo "[+] APACHE2: Habilitando o modulo rewrite e redirecionando trafego HTTP para HTTPS";
		a2enmod rewrite > /dev/null 2>&1
		echo "RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]" > $SITE_DIR/$SITE/.htaccess
		chmod 600 $SITE_DIR/$SITE/.htaccess
		chown root.root $SITE_DIR/$SITE/.htaccess
		
		
		echo -e "[+] APACHE2: Habilitando o site '$SITE' ...";
		a2ensite "$SITE" > /dev/null 2>&1

	done
	echo "[+] APACHE2: Reiniciando apache2 ...";
	systemctl restart apache2
fi
