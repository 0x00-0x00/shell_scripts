#!/bin/bash

uid=$(id -u)
if [[ $uid != 0 ]]; then
    echo "[!] You do not have enough permissions to use this script.";
    exit;
fi

function add_interface
{
    outfile="/etc/network/interfaces";
    echo "" >> $outfile;
    echo "#Host-only interface" >> $outfile;
    echo "auto eth1" >> $outfile;
    echo "iface eth1 inet static" >> $outfile;
    echo "address 192.168.56.101" >> $outfile;
    echo "broadcast 192.168.56.255" >> $outfile;
    echo "network 192.168.56.0" >> $outfile;
    echo "netmask 255.255.255.0" >> $outfile;
    return 0;
}

add_interface
echo "[+] Configuration complete. Reboot."
