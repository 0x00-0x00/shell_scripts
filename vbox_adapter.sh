#!/bin/bash
# -----------------------
# Host-Only Adapter enabling script for VirtualBox in linux machines.
# -----------------------

uid=$(id -u)
kernel_modules=("vboxdrv" "vboxnetadp" "vboxnetflt" "vboxpci")

if [[ $uid != 0 ]]; then
    echo "[!] Error: Not enough privileges to run this script.";
    exit;
fi

function check_binaries
{
    echo "[+] Checking system binaries ..."
    binaries=("modprobe" "vboxmanage")
    for binary in "${binaries[@]}"
    do
        echo "${binary}: "
        which ${binary}
        if [[ $? != 0 ]]; then
            echo "FAIL"
        else
            echo "OK"
        fi
    done
    echo ""
}

function probe_modules
{
    echo "[+] Probing kernel modules ...";
    for module in "${kernel_modules[@]}";
    do
        echo -n "${module}: ";
        modprobe -a ${module};
        if [[ $? == 0 ]]; then
            echo "OK";
        else
            echo "FAIL";
        fi
    done
    echo ""
}

function create_adapter
{
    echo -n "Creating host-only adapter: "
    vboxmanage hostonlyif create > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "OK";
    else
        echo "FAIL";
    fi
}

function enable_dhcp_server
{
    echo -n "Enabling DHCP server: "
    vboxmanage dhcpserver > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "OK";
    else
        echo "FAIL";
    fi
}

check_binaries
probe_modules
create_adapter
enable_dhcp_server
