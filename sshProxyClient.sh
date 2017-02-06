#!/bin/bash
# Client counterpart for SOCKS5 Proxy using SSH protocol
# Connects to Dynamic Forwarding listening on port 8080 at remote host.
# The server counter-part is named 'sshProxy.sh'
# 
# written by zc00l

user=shemhazai
remote=watchersnet.ddns.net
port=10000

function check_port 
{
    r=$(nc -zv localhost $port > /dev/null 2>&1)
}

echo -n "[+]  SOCKS tunnel with remote host ... "
ssh -NfL ${port}:localhost:8080 ${user}@${remote} -p 8080 > /dev/null 2>&1

check_port $port
if [[ $? -eq 0 ]]; then
    echo " OK.";
    exit;
else
    echo " FAIL.";
    exit
fi
