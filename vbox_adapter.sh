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
        echo -n "${binary}: "
        which ${binary} > /dev/null 2>&1
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

function get_interface_name
{
    # Passes the virtual box interface name to a variable given to this function
    data=$(ifconfig vboxnet | grep mtu);
    iface_name=$(echo $data | grep -oP '.+(?=:)');
    eval="$1='$iface_name'";
    return 0;
}

function create_adapter
{
    echo "[+] Enabling virtual interface to host system ..."
    echo -n "Virtual host-only adapter: ";
    if_n=$(ifconfig vboxnet | grep mtu | wc -l > /dev/null 2>&1)
    if [[ $if_n -gt 0 ]]; then
        echo "OK"
        return 1;
    fi

    echo -n "Creating host-only adapter: "
    vboxmanage hostonlyif create > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "OK";
    else
        echo "FAIL";
    fi
}

function configure_adapter
{
    # Get the interface name
    iface_name=''
    get_interface_name iface_name
    echo -n "Configuring interface $iface_name: "
    vboxmanage hostonlyif ipconfig $iface_name --ip 192.168.56.1 --netmask 255.255.255.0
    if [[ $? != 0 ]]; then
        echo "FAIL";
    else
        echo "OK";
    fi
    return 0
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
configure_adapter
