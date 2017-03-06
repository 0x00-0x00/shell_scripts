#!/bin/bash
uid=$(id -u)

if [[ $1 == "" ]] || [[ $2 == "" ]]; then
    echo "Usage: $0 <INTERNET_INTERFACE> <VIRTUAL_INTERFACE>";
    exit;
fi

if [[ $uid != 0 ]]; then
    echo "[!] Only root can change iptables rules.";
    exit;
fi


iface01=$1;
iface02=$2;

function route_traffic
{
    echo -n "[*] Creating routing rules: "
    echo "1" > /proc/sys/net/ipv4/ip_forward
    #  Create first rule
    iptables -t nat -A POSTROUTING -o $iface01 -j MASQUERADE;
    if [[ $? != 0 ]]; then
        echo -e "\033[33mFAIL\033[0m";
        exit;
    fi

    #  Create second rule
    iptables -A FORWARD -i $iface01 -o $iface02 -m state --state RELATED,ESTABLISHED -j ACCEPT;
    if [[ $? != 0 ]]; then
        echo -e "\033[33mFAIL\033[0m";
        exit;
    fi

    #  Create third rule
    iptables -A FORWARD -i $iface02 -o $iface01 -j ACCEPT;
    if [[ $? != 0 ]]; then
        echo -e "\033[33mFAIL\033[0m";
        exit;
    else
        echo -e "\033[32mOK\033[0m";
        exit;
    fi
}

route_traffic
