#!/bin/bash

uid=$(id -u)
conf_template=conf/squid/squid.conf
conf_file=/etc/squid3/squid.conf
back_file=/etc/squid3/squid.conf.old

function check_root
{
    if [[ $uid != 0 ]]; then
        echo "[!] Not enough privileges to run this script.";
        exit;
    fi
}

function check_squid
{
    echo -n "[*] Checking squid installation: "
    which squid3 -v > /dev/null 2>&1
    if [[ $? != 0 ]]; then
        echo "INSTALLED";
        return 0;
    else
        echo "NOT INSTALLED.";
        return 1;
    fi
}

function install_squid
{
    echo -n "[*] Installing squid3: "
    apt-get install squid3 -y > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "OK";
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
#check_root

#  Check for squid installation
#check_squid


#  If not installed, install it.
#if [[ $? != 0 ]]; then
#    install_squid;
#fi


# Backup the configuration file
#backup_conf

customize_config

