#!/bin/bash
DATE=$(date +%Y-%m-%d)

echo "[*] Starting server backup ..."

#Check if backup folder exists or creates it
BACKUP_FOLDER=/media/watchers/Backup/Backup_$DATE
if [ -d "$BACKUP_FOLDER" ]; then
	echo "[!] Backup directory already exists. Going to next step ..."
else
	echo "[*] Creating directory ..."
	mkdir -v -p /media/watchers/Backup/Backup_$DATE	
fi

# Folder of files to backup
FILES_DIR=/media/watchers/Arquivos
BACKUP_FILE="Server.tar.xz"

# Compress and store backup
echo "[*] Compressing files ..."
tar Jcvf $BACKUP_FOLDER/$BACKUP_FILE $FILES_DIR/* 
echo "[*] Files compressed.

# Check if smtp port is open
flag="succeeded!"
port_status=$(nc -zvn 0.0.0.0 25 2>&1 | awk {'print $7'})
if [ "$port_status" == "$flag" ]; then
        echo "[!] SMTP is ok."
        smtp=1
else
        echo "[!] SMTP service is missing"
        smtp=0
fi

#########################################################
# Finalize and report
if [ "$smtp" != "1" ]; then
        echo "As your system does not have any SMTP server, the script is not able to send mail messages to the user as the procedures completes or fails."
        echo "Script is terminating ..."
        exit
fi

echo "[!]Generating report ..."
DATA=$(date +%Y-%m-%d)
HORA=$(date +%H:%M:%S)
message="File backup procedure has been completed at $DATA $HORA"
subject="File backup job"
recipient="shemhazai"

mail -s "$subject" $recipient <<< "$message"
push -t "$subject" -m "$message"

echo "[!] Report generated and successfully sent to recipient: $recipient"


