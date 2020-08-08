#!/bin/bash
#
#********************************************************************
#Author:        ms
#URL:           https://github.com/shawn-ms/hadoop_script
#Date:          2020-08-06
#FileName:      ubuntu_init.sh
#Description:   The script for ubuntu reset
#********************************************************************
#设置root密码

su root
#换源

cp /etc/apt/sources.list /etc/apt/sourses.list.backup
 
sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list 
sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

#关闭防火墙
ufw disable
ufw status

apt-get update
apt-get install -y vim
apt-get install -y synaptic
apt-get install -y libgtk2.0-0:i386
apt-get install -y sysv-rc-config
apt-get install -y plasma-nm
apt-get install -y vsftpd
apt-get install -y bash-completion
apt-get install -y wget
apt-get install -y cmake gcc gcc-c++ zib zlib-devel open openssl-devel pcre pcre-devel curl
##ssh
apt-get install -y openssh-server
sed -i "s/prohibit-password/yes/g" /etc/ssh/sshd_config 
service ssh restart
