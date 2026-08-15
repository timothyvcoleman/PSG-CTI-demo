#!/bin/bash

sudo apt-get update

# downloads C Compiler, needed for Asterisk
sudo apt-get install -y build-essential

# downloads pjproject 2.17: provides Asterisk's SIP stack
cd /usr/local/src
wget -qO- https://github.com/pjsip/pjproject/archive/refs/tags/2.17.tar.gz | sudo tar -xz

cd ./pjproject-2.17
sudo ./configure --enable-shared --prefix=/usr --libdir=/usr/lib64

sudo make dep
sudo make
sudo make install
sudo ldconfig

# downloads dahdi-linux-complete 3.4.0
cd /usr/local/src
wget -qO- https://github.com/asterisk/dahdi-linux-complete/releases/download/v3.4.0/dahdi-linux-complete-3.4.0+3.4.0.tar.gz | sudo tar -xz
cd ./dahdi-linux-complete-3.4.0+3.4.0

sudo make
sudo make install
sudo make install-config

# downloads libpri 1.6.1
cd /usr/local/src
wget -qO- https://github.com/asterisk/libpri/releases/download/1.6.1/libpri-1.6.1.tar.gz | sudo tar -xz
cd ./libpri-1.6.1

sudo make
sudo make install

# downloads Asterisk 22.10.1
cd /usr/local/src
wget -qO- https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-22.10.1.tar.gz | tar -xz

cd ./asterisk-22.10.1
sudo ./contrib/scripts/install_prereq install
sudo ./configure

sudo make
sudo make install
sudo make samples
sudo make config
sudo make install-logrotate

# start service
sudo service asterisk start

# give it about 5 minutes to finish loading all the files

# use this to check the progress
# cat /var/log/cloud-init-output.log