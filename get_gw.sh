#!/bin/bash

data=$(route -n);
lines=()
while read -r line;
do
    lines+=("$line");
done <<< "$data";

for line in "${lines[@]}";
do
    destination=$(echo "$line" | awk {'print $1'})
    if [ "$destination" == "0.0.0.0" ]; then
        gw=$(echo "$line" | awk {'print $2'});
        echo $gw;
    fi
done

