#!/bin/bash

uid=$(id -u);
if [[ $uid != 0 ]]; then
	echo "[!] Error: Only root can disk clone.";
	exit;
fi

if [[ $1 == "" ]] || [[ $2 == "" ]]; then
	echo -e "\033[092mUsage: \033[0m $0 <DISK> <IMG.img.gz>";
	exit;
fi

echo -n -e "[\033[093m*\033[0m] Cloning disk $1: ";
dd if=$1 conv=noerror,sync bs=64K | gzip -c > $2;
date_stamp=$(date +%Y-%m-%d_%H-%M-%S);
if [[ $? != 0 ]]; then
	echo -e "\033[091mFAILED\033[0m";
	echo "Backup failed at $date_stamp" >> /var/log/backup.log;
else
	echo -e "\033[092mSUCCESS\033[0m";
	echo "Backup successful at $date_stamp" >> /var/log/backup;
fi
exit

