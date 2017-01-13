#!/bin/bash

#Check if user is root as changing firewall settings are privileged actions.
uid=$(id -u)

if [ "$uid" != "0" ]; then
	echo "You must have super-user privileges to run this script."
	exit
fi

#------------------------
# Script configuration #
#------------------------
server_ip=192.168.0.123
allow_ports=(22 25 53 80 443 5222)
#outgoing_only=(10000:65535)
outgoing_only=(10000:10001)

# Zeroing the configuration first
iptables -F

# Allowing DNS queries
echo "[+] Setting up DNS rules ..."
iptables -A INPUT -p udp -d "${server_ip}" --dport 53 -m state --state ESTABLISHED -j ACCEPT;
iptables -A INPUT -p udp -d "${server_ip}" --sport 53 -m state --state ESTABLISHED -j ACCEPT;

iptables -A INPUT -p tcp -d "${server_ip}" --dport 53 -m state --state ESTABLISHED -j ACCEPT;
iptables -A INPUT -p tcp -d "${server_ip}" --sport 53 -m state --state ESTABLISHED -j ACCEPT;

iptables -A OUTPUT -p udp -s "${server_ip}" --sport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;

# Not needed.
iptables -A OUTPUT -p udp -s "${server_ip}" --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
#iptables -A OUTPUT -p tcp -d "${server_ip}" --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
#iptables -A OUTPUT -p tcp -s "${server_ip}" --sport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;


# Loop configuration
# --------------------
# Iterator variable
x=0

#Number of ports to be allowed (n)
y=6

while [ "$x" != "$y" ]; 
do
	echo "[+] Creating rules for port ${allow_ports[$x]} ..."; 
	#iptables -A INPUT -p tcp -d "${server_ip}" --sport ${allow_ports[$x]} -m state --state ESTABLISHED -j ACCEPT;
	iptables -A INPUT -p tcp -d "${server_ip}" --dport ${allow_ports[$x]} -m state --state NEW,ESTABLISHED -j ACCEPT;
	#iptables -A OUTPUT -p tcp -d "${server_ip}" --dport ${allow_ports[$x]} -m state --state NEW,ESTABLISHED -j ACCEPT;
	iptables -A OUTPUT -s "${server_ip}" -p tcp --sport ${allow_ports[$x]} -m state --state NEW,ESTABLISHED -j ACCEPT;
	((x++)); 
done
	echo ""
	echo "[*] Incoming/Outgoing rules ....... OK"
	echo ""

# Loop configuration
# --------------------
#Iterator variable
x=0
#Number of ports to create rules
y=1

while [ "$x" != "$y" ];
do
	echo "[+] Creating outgoing rules for port/ports ${outgoing_only[$x]} ...";
	#iptables -A OUTPUT -p tcp --dport ${outgoing_only[$x]} -j ACCEPT;
	iptables -A OUTPUT -p tcp -s "${server_ip}" --sport ${outgoing_only[$x]} -m state --state NEW,ESTABLISHED -j ACCEPT;
	((x++));
done	
	echo ""
	echo "[*] Outgoing-only rules ........... OK"
	echo ""

echo "[*] Changing default policy to DROP and enabling logs..."
iptables -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IP INPUT drop: '
iptables -A INPUT -j DROP

iptables -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'IP OUTPUT drop: '
iptables -A OUTPUT -j DROP

echo "[+] All done."
