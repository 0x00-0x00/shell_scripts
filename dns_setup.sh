#!/bin/bash
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


