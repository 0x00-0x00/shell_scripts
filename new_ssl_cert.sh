#!/bin/bash

keyfile=key.pem
certfile=cert.pem
days=365

openssl req -x509 -newkey rsa:2048 -keyout $keyfile -out $certfile -days $days

