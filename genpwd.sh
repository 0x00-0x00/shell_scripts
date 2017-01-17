#!/bin/bash

if [ "$1" == "" ]; then 
    echo "[!] Not enought arguments."
    exit
fi

openssl rand -base64 32 | tr -d /=+ | cut -c -${1}
