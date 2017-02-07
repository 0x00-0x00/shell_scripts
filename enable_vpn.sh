#!/bin/bash
uid=$(id -u)
remote="watchersnet.ddns.net"
user=shemhazai

function check_root 
{
    if [ "$1" != "0" ]; then
        echo "You do not have sufficient privileges to run this script."
        exit
    fi

}

function enable_vpn
{
    echo -n "[+] Establishing connectivity with vpn: "
    sshuttle --dns -r ${user}@${remote} 0/0
    if [[ $? -eq ]]; then
        echo " DONE."
        exit
    else
        echo " FAIL."
        exit
    fi

}

check_root $uid
enable_vpn
