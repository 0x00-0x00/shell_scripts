#!/bin/bash

PROGRAM_DIR=/opt

function check_root
{
if [ "$1" != "0" ]; then
	echo "Lack of privilege error."
	exit
fi
}

function delete_folder
{
if [ -d "$1" ]; then
	rm -r $1
fi
}

# Check if root
check_root $(id -u)

delete_folder /tmp/tg

# Clone the repo
cd /tmp
git clone --recursive https://github.com/0x00-0x00/tg.git
cd tg/
# Install dependencies
apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev libjansson-dev libpython-dev make
./configure
make 

echo "[+] Moving telegram-cli folder to $PROGRAM_DIR ..."
mv /tmp/tg $PROGRAM_DIR

echo "[+] Creating binary shortcut to /usr/local/bin ..."
ln -s $PROGRAM_DIR/tg/bin/telegram-cli /usr/local/bin/telegram-cli

echo "[+] Done. You can use telegram-cli now."
