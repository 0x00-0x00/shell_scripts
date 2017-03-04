#!/bin/bash
# Script by zc00l
# Generate informative report about linux system specifications
#

uid=$(id -u);
if [[ $uid != 0 ]]; then
    echo "[!] Error: Not enough privileges to run this script.";
    exit;
fi

function gather_cpu
{
    data=$(lscpu);
    arch=$(echo $data | grep Arch | awk {'print $2'});
    cpu_count=$(echo $data | grep CPU(s) | awk {'print $2'});
    model=$(echo $data | grep Model | awk {'print $2'});
    ghz=$(echo $data | grep "CPU max MHz" | awk {'print $2'});

    echo "----------"
    echo "CPU DATA"
    echo "----------";
    echo "Arch ...: $arch";
    echo "CPUs ...:"$cpu_count;
    echo "Model ..: $model";
    echo "GHz ....: $ghz";
}

gather_cpu
