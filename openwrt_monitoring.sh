#!/bin/ash

max_size=6600000
villain_host="cloudshark.org"
opt=8;  # IMPORTANT VALUE -- Amount of time to capture data
rdns_time=""

echo "Digite o ID do simple push: ";
read push_id



delete_all() {
    rm /tmp/cshark*
    return 0;
}

dns_time() {
    t=$(time ping $villain_host -c 1 2>&1 | grep real | awk {'print $3'} | grep -oE "[0-9]+" | head -n1);
    echo $t;

}

notify() {
    if [[ $1 != "" ]] && [[ $2 != "" ]]; then
        echo "[*] Trying to send notification to owner ..."
        ssh shemhazai@192.168.0.123 "push -i $push_id -t \"$1\" -m \"$2\""
    else
        echo "[!] notify() error: no arguments";
    fi
}

measure_dns_resolve_time() {
    echo "[+] Measuring DNS resolve time to host $villain_host ..."
    rdns_time=$(dns_time);
    echo "[*] Resolve time took $rdns_time seconds."
    return;

}

start() {
    while [ 1 -eq 1 ]; do
        measure_dns_resolve_time;
        x=0;
        while [ $x -lt 4 ]; do
            x=$((x+1))
            delete_all
            echo "[!] Commencing traffic capture ..."
            complete=0;
            capture_time=0;
            cshark -k -S $max_size 1>> cshark.stdout &
            pid=$!
            echo "[*] CShark is running on PID $pid"
            while [[ $complete -eq 0 ]]; do
                sleep 1;
                size=$(wc -c cshark.pcap* 2>/dev/null | awk {'print $1'})
                if [[ $size == "" ]]; then
                    sleep 1;
                fi
                if [[ $size -gt $max_size ]]; then
                    kill -9 $pid
                    if [[ $? == 0 ]]; then
                        echo "[*] INTERRUPT signal sent to PID $pid"
                    else
                        echo "[!] INTERRUPT signal error"
                        notify "Monitoring script" "Error on interrupt"
                    fi
                    echo -e "Capture time: $capture_time seconds"
                    break;
                fi
                echo -n -e "Capture time: $capture_time seconds\r"
                #sleep 1
                capture_time=$((capture_time+1))
            done
            out_file=$(ls /tmp | grep -oE "cshark\.pcap\-[a-zA-Z0-9]+");
            echo "[*] Output file: $out_file"

            # Transference
            log_file=$(date +%Y-%m-%d_%H%M%S);

            echo "[*] Sending file $out_file as $log_file to remote server ..."
            scp $out_file shemhazai@192.168.0.123:/media/watchers/Backup/Traffic/$log_file.pcap
            if [[ $? == 0 ]]; then
                echo "[*] Remote upload complete."
            else
                echo "[!] Remote upload failure."
                notify "Monitoring script" "Error on transference"
            fi
            #return 0;
        done
    done
}

start
