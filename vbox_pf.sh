#!/bin/bash
#  Forward TCP connections from host to guest using vboxmanage
#  Written by zc00l

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]]; then
    echo "Usage: $0 <VirtualMachine Name> <local_port> <vm_port>";
    exit;
fi

# Generate a md5 hash for port-forward name
md5=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n1 | md5sum | awk {'print $1'})

echo -n "Port forwarding host:$2 to virtual:$3 :"
vboxmanage modifyvm "$1" --natpf1 "$md5,tcp,,$2,$3"

if [[ $? == 0 ]]; then
    echo "OK";
else
    echo "FAIL";
fi

