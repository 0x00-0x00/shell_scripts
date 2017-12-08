#!/bin/bash

uid=$(id -u)
conf_template=conf/squid/squid.conf
conf_file=/usr/local/squid/etc/squid.conf
back_file=/usr/local/squid/etc/squid.conf.old
cert_folder=/usr/local/squid/ssl_cert
squid_link="http://www.squid-cache.org/Versions/v3/3.5/squid-3.5.24.tar.gz"
squid_file="squid-3.5.24.tar.gz"
squid_folder="squid-3.5.24"


function check_root
{
    if [[ $uid != 0 ]]; then
        echo "[!] Not enough privileges to run this script.";
        exit;
    fi
}


function resolv_permissions
{
    user_check=$(cat /etc/passwd | grep proxy | wc -l);
    if [[ $user_check -eq 0 ]]; then
        echo -n "[*] Creating user 'proxy': ";
        useradd -U proxy -s /bin/nologin;
        if [[ $? != 0 ]]; then
             echo "FAIL";
        else
             echo "OK";
        fi
     fi
     perm_folders=(/usr/local/squid/var /dev/shm /var/lib/ssl_db)
     for f in "${perm_folders[@]}";
     do
         echo -n "[*] Changing permission for folder '$f': ";
         chown -R proxy:proxy "$f";
         if [[ $? != 0 ]]; then
             echo "FAIL";
         else
             echo "OK";
         fi
     done

}


function enable_ssl_db
{
    echo -n "[*] Initializing SSL data-base: ";
    /usr/local/squid/libexec/ssl_crtd -c -s /var/lib/ssl_db
    if [[ $? != 0 ]]; then
        echo "FAIL";
    else
        echo "OK";
    fi
}


function install_certs
{
    if [[ ! -e $cert_folder ]]; then
        mkdir $cert_folder;
    fi;
    cd $cert_folder;
    if [[ ! -e "myCA.pem" ]]; then
        echo "[*] Creating CA certificate... ";
        openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout myCA.pem  -out myCA.pem
    fi
    cd -;
}


function check_squid
{
    echo -n "[*] Checking squid installation: "
    which squid3 -v > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "INSTALLED";
        return 0;
    else
        echo "NOT INSTALLED.";
        return 1;
    fi
}


function install_squid
{
    cd /tmp
    wget $squid_link;
    tar -xvf $squid_file;
    cd $squid_folder;
    ./configure --with-openssl --enable-ssl-crtd
    make
    make install
    ok=$?
    echo -n "[*] Installing squid3: "
    if [[ $ok == 0 ]]; then
        echo "OK";
	ln -s /usr/local/squid/sbin/squid /usr/local/bin/squid
    else
        echo "FAIL";
    fi
}


function backup_conf
{
    echo -n "[*] Checking for configuration file: "
    if [[ ! -e $conf_file ]]; then
        echo "DOES NOT EXISTS.";
        exit;
    else
        echo "EXISTS.";
    fi

    echo -n "[*] Backing-up configuration file: "
    cp $conf_file $back_file
    if [[ $? == 0 ]]; then
        echo "OK";
    else
        echo "FAIL";
        return -1;
    fi
    return 0;
}


function customize_config
{
    #  Check template exists.
    if [[ ! -e $conf_template ]]; then
        echo "[!] Configuration file template does not exists.";
        exit;
    fi

    local placeholder=XXX
    lines=()
    data=$(cat $conf_template | grep "$placeholder")
    while  read -r line;
    do
        lines+=("$line");
    done <<< "$data";

    #  Create temporary file
    tmp_file=$(mktemp)
    echo "[*] Using temporary file $tmp_file"

    #  Dump template data into temporary
    cat $conf_template > $tmp_file;

    echo "[*] Interactive configuration started."
    for l in "${lines[@]}";
    do
        parameter=$(echo $l | awk {'print $1'})
        description="$(cat $tmp_file | grep -B1 "$parameter" | head -n1)"
        echo $description;


        echo -n "[$parameter] value: "
        read tmp_value;

        f_line=$(echo "$tmp_value" | sed "s/\//\\\\\//g")
        replace_string="$(cat "$tmp_file" | grep "$parameter" | sed "s/$placeholder/$f_line/")"

        f_line=$(echo "$replace_string" | sed "s/\//\\\\\//g")

        fo_line=$(echo "$l" | sed "s/\//\\\\\//g")
        repl_data=$(sed "s/$fo_line/$f_line/" $tmp_file);

        echo "$repl_data" > $tmp_file;
        echo "[+] Parameter '$parameter' successfully set to '$tmp_value'.";
        echo "";
        sleep 1;
    done

    cat $tmp_file;
    return 0;
}

#  Check for necessary privileges
check_root

#  Check for squid installation
check_squid


#  If not installed, install it.
if [[ $? != 0 ]]; then
    install_squid;
fi


# Backup the configuration file
backup_conf

customize_config

install_certs

enable_ssl_db

resolv_permissions
