#!/bin/bash
# Script by zc00l
# Generate informative report about linux system specifications
#


#  Header function to padronize output
function header
{
    echo "______________________"
    echo "$1";
    echo "======================";
}


function gather_cpu
{
    arch=$(lscpu | grep Arch | awk {'print $2'});
    cpu_count=$(lscpu | grep "CPU(s)" | head -n1 |  awk {'print $2'});
    model=$(lscpu | grep "Model name" | sed 's/Model name:\s*//');
    ghz=$(lscpu | grep "CPU max MHz" | sed 's/CPU max MHz:\s*//' );
    header "CPU";
    echo "Arch .........: $arch";
    echo "CPUs .........: $cpu_count";
    echo "Model ........: $model";
    echo "MHz ..........: $ghz";
}

function gather_mem
{
    total=$(free -h -m | grep Mem | awk {'print $2'});
    swap=$(free -h -m | grep Swap: | awk {'print $2'});
    header "Memory";
    echo "Total RAM ....: $total";
    echo "Swap size ....: $swap";
}

function gather_disk
{
    total_disk=$(df -h | grep /dev/root | awk {'print $2'});
    total_use=$(df -h | grep /dev/root | awk {'print $3'});
    percent=$(df -h | grep /dev/root | awk {'print $5'});
    header "Disk Usage";
    echo "Total space ..: $total_disk";
    echo "Space in use .: $total_use";
    echo "In use pctg ..: $percent";
}



gather_cpu
gather_mem
gather_disk
