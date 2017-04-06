#!/bin/bash
# || Bash script made by Z3r0-C00L
# ||   Automatic rsync my data files to the external HDD and remote SSH server
# ||

log_file=/var/log/backuplog.log;
uid=$(id -u);

## Variable definition
local_source=/media/watchers/Arquivos/
local_dest=/media/BACKUP_HDD/$(date +%Y-%m-%d)

#  Remote variables
remote_host=""
remote_user=""
remote_dest=""

function report_status
{
    if [[ $1 == 0 ]]; then
        echo -e "\033[092mSUCCESS\033[0m";
    else
        echo -e "\033[091mFAILED\033[0m";
        return 1;
    fi
    return 0;
}


function log
{
    msg="[\033[093m*\033[0m] $1 ";
    echo -e "$msg";
    echo -e "$msg" >> $log_file;
    return 0;
}


function error
{
    msg="[\033[093m!\033[0m] \033[091m[\033[93m!\033[0m] \033[091mERROR\033[0m:\033[0m $1";
    echo -e "$msg";
    echo -e "$msg" >> $log_file;
    return 0;
}


function check_root
{
    if [[ $uid != 0 ]]; then
        echo -e "\033[091mERROR\033[0m: Only root can realize backup procedure.";
        exit 1;
    fi
    return 0;
}


function local_backup
{
    rsync -r $local_source $local_dest;
    return $?;
}

function remote_backup
{
    if [[ $remote_user == "" ]] || [[ $remote_dest == "" ]] || [[ $remote_host == "" ]]; then
       echo -e "[\033[93m!\033[0m] \033[091mERROR\033[0m: Not enough arguments supplied for handle the remote synchronization.";
       exit 1;
    fi
    #ssh $remote_user@$remote_host "mkdir ${remote_dest}/$(date +%Y-%m-%d)";
    #if [[ $? != 0 ]]; then
    #    echo -e "[\033[93m!\033[0m] \033[091mERROR\033[0m: Could not create backup folder.";
    #    exit 1;
    #fi
    echo "[+] Source: ${local_source}";
    echo "[+] Destination: ${remote_user}@${remote_host}:${remote_dest}";
    rsync -r ${local_source} ${remote_user}@${remote_host}:${remote_dest};
    if [[ $? == 0 ]]; then
        echo "[!] Complete.";
    else
        echo "[!] Failed.";
    fi
    return 0;
}

check_root;
if [[ $1 == "" ]]; then
    echo -e "For help and documentation, type:\n   $0 -h";
    exit 0;
fi

while getopts "lrhd:i:u:" opt; do
    case $opt in
        l) local_backup;;
        r) remote_backup;;
        i) remote_host=$OPTARG; echo "[+] Remote host set to: $OPTARG";;
        u) remote_user=$OPTARG; echo "[+] Remote user set to: $OPTARG";;
        d) remote_dest=$OPTARG; echo "[+] Remote dest set to: $OPTARG";;
        h) echo -e "\033[02mUsage\033[0m: $0 [-l -r]\n \033[01m-l\033[0m for Local Backup\n \033[1m-r\033[0m for Remote Backup\n \033[01m-i\033[0m Remote IP address\n \033[01m-u\033[0m Remote User Name\n \033[01m-d\033[0m Remote Folder"; exit 0;;
    esac
done

