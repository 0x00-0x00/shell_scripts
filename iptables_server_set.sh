#!/bin/bash

# ------------------------ #
# Script escrito por zc00l #
# ------------------------ #

# Static variables 
SERVER_IP=($(hostname -I))
IPT=$(which iptables)

# Ports to enable
# Squid-proxy: 3128
# E-mails: 25, 587, 465, 110, 995
# HTTP and HTTPS: 80 & 443
ALLOW_PORTS=(22 25 80 443)

function clean_iptables 
{
	echo "[+] Clearing existing rules ..."
	${IPT} -F;
}

function allow_port 
{
	${IPT} -A INPUT -p tcp -d "$2" --sport $1 -m state --state ESTABLISHED -j ACCEPT;
	${IPT} -A INPUT -p tcp -d "$2" --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
	echo "[+] Created new rule: ACCEPT for $1 in CHAIN INPUT."
	${IPT} -A OUTPUT -p tcp -s "$2" --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
	${IPT} -A OUTPUT -p tcp -s "$2" --sport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
	echo "[+] Created new rule: ACCEPT for $1 in CHAIN OUTPUT."
}

function allow_icmp
{
	${IPT} -A INPUT -p icmp --icmp-type 8 -s 0/0 -d "$1" -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT;
	${IPT} -A OUTPUT -p icmp --icmp-type 0 -d 0/0 -s "$1" -m state --state ESTABLISHED,RELATED -j ACCEPT;
	${IPT} -A OUTPUT -p icmp --icmp-type 8 -s "$1" -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT;
	${IPT} -A INPUT -p icmp --icmp-type 0 -s 0/0 -d "$1" -m state --state ESTABLISHED,RELATED -j ACCEPT;


}

function allow_dns
{
	${IPT} -A INPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
	${IPT} -A OUTPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT;
	${IPT} -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
	${IPT} -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT;
	echo "[+] Created ruleset for DNS queries for IP $1."
}

function check_root 
{
	if [ "$1" != "0" ]; then
		echo "[!] You lack privileges to run this script."
		exit
	fi
}

function enable_log
{
	${IPT} -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'INPUT drop:'
	echo "[+] Logging enabled for chain INPUT."
	${IPT} -A INPUT -j DROP
	echo "[+] Chain INPUT set to DROP."
	${IPT} -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'OUTPUT drop: '
	echo "[+] Logging enabled for chain OUTPUT."
	${IPT} -A OUTPUT -j DROP
	echo "[+] Chain OUTPUT set to DROP."
}

# Script init
echo "[*] Checking privileges ..."
uid=$(id -u)
check_root $uid
clean_iptables

for arg in "$@"
do
	ALLOW_PORTS+=("$arg")
done

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
for host in "${SERVER_IP[@]}"
do
	#host=${SERVER_IP[0]}
	echo "[+] Creating ruleset for IP ${host} ..."
	allow_dns $host
	allow_icmp $host
	# Loop array into function
	for port in "${ALLOW_PORTS[@]}"
	do
		allow_port $port $host
	done
done

echo "[+] ${#ALLOW_PORTS[*]} ports were set to permissive rules in iptables."

enable_log

echo "[X] End of script."
exit



