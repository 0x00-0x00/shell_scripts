#!/bin/bash

uid=$(id -u)
if [ "$uid" != "0" ]; then
	echo "No root."
	exit
fi

PERFORMANCE_FILE=/sys/class/drm/card0/device/power_dpm_force_perfomance_level

echo "[*] Checking GPU performance level ... "
status=$(cat $PERFORMANCE_FILE)

if [ "$status" == "high" ]; then
	echo "[+] Performance levels are set to HIGH."
	exit
else
	echo "[*] Setting GPU performance level to HIGH ..."
	cat high > $PERFORMANCE_FILE
fi

status=$(cat $PERFORMANCE_FILE)
if [ "$status" != "high" ]; then
	echo "[-] GPU performance level is not set to HIGH."
	exit
else
	echo "[+] GPU performance level is correctly defined."
	exit

