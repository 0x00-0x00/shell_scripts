#!/bin/bash

uid=$(id -u)

if [ "$uid" != 0 ]; then
	echo "You do not have permissions to run this script."
	exit
fi
DESTINATION=/media/watchers/Arquivos/CONFIG/RaspberryPi/reports
FILE=tree_$(date +%Y-%m-%d).log

##### Save File Tree #####
echo "Saving file tree ..."
/usr/bin/tree -A -h /media/watchers > $DESTINATION/$FILE


ADMIN_GROUP=root
##### Change file permissions ######
echo "Changing log file permissions ..."
chown root $DESTINATION/$FILE
chgrp $ADMIN_GROUP $DESTINATION/$FILE
chmod 600 $DESTINATION/$FILE
echo "Log file permission set."


########################################################
# Check if smtp port is open
########
# netcat versions differs on -zvn attribute response 
# Options:
#col=5
#flag=open
#-------------------
#col=7
flag="succeeded!"

port_status=$(nc -zvn 0.0.0.0 25 2>&1 | awk {'print $7'})
if [ "$port_status" == "$flag" ]; then
	echo "[!] SMTP is ok."
	smtp=1
else
	echo "[!] SMTP service is missing"
	smtp=0
fi

######### Finalize and report ############

if [ "$smtp" != "1"  ]; then
	echo "As your system does not have any SMTP server, the script is not able to send mail messages to the user as the procedures completes or fails."
	echo "Script is terminating ..."
        exit
fi

echo "[!] Generating report ..."
DATA=$(date +%Y-%m-%d)
HORA=$(date +%H:%M:%S)
message="File tree report procedure has been completed at $DATA $HORA"
subject="File tree job"
recipient="shemhazai"

mail -s "$subject" $recipient <<< "$message"
push -t "$subject" -m "$message"

echo "[!] Report generated successfully and sent to recipient: $recipient"

##### End of Script
exit
