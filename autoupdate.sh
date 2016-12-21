#!/bin/bash
echo "Updating repositories ..."
apt-get update -y -qq >> /var/log/messages

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
message="Repository (apt) update procedure has been completed at $DATA $HORA"
subject="Repository update job"
recipient="shemhazai"

mail -s "$subject" $recipient <<< "$message"
push -t "$subject" -m "$message"

echo "[!] Report generated and successfully sent to recipient: $recipient"







