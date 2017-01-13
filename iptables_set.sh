#!/bin/bash

# ------------------------ #
# Script escrito por zc00l #
# ------------------------ #

# Static variables 
SERVER_IP=($(hostname -I))
ALLOW_PORTS=(22 25 53 80 443 3128 5222)
IPT=$(which iptables)

function clean_iptables 
{
	echo "[+] Clearing existing rules ..."
	${IPT} -F;
}

function allow_port 
{
	${IPT} -A INPUT -p tcp -d "$2" --sport $1 -m state --state ESTABLISHED -j ACCEPT;
	echo "[+] Created new rule: ACCEPT for $1 in CHAIN INPUT."
	${IPT} -A OUTPUT -p tcp -s "$2" --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
	echo "[+] Created new rule: ACCEPT for $1 in CHAIN OUTPUT."
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

for host in "${SERVER_IP[@]}"
do
	echo "[+] Creating ruleset for IP ${host} ..."
	allow_dns $host
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



