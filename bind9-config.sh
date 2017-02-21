#!/bin/bash
default_key="/etc/bind/rndc.key"
key_name="bind9.key+157+33323"

function check_root 
{
	uid=$(id -u)
	if [[ $uid != 0 ]]; then
		echo "[!] No privileges.";
		exit;
	fi
}

function check_exist
{
	#  Data checkage.
	if [[ $1 == "" ]]; then
		echo "[!] No input data.";
		exit;
	fi
	
	if [[ ! -e "$1" ]]; then
		echo "[!] File '$1' does not exists.";
		return -1;
	fi
	
	return 0;
}



check_root
check_exist $default_key


# Backup old key
echo -n "[*] Old key backup: "
cp $default_key default.key > /dev/null 2>&1
if [[ $? == 0 ]]; then
	echo "OK.";
else
	echo "FAIL.";
	exit;
fi


#  Create new key
echo -n "[*] New key creation: "
cd /etc/bind > /dev/null 2>&1;
dnssec-keygen -a HMAC-MD5 -b 512 -n USER K$key_name > /dev/null 2>&1
if [[ $? == 0 ]]; then
	echo "OK.";
else
	echo "FAIL.";
fi

echo $ls

