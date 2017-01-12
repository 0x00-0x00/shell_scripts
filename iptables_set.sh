#!/bin/bash

#Check if user is root as changing firewall settings are privileged actions.
uid=$(id -u)

if [ "$uid" != "0" ]; then
	echo "You must have super-user privileges to run this script."
	exit
fi


allow_ports=(22 25 80 443 5222)
outgoing_only=(10000:65535)

###################################
#       LOOP CONFIGURATION        #
###################################
#Iterator variable
x=0

#Number of ports to be allowed (n)
y=5
while [ "$x" != "$y" ]; 
do
	echo "[+] Creating rules for port ${allow_ports[$x]} ..."; 
	iptables -A INPUT -p tcp --dport ${allow_ports[$x]} -j ACCEPT;
	iptables -A INPUT -p tcp --sport ${allow_ports[$x]} -j ACCEPT;
	iptables -A OUTPUT -p tcp --sport ${allow_ports[$x]} -j ACCEPT;
	iptables -A OUTPUT -p tcp --dport ${allow_ports[$x]} -j ACCEPT;
	((x++)); 
done
	echo ""
	echo "[*] Incoming/Outgoing rules ....... OK"
	echo ""

###################################
#       LOOP CONFIGURATION        #
###################################
#Iterator variable
x=0
#Number of ports to create rules
y=1

while [ "$x" != "$y" ];
do
	echo "[+] Creating outgoing rules ...";
	iptables -A OUTPUT -p tcp --dport ${outgoing_only[$x]} -j ACCEPT;
	iptables -A OUTPUT -p tcp --sport ${outgoing_only[$x]} -j ACCEPT;
	((x++));
done	
	echo ""
	echo "[*] Outgoing-only rules ........... OK"
	echo ""

echo "[*] Changing default policy to DROP ..."
iptables -P INPUT DROP
iptables -P OUTPUT DROP

echo "[+] All done."
