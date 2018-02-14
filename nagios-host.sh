#!/bin/bash
# zc00l install script for Nagios Hosts.

NAGIOS_PLUGIN_URL="http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz"
NRPE_PLUGIN="https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz"

if  [[ $(which curl) == "" ]]; then
	echo "[+] CURL is needed for this script to work.";
	exit 1;
fi

if [[ $(which tar) == "" ]]; then
	echo '[+] TAR is needed for this script to work.";
	exit 1;
fi

if [[ $(id -u) != "0" ]]; then
	echo "[+] Only root can install nagios host plugins.";
	exit 1;
fi

user=$(cat /etc/passwd | grep -i nagios | wc -l);
if [[ $user -eq 0 ]]; then
	echo "[!] No user nagios was found.";
	useradd nagios
fi

# Update the sytem
echo '[+] Updating the system ...";
apt-get update -y 2>&1 > /dev/null

# Install the necessary packages
echo '[+] Installing apt-get packages ...";
apt-get install build-essential libgd2-xpm-dev openssl libssl-dev unzip

# Let's install all this stuff to the /root
cd /root

if [[ ! -d /root/nagios ]]; then
	mkdir /root/nagios;
fi

if [[ $? -eq 0 ]]; then
	cd /root/nagios;
fi

# Download the plugin file
curl -L -O $NAGIOS_PLUGIN_URL

# Uncompress it
tar zxf nagios-plugins-*.tar.gz

# Enter the folder
cd nagios-plugins-*;

# Configure it so we can build.
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl


# If the configure was succesfull, let's compile it and install it.
if [[ $? -eq 0 ]]; then
	make
	make install
else
	echo '[+] configure error.';
	exit 1;
fi

cd ../

# Download the NRPE plugin
curl -L -O $NRPE_PLUGIN

# Uncompress it
tar zxf nrpe-*.tar.gz

# Enter the folder
cd nrpe-*

# Now let's configure.
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu

if [[ $? -eq 0 ]]; then
	make all
	make install
	make install-config
	make install-init
else
	echo '[+] configure failed.';
	exit 1;
fi

echo '[!] Now edit /usr/local/nagios/etc/nrpe.cfg and add the Nagios Deamon to allowed_hosts directive.';


exit 0;
