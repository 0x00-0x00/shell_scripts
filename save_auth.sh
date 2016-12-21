#!/bin/bash
start_time=$(python -c "import time; print time.time()")
DATA=$(date +%Y-%m-%d)
HORA=$(date +%H:%M:%S)
destination=/media/watchers/Arquivos/CONFIG/RaspberryPi/reports
log_file=auth-log_$(date +%Y-%m-%d).tar.xz


echo "Saving authentication logs ..."
tar Jcvf $destination/$log_file /var/log/auth*


end_time=$(python -c "import time; print time.time()")
DATA=$(date +%Y-%m-%d)
HORA=$(date +%H:%M:%S)

#Check if file exists and reports to mail
if [ -f "$destination/$log_file" ]; then
	echo "Authentication logs successfuly stored"
	mail -s "Authentication job" shemhazai <<< "Authentication job took $(end_time - start_time) seconds and has been completed at $DATA $HORA"
	exit
else
	echo "Authentication logs have not been stored.."
	mail -s "Authentication job" shemhazai <<< "Authentication job has failed to complete at $DATA $HORA"
	exit
fi
