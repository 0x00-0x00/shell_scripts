#!/bin/bash

echo "Type the interface: "
read INTERFACE

echo "Type the machine IP: "
read IP

echo "Type the netmask: "
read NETMASK

echo "Type the gateway IP: "
read GW

echo "Type the ethernet address: "
read ETHERNET

echo "Bringing $INTERFACE down ..."
ifconfig $INTERFACE down
sleep 1

echo "Changing $INTERFACE ethernet address ..."
ifconfig $INTERFACE hw ether $ETHERNET
sleep 1

echo "Changing $INTERFACE IP address and Netmask configuration ..." 
ifconfig $INTERFACE $IP netmask $NETMASK
sleep 1

echo "Adding default route to intranet gateway ..."
route add default gw $GW $INTERFACE
sleep 1

echo "Bringing $INTERFACE up ..."
ifconfig $INTERFACE up
sleep 1

echo "Now remeber to check if DNS nameserver in /etc/resolv.conf is equal to machine configuration and you are set."
exit

