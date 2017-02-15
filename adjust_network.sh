#!/bin/bash

# Script to generate route entries into Routing table
# for linux system's.
# It is a common command that I use in my own network.

uid=$(id -u)

if [[ $uid != 0 ]]; then
    echo "[!] Not enough privileges to run this script.";
    exit;
fi

function add_network
{
    echo -n "Adding route entry for network $1: "
    route add -net $1 netmask 255.255.255.0 $2

    if [[ $? == 0 ]]; then
        echo "OK";
    else
        echo "FAIL";
    fi
}

function check_interface
{
    iface_n=$(ifconfig | grep mtu | grep $1 | wc -l)
    if [[ $iface_n == 0 ]]; then
        exit;
    else
        return 0
    fi
}

if [[ $1 == "" ]] || [[ $2 == "" ]]; then
    echo "Usage: $0 <Interface> <Network>"
    echo "Example: $0 wlan0 192.168.0.0"
    exit;
fi

check_interface $1
add_network $2 $1
