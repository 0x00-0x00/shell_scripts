#!/bin/bash
uid=$(id -u);

if [[ $uid != 0 ]]; then
    echo "[!] Error: You are not root to create a self-signed certificate.";
    exit;
fi

if [[ $1 == "" ]]; then
    echo "Usage: $0 <CERT_PATH>";
    exit;
fi

function create_cert
{
    echo -n "[*] Creating new certificate: ";
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $1.key -out $1.crt;
    if [[ $? != 0 ]]; then
        echo "FAIL";
    else
        echo "OK";
    fi
    return 0;
}

create_cert $1;
