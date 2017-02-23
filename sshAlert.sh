#!/bin/bash
#  SSH alert using simple push api to notify
#  system administrator when failed ssh login
#  attempts are made.
# ----------------------------------------------
#  Written by zc00l



log_locations=(/var/log/secure /var/log/auth)

#  Check if have enough privileges.
uid=$(id -u);
if [[ ${uid} != 0 ]]; then
    echo "[!] You do not have enough permissions.";
    exit;
fi


#  Define the log file.
for f in "${log_locations[@]}";
do
    if [[ -e $f ]]; then
        log_file=$f;
        break;
    fi
done


function filter_attempt
{
    # Need data!
    if [[ $1 == "" ]]; then
        return 1;
    fi
    conn_type=$(echo $1 | awk {'print $2'});
    user=$(echo $1 | awk {'print $4'});
    ip=$(echo $1 | awk {'print $6'});
    err_string="Wrong $conn_type attempt to log-in in $user by $ip";
    echo "$err_string";
    #push -t "Failed login" -m "$err_string";
    return 0;
}

function start_daemon
{
    regex="Failed\s[\s\w\.]+";
    while [[ 1 -eq 1 ]];
    do
        log_data=$(tail $log_file | grep -oP $regex | wc -l);
        sleep 3;
        u_log_data=$(tail $log_file | grep -oP $regex | wc -l);
        if [[ $log_data != $u_log_data ]]; then
            lines=();
            new_data="$(tail -n$u_log_data $log_file | grep -oP $regex)";
            while read -r line;
            do
                lines+=("$line");
            done <<< "$new_data";
            for l in "${lines[@]}";
            do
                filter_attempt "$l";
            done
        fi
    done
}

start_daemon

