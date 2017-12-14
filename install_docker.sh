#!/bin/bash
# Install docker to kali linux 2017.1
if [[ $(id -u) != 0 ]]; then
    echo "Only root man :)"
    exit 0
fi
chk() {
    if [[ $? != 0 ]]; then
        echo "Something gone wrong!"
        exit 1;
    fi
}
apt-get update -y
apt get install -y apt-transport-https ca-certificates dirmngr
chk
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
chk
echo 'deb https://apt.dockerproject.org/repo debian-stretch main' > /etc/apt/sources.list.d/docker.list
chk
apt-get update -y
apt-get install docker-engine
chk
echo "Docker should be installed by now."
sleep 10
service docker start
chk
echo "Docker is installed."
