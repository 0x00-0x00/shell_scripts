#!/bin/bash

GRN='\033[0;92m'
RED='\033[0;91m'
YEL='\033[0;93m'
NO='\033[0m'

# ------------------------ #
# Script escrito por zc00l #
# ------------------------ #


# Iptables binary definition
IPT=$(which iptables)

# Ports to enable
# Squid-proxy: 3128
# E-mails: 25, 587, 465, 110, 995
# HTTP and HTTPS: 80 & 443
# SMB: 139 & 445
# TorSocks: 9050
# XMPP: 5222
ALLOW_PORTS=(22 80 139 445 443 3128 8080 5222 9050)
ALLOWED=(22)

function get_interface
{
    data=$(route -n);
    lines=()
    while read -r line;
    do
        lines+=("$line");
    done <<< "$data";

    for line in "${lines[@]}";
    do
        destination=$(echo "$line" | awk {'print $1'})
        if [ "$destination" == "0.0.0.0" ]; then
            gw=$(echo "$line" | awk {'print $8'});
            echo $gw;
	    return;
        fi
    done
}

function get_ip
{
    ip=$(ifconfig $(get_interface) | grep -oP '[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}' | head -n1)
    echo "$ip";
}

function clean_iptables
{
	echo -n "[+] Clearing existing rules: "
	${IPT} -F;
    if [[ $? != 0 ]]; then
        echo -e "${RED}FAIL${NO}";
        exit;
    else
        echo -e "${GRN}OK${NO}";
    fi
}

function allow_port
{
	${IPT} -A INPUT -p tcp -d "$2" --sport $1 -m state --state ESTABLISHED -j ACCEPT;
	echo -e "[+] Created new rule: ${GRN}ACCEPT${NO} for $1 in CHAIN INPUT."
	${IPT} -A OUTPUT -p tcp -s "$2" --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
	echo -e "[+] Created new rule: ${GRN}ACCEPT${NO} for $1 in CHAIN OUTPUT."
}

function allow_dns
{
	${IPT} -A INPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
	${IPT} -A OUTPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT;
	${IPT} -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
	${IPT} -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT;
	echo -e "[+] Created ruleset for ${YEL}DNS queries${NO} for IP $1."
}

function allow_icmp {
    ${IPT} -A INPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT;
    ${IPT} -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT;
    return 0;
}


function check_root
{
	if [ "$1" != "0" ]; then
        echo -e "${RED}FAIL${NO}";
		echo -e "[!] ${RED}ERROR${NO}: You lack privileges to run this script."
		exit
    else
        echo -e "${GRN}OK${NO}"
	fi
}

function enable_log
{
	${IPT} -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'INPUT drop:'
	echo -e "[+] Logging ${GRN}enabled${NO} for chain INPUT."
	${IPT} -P INPUT DROP
	echo -e "[+] Chain INPUT set to ${RED}DROP${NO}."
	${IPT} -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'OUTPUT drop: '
	echo -e "[+] Logging ${GRN}enabled${NO} for chain OUTPUT."
	${IPT} -P OUTPUT DROP
	echo -e "[+] Chain OUTPUT set to ${RED}DROP${NO}."
}

# Script init
echo -n "[*] Checking privileges: "
uid=$(id -u)
check_root $uid

ip=$(get_ip);
echo -n "[*] Resolving IP address: ";
echo $ip;
echo -n "Is this information correct? [y/N]";
read k;
if [ "$k" == "y" ] || [ "$k" == "Y" ]; then
    echo "[*] Setting IP to $ip.";
else
    echo "[!] Aborting program."
    exit;
fi


SERVER_IP=("$ip");
clean_iptables

for arg in "$@"
do
	ALLOW_PORTS+=("$arg")
done

allow_icmp;  # allow icmp packets
for host in "${SERVER_IP[@]}"
do
	echo "[+] Creating ruleset for IP ${host} ..."
	allow_dns $host;
	# Loop array into function
	for port in "${ALLOW_PORTS[@]}"
	do
		allow_port $port $host
	done
	# Check if input port is in ALLOWED_SERVICES variable
    	for port in "${ALLOWED[@]}"
    	do
        	${IPT} -A INPUT -p tcp -d "$host" --dport $port -m state --state NEW,ESTABLISHED -j ACCEPT;
        	${IPT} -A OUTPUT -p tcp -s "$host" --sport $port -m state --state NEW,ESTABLISHED -j ACCEPT;
    	done



done

echo "[+] ${#ALLOW_PORTS[*]} ports were set to permissive rules in iptables."

enable_log

echo -e "[X] \033[0;1mEnd of script${NO}."
exit



