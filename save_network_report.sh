#!/bin/bash


# Configuration
INTERFACE=eth0
DESTINATION=/media/watchers/Arquivos/CONFIG/RaspberryPi/reports
LOG_FILE=vnstat_$(date +%Y-%m-%d).log


# Initialization
echo "Generating bandwidth report ..."
vnstat -i $INTERFACE --short > $DESTINATION/$LOG_FILE


# Check if smtp port is open
#Raspberry Pi Settings
flag="succeeded!"
#Slackware settings
#flag="open"
port_status=$(nc -zvn 0.0.0.0 25 2>&1 | awk {'print $7'})
if [ "$port_status" == "$flag" ]; then
        echo "[!] SMTP is ok."
        smtp=1
else
        echo "[!] SMTP service is missing"
        smtp=0
fi       

# Finalize and report
echo "[!] Generating reporting ..."
DATA=$(date +%Y-%m-%d)
HORA=$(date +%H:%M:%S)
message="Network bandwidth usage report procedure has been completed at $DATA $HORA"
subject="Network bandwidth usage report job"
recipient="shemhazai"

mail -s "$subject" $recipient <<< "$message"
push -t "$subject" -m "$message"

echo "[!] Report generated and successfully sent to recipient: $recipient"

#### End
exit
