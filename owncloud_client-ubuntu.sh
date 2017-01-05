#!/bin/bash
# OwnCloud client installer for Ubuntu 16.04 
# Escrito por Andre Marques (zc00l/shemhazai)
#
uid=$(id -u)
if [ "$uid" != "0" ]; then
	echo "You need administrative privileges to run this script."
	exit
fi


# Variables definition 
UBUNTU_1610=http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_16.10/
UBUNTU_1610_KEY=http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_16.10/Release.key

UBUNTU_16=http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_16.04/
UBUNTU_16_KEY=http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_16.04/Release.key

UBUNTU_15=http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_15.04/
UBUNTU_15_KEY=http://download.opensuse.org/repositories/isv:ownCloud:desktop/Ubuntu_15.04/Release.key



# For ubuntu 15.10
# sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_15.10/ /' > /etc/apt/sources.list.d/owncloud-client.list"

#For Ubuntu 16.10
# sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_16.10/ /' > /etc/apt/sources.list.d/owncloud-client.list"

#For ubuntu 15.04
# sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/Ubuntu_15.04/ /' > /etc/apt/sources.list.d/owncloud-client.list"

#For ubuntu 16.04
echo "[+] Downloading GPG key of OwnCloud repository ..."
wget ${UBUNTU_16_KEY} -O /tmp/Release.key > /dev/null 2>&1

echo "[+] Adding key to apt-get ... "
apt-key add - < /tmp/Release.key

echo "[*] Cleaning unneccessary files ..."
shred -u -z /tmp/Release.key

echo "[+] Adding owncloud desktop repository to sources.list ... "
sh -c "echo 'deb ${UBUNTU_16} /' > /etc/apt/sources.list.d/owncloud-client.list"

echo "[+] Updating package headers ... "
apt-get update > /dev/null 2>&1

echo "[+] Installing owncloud-client ..."
apt-get install owncloud-client -y > /dev/null 2>&1

# Complete
echo "[*] OwnCloud-client package has been installed."
