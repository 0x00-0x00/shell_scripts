#!/bin/bash

#Configuration
SWAP_LOCATION=/
KB=1024

echo "Swap file creation script"
echo "written by shemhazai at 2016-11-07"
echo "------------------------------------"

#Check if root
uid=$(id -u)
if [ "$uid" != "0" ]; then
	echo "You do not have enough permissions to run this script."
	exit
fi

echo ""
echo "--------------------------------"
echo "Welcome to the SFCW"
echo "Swap File Creation Wizard"
echo "--------------------------------"
echo "Default configurations: "
echo "Swap file location: $SWAP_LOCATION"

echo "Type swap file name:"
read SWAP_FILENAME

echo "Type swap file size in megabytes:"
read SWAP_SIZE
REAL_SWAP_SIZE=$((SWAP_SIZE * KB))

echo "[*] Set $SWAP_SIZE mega-bytes to swap file."

echo ""
echo "[!] Creating swap file ..."
dd if=/dev/zero of=$SWAP_LOCATION/$SWAP_FILENAME bs=$KB count=$REAL_SWAP_SIZE > /dev/null 2>&1

#Check if swap file exists.
if [ -a $SWAP_LOCATION/$SWAP_FILE ]; then
	echo "[*] Swap file created."
	
	echo "[*] Changing swap file permissions..."
	chown root:root "$SWAP_LOCATION/$SWAP_FILE" > /dev/null 2>&1
	chmod 600 "$SWAP_LOCATION/$SWAP_FILE" > /dev/null 2>&1
	echo "[*] Root permission set to swap file."

	echo "[*] Converting file to swap ..."
	mkswap "$SWAP_LOCATION/$SWAP_FILE" > /dev/null 2>&1
	echo "[*] File converted to swap successfully."

	echo "[*] Enabling swap file ..."
	swapon $SWAP_LOCATION/$SWAP_FILE
	echo "[*] Swap file enabled."
	
else
	echo "[*] Swap file was not created."
fi

exit
