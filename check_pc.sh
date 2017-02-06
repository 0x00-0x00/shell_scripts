#!/bin/bash

remote=192.168.0.125
port=22



while [[ 1 -eq 1 ]]; 
	do
		status=$(nc ${remote} ${port} > /dev/null 2>&1)
		if [[ $? -eq 0 ]]; then
			echo "[+] Computer '${remote} is now online."
			push -t "Online PC" -m "Computer '${remote}' is now online."
		else
			echo "[!] Computer '${remote}' is still offline."
			sleep 60
			exit
		fi
			
	done
