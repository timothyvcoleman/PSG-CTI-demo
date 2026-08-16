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

# download zoiper for voice calls


# creating pjsip endpoint in asterisk
sudo mv /etc/asterisk/pjsip.conf /etc/asterisk/pjsip.conf.bak

cd /etc/asterisk

cat << 'EOF' | sudo tee -a /etc/asterisk/pjsip.conf > /dev/null
[global]
type=global
endpoint_identifier_order=ip,username,anonymous

[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0:5060

[trunk-sip]
type=endpoint
context-from-siptrunk
disallow=all
allow=ulaw
aors=trunk-sip-aor
from_user=1010
outbound_auth=trunk-sip
direct_media=no

[trunk-sip-aor]
type=aor
contact=

[trunk-sip-auth]
type=auth
auth_type=userpass
password=psg
username=1010

[trunk-identity]
type=identity
match=[make-an-external-server]
endpoint=trunk-sip

[registration-sip]
type=registration
outbound_auth=trunk-sip-auth
server_uri=sip:[make-an-external-server]:5060
auth_rejection_permanent=no
client_uri=sip:1010@[make-an-external-server]:5060
retry_interval=60
contact_user=9999

[e1]
type=endpoint
context=from-internal
disallow=all
allow=ulaw
auth=e1
aors=e1
force_rport=yes
rtp_symmetric=yes
rewrite_contact=yes
direct_media=no

[e1]
type=auth
auth_type=userpass
password=psg1
username=psg1

[e1]
type=aor
max_contact=1

[e2]
type=endpoint
context=from-internal
disallow=all
allow=ulaw
auth=e1
aors=e1
force_rport=yes
rtp_symmetric=yes
rewrite_contact=yes
direct_media=no

[e2]
type=auth
auth_type=userpass
password=psg2
username=psg2

[e2]
type=aor
max_contact=1
EOF

sudo asterisk -r
core restart now

# to verify the endpoint was created
# sudo asterisk -r
# pjsip show endpoints