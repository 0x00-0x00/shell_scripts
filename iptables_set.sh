#!/bin/bash

#Check if user is root as changing firewall settings are privileged actions.
uid=$(id -u)

if [ "$uid" != "0" ]; then
	echo "You must have super-user privileges to run this script."
	exit
fi


allow_ports=(22 25 80 443 8080 5222 9999)
outgoing_only=(10000:65535)

x=0
while [ "$x" != "4" ]; 
do
	echo "Creating rules for port ${allow_ports[$x]} ..."; 
	sudo iptables -A INPUT -p tcp --dport ${allow_ports[$x]} -j ACCEPT;
	sudo iptables -A INPUT -p tcp --sport ${allow_ports[$x]} -j ACCEPT;
	sudo iptables -A OUTPUT -p tcp --sport ${allow_ports[$x]} -j ACCEPT;
	sudo iptables -A OUTPUT -p tcp --dport ${allow_ports[$x]} -j ACCEPT;
	((x++)); 
done

	echo "Incoming/Outgoing rules ....... OK"
	

x=0
while [ "$x" != "1" ];
do
	echo "Creating outgoing rules ...";
	sudo iptables -A OUTPUT -p tcp --dport ${outgoing_only[$x]} -j ACCEPT;
	sudo iptables -A OUTPUT -p tcp --sport ${outgoing_only[$x]} -j ACCEPT;
	((x++));
done	
	echo "Outgoing-only rules ........... OK"


echo "Changing default policy to DROP ..."
iptables -P INPUT DROP
iptables -P OUTPUT DROP

echo "All done."
