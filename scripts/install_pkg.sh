#!/bin/bash

#yum update -y
yum install -y libaio*
yum install -y libncurse*
yum install -y libnsl*
yum install -y python2
yum install -y jq
yum install -y wget
yum install -y gcc
yum install -y gcc-c++
yum install -y gdb*
yum install -y sysstat gdb dstat

curl -o compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
rpm -Uvh compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm

mkdir -p /opt/aws/bin
wget https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
easy_install-2 --script-dir /opt/aws/bin aws-cfn-bootstrap-latest.tar.gz

yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
