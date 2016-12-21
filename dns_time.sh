#!/bin/bash

echo "Type a hostname to query: "
read HOST

echo "Type a DNS server IP to use: "
read DNS_SERVER

time( for i in "sed 1 1000"; do dig $HOSTm @$DNS_SERVER > /dev/null 2>>/dev/null; done)
