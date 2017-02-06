#!/bin/bash

user=shemhazai
port=8080

echo -n "[+] Turning SSH SOCKS proxy online ..."
/usr/bin/ssh -D $port $user@localhost
if [[ $? -eq 0 ]]; then
	echo " Done.";
	exit;
else
	echo " ERROR $?";
	exit;
fi



