#!/bin/bash

function kill_process
{
    echo -n -e "[\033[093m*\033[0m] Interrupting process $1: ";
    kill -int $1;
    if [[ $? == 0 ]]; then
        echo -e "\033[092mSUCCESS\033[0m";
    else
        echo -e "\033[091mFAILED\033[0m";
        return 1;
    fi
    return 0;
}

while getopts ":p:h" opt "${SET[@]}"; do
    case $opt in
        ?) echo -e "To see the help section, type:\n   $0 -h";;
        h) echo -e "Usage: $0 -p \033[093m<PID>\033[0m"; exit 0;;
        p) kill_process $OPTARG; exit $?;;
    esac
done
