#!/bin/bash

function tunnel
{
    /usr/bin/ssh -N -R 18000:localhost:22 shemhazai@watchersnet.ddns.net
    if [[ $? -eq 0 ]]; then
        echo "Tunnel to jumpbox created successfully."
    else
        echo An error occurred creating a tunnel to jumpbox. Err: $?
    fi
}



tunnel
