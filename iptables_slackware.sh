#!/bin/bash

# ------------------------ #
# Script escrito por zc00l #
# ------------------------ #


# Iptables binary definition
IPT=$(which iptables)

# Ports to enable
# Squid-proxy: 3128
# E-mails: 25, 587, 465, 110, 995
# HTTP and HTTPS: 80 & 443
ALLOW_PORTS=(22 25 80 443)
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
        echo "\033[091mFAIL\033[0m";
        exit;
    else
        echo "\033[092OK\033[0m";
    fi
}

function allow_port
{
    # Check if input port is in ALLOWED_SERVICES variable
    for port in "${ALLOWED[@]}"
    do
        ${IPT} -A INPUT -p tcp -d "$2" --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
        ${IPT} -A OUTPUT -p tcp -s "$2" --sport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
    done

	${IPT} -A INPUT -p tcp -d "$2" --sport $1 -m state --state ESTABLISHED -j ACCEPT;
	echo "[+] Created new rule: \033[092mACCEPT\033[0m for $1 in CHAIN INPUT."
	${IPT} -A OUTPUT -p tcp -s "$2" --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT;
	echo "[+] Created new rule: \033[092mACCEPT\033[0m for $1 in CHAIN OUTPUT."
}

function allow_dns
{
	${IPT} -A INPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
	${IPT} -A OUTPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT;
	${IPT} -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT;
	${IPT} -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT;
	echo "[+] Created ruleset for \033[93mDNS queries\033[0m for IP $1."
}

function check_root
{
	if [ "$1" != "0" ]; then
        echo "\033[091mFAIL\033[0m";
		echo "[!] \033[091mERROR\033[0m: You lack privileges to run this script."
		exit
    else
        echo "\033[092mOK\033[0m"
	fi
}

function enable_log
{
	${IPT} -A INPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'INPUT drop:'
	echo "[+] Logging \033[092menabled\033[0m for chain INPUT."
	${IPT} -A INPUT -j DROP
	echo "[+] Chain INPUT set to \033[091mDROP\033[0m."
	${IPT} -A OUTPUT -j LOG -m limit --limit 12/min --log-level 4 --log-prefix 'OUTPUT drop: '
	echo "[+] Logging \033[092menabled\033[0m for chain OUTPUT."
	${IPT} -A OUTPUT -j DROP
	echo "[+] Chain OUTPUT set to \033[091mDROP\033[0m."
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

echo "[X] \033[1mEnd of script\033[0m."
exit



