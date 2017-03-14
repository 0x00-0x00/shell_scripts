#!/bin/bash
# Script escrito por Andre Marques (zc00l)
#  RunFireWall serve de script de gatilho,
#  para outro script, ativador de firewall.
#  Faz a checagem de processos para a habilitacao/desabilitacao
#  do firewall em momentos distintos.
##

# Statically defined variables
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


#  Processos que, quando detectados, desabilitam o firewall
function check_banned_processes
{
    banned=("sshuttle" "aria2c");
    for program in "${banned[@]}"; do
        n=$(ps -A | grep $program | wc -l);
        if [[ $n -gt 0 ]]; then
            error "Process ${program} detected. Deactivating firewall...";
            exit 1;
        fi
    done
    return 0;
}


check_root;
check_firewall_presence;
free_firewall
check_banned_processes
activate_firewall
