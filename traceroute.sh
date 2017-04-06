#!/bin/bash

hops=0;
host="8.8.8.8";

function log
{
    echo -e "\033[092mINFO\033[0m: $1";
    return 0;
}

function error
{
    echo -e "\033[091mERRO\033[0m: $1";
    return 0;
}

function helpme
{
    echo -e "\033[093mUso\033[0m: $0 -n NumeroDeHops";
    exit 0;
}

if [[ ${#} < 2 ]]; then
    helpme;
fi

while getopts "n:" opt; do
    case $opt in
        n)hops=$OPTARG; log "Numero de hops definido em: $OPTARG";;
    esac;
done;

if [[ $hops < 1 ]]; then
    error "Numero de hops deve ser superior a 0!";
    exit 1;
fi

seq 1 ${hops} | while read TTL; do
    HOP=$(ping ${host} -c 1 -t ${TTL} -W 2 | grep -oP '[Ff]rom [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk {'print $2'});
    if [[ $HOP == "" ]]; then
        HOP="*";
    fi
    if [[ $? != 0 ]]; then
        echo -e "[\033[093m+\033[0m] Hop numero ${TTL} ${HOST}";
    else
        echo -e "[\033[093m+\033[0m] Hop numero ${TTL} ${HOP}";
        if [[ $HOP == $host ]]; then
            exit 0;
        fi
    fi
done
