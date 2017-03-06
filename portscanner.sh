#!/bin/bash


if [[ $1 == "" ]]; then
    echo "Usage: $0 <HOST>";
    exit;
fi

function tcp_scan
{
    if [[ $1 == "" ]] || [[ $2 == "" ]]; then
        echo "Missing parameters.";
        exit;
    fi

    nc -zv $1 $2 2>&1 | grep -oP '[0-9]+\s\([\w]+\)\sopen' 
}


start_range=1;
end_range=65535;

while [[ $start_range -lt $end_range ]];
do
    tcp_scan $1 $start_range
    #  Increment variable
    ((start_range++));

done

