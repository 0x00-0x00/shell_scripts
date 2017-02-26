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

    #  Create first rule
    iptables -t nat -A POSTROUTING -o $iface01 -j MASQUERADE;
    if [[ $? != 0 ]]; then
        echo "FAIL";
        exit;
    fi

    #  Create second rule
    iptables -A FORWARD -i $iface01 -o $iface02 -m state --state RELATED,ESTABLISHED -j ACCEPT;
    if [[ $? != 0 ]]; then
        echo "FAIL";
        exit;
    fi

    #  Create third rule
    iptables -A FORWARD -i $iface02 -o $iface01 -j ACCEPT;
    if [[ $? != 0 ]]; then
        echo "FAIL";
        exit;
    else
        echo "OK";
        exit;
    fi
}

route_traffic
