#!/bin/bash

uid=$(id -u)
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



