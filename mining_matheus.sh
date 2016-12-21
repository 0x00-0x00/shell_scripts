#!/bin/bash

RIG_NAME="Matheus - RIG 1"

echo "Ensuring mining process will not run twice ..."
ssh Itslikehim@192.168.1.203 'taskkill /f /im ethminer.exe'

echo "Starting mining operation for $RIG_NAME in 10 seconds ..."
sleep 10


# Send notification to cellphone
push -t "Ethereum" -m "Iniciando mining em $RIG_NAME"

ssh Itslikehim@192.168.1.203 'cd C:\\ && setx GPU_FORCE_64BIT_PTR 0 && setx GPU_MAX_HEAP_SIZE 100 && setx GPU_USE_SYNC_OBJECTS 1 && setx GPU_MAX_ALLOC_PERCENT 100 && setx GPU_SINGLE_ALLOC_PERCENT 100 &&./ethminer --farm-recheck 200 -G -S eu1.ethpool.org:3333 -FS us1.ethpool.org:3333 -O 0xbff6b810563a4fbd6dadc685e5dc13dedc45e85a.rig1'
