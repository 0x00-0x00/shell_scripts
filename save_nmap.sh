#!/bin/bash
uid=$(id -u)
data=$(date +%Y-%m-%d)
hora=$(date +%H:%M:%S)

#########################################################
# Configuration						#
#########################################################
IP_NETWORK=192.168.1.0/24

#Raspberry Pi Folder
ADMIN_GROUP=root
#ADMIN_GROUP=adm

#Raspberry Pi Folder
REPORT_FOLDER=/media/watchers/Arquivo/CONFIG/RaspberryPi/reports
#REPORT_FOLDER=/tmp

#########################################################
# Check if user has root privileges
if [ "$uid" != "0" ]; then
	echo "This script requires root privileges." 
	exit
fi


#########################################################
# Clean /tmp folder for files with name similiarity 

#Scans for files and deletes it
f=0
for file in /tmp/nmap_*; do ((f++)); done
if [ "$f" == "0" ]; then
	echo "No old report log found in temporary folder."
else
	for f in /tmp/nmap_*.*; do shred -u -z $f; done
fi

#########################################################
# Scan network and store results into file
OUTPUT_FILE=nmap_$data
echo "Scanning network '$IP_NETWORK' ..."
nmap -sS $IP_NETWORK -oA /tmp/$OUTPUT_FILE
echo "Scan completed."

#########################################################
# Compress scanning results into tarball
echo "Compressing output files ..."
FILE_FULLPATH=$REPORT_FOLDER/$OUTPUT_FILE.tar.xz
tar Jcvf $FILE_FULLPATH /tmp/nmap_*
echo "Compression is okay."


#########################################################
# Changes files permission to ensure data security
echo "Changing file permissions ..."
chown root $FILE_FULLPATH
chgrp $ADMIN_GROUP $FILE_FULLPATH
chmod 600 $FILE_FULLPATH
echo "New permissions sucessfully set."

#########################################################
# Send file to log folder
echo "Copying data to remote media device ..."
cp $FILE_FULLPATH /media/watchers/Arquivos/CONFIG/RaspberryPi/reports/
echo "Data copied successfully."


########################################################
# Check if smtp port is open
# Raspberry Pi is column 7 and flag "succeeded"
# While other netcat versions may be column 5 and "open" flag
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
message="Network security scanning procedure has been completed at $DATA $HORA"
subject="Network scanning job"
recipient="shemhazai"

mail -s "$subject" $recipient <<< "$message"
push -t "$subject" -m "$message"

echo "[!] Report generated and successfully sent to recipient: $recipient"

#########################################################
# End of Script
exit
