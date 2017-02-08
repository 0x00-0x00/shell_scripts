#!/bin/bash

user=shemhazai
remote=watchersnet.ddns.net
lport=18000

function tunnel
{

    nc -zv ${remote} 22
    while [[ $? -eq 1 ]]; 
    do
        sleep 30
        nc -zv ${remote} 22
    done

    /usr/bin/ssh -N -R ${lport}:localhost:22 ${user}@${remote} > /dev/null 2>&1 &
    if [[ $? -eq 0 ]]; then
        echo "Tunnel to jumpbox created successfully."
    else
        echo An error occurred creating a tunnel to jumpbox. Err: $?
    fi
}


tunnel
