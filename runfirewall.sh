#!/bin/bash

# Defines
uid=$(id -u);

function report_status
{
    if [[ $1 == 0 ]]; then
        echo -e "\033[092mSUCESS\033[0m";
    else
        echo -e "\033[091mFAILED\033[0m";
    fi
}


function error
{
    echo -e "[\033[093m!\033[0m] \033[091mERROR\033[0m: $1";
    return 0;
}


function check_root
{
    if [[ $uid != 0 ]]; then
        error "Only root can activate/deactivate firewall";
        exit 1;
    fi
    return 0;
}


function count_firewall_rules
{
    n=$(iptables -L | grep -vE 'Chain?|target' | grep -E '^[a-zA-Z]' | wc -l);
    echo $n;
}


function check_firewall_presence
{
    echo -n -e "[\033[093m*\033[0m] Checking iptables: "
    modprobe ip_tables;
    report_status $?;
    if [[ $? == 1 ]]; then
        exit 1;
    fi
}


function free_firewall
{
    echo -n -e "[\033[092m*\033[0m] Clearing iptables rules: ";
    iptables -F;
    report_status $?;
    if [[ $? == 1 ]]; then
        exit 1;
    fi
}


function activate_firewall
{
    script=/opt/shell_scripts/iptables_slackware.sh
    echo -n -e "[\033[093m*\033[0m] Executing iptables script: ";
    echo "y" | $(which bash) $script > /dev/null 2>&1;
    report_status $?;
    if [[ $? == 1 ]]; then
        exit 1;
    fi
}


check_root;
check_firewall_presence;
free_firewall
activate_firewall
