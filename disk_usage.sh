#!/bin/bash

mountpoint=/dev/root
lines=();
data=$(df -h | grep /dev/root | grep -oP '[0-9]+[GKB]' | sed 's/\s/\n/g')
perc=$(df -h | grep $mountpoint | grep -oP '[0-9]+%')


while read -r line;
do
    lines+=("$line");
done <<< "$data";

total_size=${lines[0]};
used_amount=${lines[1]};
available=${lines[2]};

function pretty
{
    echo "Mountpoint: $mountpoint";
    echo "_________________________";
    echo "Total size .: $total_size";
    echo "Used  ......: $used_amount";
    echo "Available ..: $available";
    echo "Percentage .: $perc";
}

function ugly
{
    echo "$total_size,$used_amount,$available,$perc";
}

if [[ $1 != "--pretty" ]] && [[ $1 != "--ugly" ]]; then
    echo "Usage: $0 --pretty || --ugly"
    exit;
fi

if [[ $1 == "--pretty" ]]; then
    pretty
else
    ugly
fi


