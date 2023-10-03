#!/bin/bash

USER_PARAM=$2
source $USER_PARAM

cat << EOF >> /etc/sysctl.conf
#-----------
# TIBERO ENV
#-----------
kernel.shmall = $SHMALL
kernel.shmmax = $SHMMAX
kernel.shmmni = 4096
kernel.sem = 10000 32000 10000 10000
fs.file-max = 67108864
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 1024 65500
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.ipv4.tcp_rmem = 4194304
net.ipv4.tcp_wmem = 1048576
EOF

sysctl -p /etc/sysctl.conf

sed -i '/# End of file/d' /etc/security/limits.conf
cat << EOF >> /etc/security/limits.conf
#-----------
# TIBERO ENV
#-----------
$1  soft   nofile  65536
$1  hard   nofile  65536
$1  soft  nproc   2047
$1  hard  nproc   16384
EOF

sed -i 's/#RemoveIPC=no/RemoveIPC=no/g' /etc/systemd/logind.conf
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
