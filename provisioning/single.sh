#!/bin/bash
set -e

apt-get update
apt-get install -y wget curl gcc libev4 libev-dev python-dev

echo "Installing repos"
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl -L https://debian.datastax.com/debian/repo_key | apt-key add -

echo "Installing binaries"
apt-get update
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install -y oracle-java8-installer
sudo apt-get install -y dsc30 -V
sudo apt-get install -y cassandra-tools

sudo service cassandra start
echo "Complete"
