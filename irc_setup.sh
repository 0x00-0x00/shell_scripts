#!/bin/bash

user="ircd"
website="https://unrealircd.org/unrealircd4/"
file="unrealircd-4.0.11.tar.gz "

set_up_user() {
	created=$(cat /etc/passwd | grep $user | wc -l);
	if [[ $created < 1 ]]; then
		echo "[+] Creating user 'ircd' ..."
		adduser ircd
	fi
	apt-get install sudo -y > /dev/null 2>&1
}

install_deps() {
	echo "[+] Installing deps ..."
	sudo apt-get install build-essential openssl libcurl4-openssl-dev zlib1g zlib1g-dev zlibc libgcrypt20 libgcrypt11-dev libgcrypt20-dev wget -y > /dev/null 2>&1
}

download_daemon() {
	cd ~
	echo "[+] Downloading daemon ..."
	wget --no-check-certificate $website$file > /dev/null 2>&1
	if [[ $? == 0 ]]; then
		echo "[*] File $file downloaded.";
	else
		echo "[!] File $file could not be downloaded.";
		exit 1;
	fi
}

install_daemon() {
	tar -xvf $file
	cd unr*/
	./Config
}

set_up_user
install_deps
download_daemon
install_daemon
