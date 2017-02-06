#!/bin/bash

user=shemhazai
remote=watchersnet.ddns.net
lport=18000

function tunnel
{
    /usr/bin/ssh -N -R ${lport}:localhost:22 ${user}@${remote}
    if [[ $? -eq 0 ]]; then
        echo "Tunnel to jumpbox created successfully."
    else
        echo An error occurred creating a tunnel to jumpbox. Err: $?
    fi
}

tunnel
