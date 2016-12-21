#!/bin/bash

id=$(id -u)
ipfile=/proc/sys/net/ipv4/ip_forward


echo "Checking privileges ..."
if [ "$id" != "0" ];
then
	echo "You need to be root."
	exit
fi

echo "Changing kernel setting for ip forwarding ..."
echo "1" >> $ipfile


echo "Checking changes ..."
v=$(cat $ipfile)
if [ "$v" != "1" ];
then
	echo "ERROR: Failed to set ip forward."
else
	echo "SUCCESS: Kernel IP forward was set."
fi
