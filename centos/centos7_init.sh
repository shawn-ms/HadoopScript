#!/bin/bash
#
#********************************************************************
#Author:        ms
#URL:           https://github.com/shawn-ms/hadoop_script
#Date:          2020-08-06
#FileName:      centos7_init.sh
#Description:   The script for centos7 reset
#********************************************************************


#检查脚本运行用户是否为root
if [ $(id -u) !=0 ];then
	echo -e "\033[1;31m Error! You must be root to run this script! \033[0m"
	exit 10
fi

#禁用selinux
sed -ri 's/^(SELINUX=)enforcing/\1disabled/'  /etc/selinux/config

#禁用防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service

#优化ssh登录
sed -ri 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -ri 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

#禁用不需要的服务
systemctl stop postfix.service
systemctl disable postfix.service
yum install wget
#配置系统使用阿里云yum源和EPEL源
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
wget -P /etc/yum.repos.d http://mirrors.aliyun.com/repo/Centos-7.repo
wget -P /etc/yum.repos.d http://mirrors.aliyun.com/repo/epel-7.repo
yum make clean all
yum makecache

#安装wget工具
yum -y install wget
#安装vim工具
yum -y install vim
#设置系统默认编辑器为vim
echo export EDITOR=vim >> /etc/profile.d/env.sh
#安装bash命令tab自动补全组件
yum -y install bash-completion
#安装vim编辑器
yum -y install vim screen lrzsz tree psmisc
#安装压缩解压工具
yum -y install zip unzip bzip2 gdisk
#安装网络及性能监控工具
yum -y install telnet net-tools sysstat iftop lsof iotop htop dstat
#安装源码编译工具及开发组件
yum -y install cmake gcc gcc-c++ zib zlib-devel open openssl-devel pcre pcre-devel curl

#安装chrony时间同步服务
yum -y install chrony
systemctl enable chronyd.service
systemctl start chronyd.service

#配置chrony时间同步阿里云ntp服务器
sed -i -e '/^server/s/^/#/'  -e '1a server ntp.aliyun.com iburst' /etc/chrony.conf
systemctl restart chronyd.service

#初始化完成重启系统
echo -e "\033[1;32m System initialization is complete and will be reboot in 10s...\033[0m"
