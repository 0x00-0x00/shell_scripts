#!/bin/bash

function public_key
{
user_name=$(id -u -n)
if [ -e "/home/$user_name/.ssh/id_rsa.pub" ]; then
	echo "[+] Local public key was found."
else
	echo "[-] Local public key was not found."
	ssh-keygen	
fi
}


x=0
for arg in "$@"
do
((x++));
done

# Check argument number
if [ "$x" != "2" ]; then
	echo "Usage: $0 USER SERVER_IP"
	exit
fi

# Check public key and/or generate it.
public_key

# Copy content of public key into authorized_keys file of server
cat ~/.ssh/id_rsa.pub | ssh $1@$2 'cat >> ~/.ssh/authorized_keys'

echo "[+] Procedure complete."
exit
