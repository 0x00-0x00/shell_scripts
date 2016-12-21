#!/bin/bash

echo "Type remote host user: "
read USER

echo "Type remote host IP: " 
read IP

if [ -a "~/.ssh/id_rsa.pub" ]; then
	echo "[*] Local public key was found."
else
	echo "[!] Local public key was not found."
	ssh-keygen
	
fi

cat ~/.ssh/id_rsa.pub | ssh ${USER}@${IP} 'cat >> ~/.ssh/authorized_keys'

echo "Procedure complete."
exit
