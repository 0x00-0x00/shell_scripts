#!/bin/bash
# -----------------------------------------
# Script escrito por Andre Marques (zc00l) 
# Instalacao automatizada do OwnCloud
# -----------------------------------------
FOLDER_NAME=/media/OwnCloud
USER_NAME=www-data
GROUP_NAME=www-data

# Get User ID number
uid=$(id -u)

if [ "$uid" != "0" ]; then
	echo "You need root permissions to run this script."
	exit
fi

# PART 1 - Downloading and Install
# Uncomment these lines to enable this PART.

#echo "[+] Installing OwnCloud repository into the system ..."
#sh -c "echo 'deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /' >> /etc/apt/sources.list.d/owncloud.list"
#echo "[+] Downloading GPG key from repository ..."
#wget -nv https://download.owncloud.org/download/repositories/stable/Debian_8.0/Release.key -O Release.key > /dev/null 2>&1
#echo "[+] Adding GPG key to apt-get ..."
#apt-key add - < Release.key
#echo "[!] Removing unnecessary files ..."
#rm Release.key > /dev/null 2>&1
#echo "[+] Updating package headers ..."
#apt-get update -y > /dev/null 2>&1
#echo "[+] Downloading and installing owncloud ..."
#apt-get install owncloud -y > /dev/null 2>&1

#-------------------------------------------------------
# END OF PART 1 
#-------------------------------------------------------

# ------------------------------------------------------
# Part 2 - Configuring OwnCloud & Apache SSL
# ------------------------------------------------------

#echo "[+] Creating OwnCloud Folder on ${FOLDER_NAME} ..."
#mkdir ${FOLDER_NAME} > /dev/null 2>&1

#echo "[+] Creating owncloud group named ${GROUP_NAME} ..."
#groupadd ${GROUP_NAME} > /dev/null 2>&1

#echo "[+] Creating user '${USER_NAME}' and adding it to group '${GROUP_NAME}'"
#usermod -a -G ${GROUP_NAME} ${USER_NAME} > /dev/null 2>&1

#echo "[+] Changing permissions from OwnCloud folder ..."
#chown -R ${USER_NAME}:${GROUP_NAME} ${FOLDER_NAME} > /dev/null 2>&1
#chmod -R 755 ${FOLDER_NAME} > /dev/null 2>&1

echo "[+] Enabling SSL on apache2 ..."
a2enmod ssl > /dev/null 2>&1

# Create directory for APACHE SSL
echo "[+] Creating SSL directory under /etc/apache2 folder ..."
mkdir /etc/apache2/ssl > /dev/null 2>&1

# Create certificate
echo "[+] Creating SSL certificate ..."
openssl req -x509 -nodes -days 365 -newkey rsa:2046 -keyout /etc/apache2/ssl/owncloud.key -out /etc/apache2/ssl/owncloud.crt

# Add data to apache2 SSL configuration
echo "[+] Configuring APACHE2 SSL keys ..."
OUT_FILE=/etc/apache2/sites-available/default-ssl.conf
echo "ServerName RPI IP :443" >> ${OUT_FILE}
echo "SSLEngine on" >> ${OUT_FILE}
echo "SSLCertificateFile /etc/apache2/ssl/owncloud.crt" >> ${OUT_FILE}
echo "SSLCertificateKeyFile /etc/apache2/ssl/owncloud.key" >> ${OUT_FILE}

