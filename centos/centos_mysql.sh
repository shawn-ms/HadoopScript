#!/bin/bash
#
#********************************************************************
#Author:        ms
#URL:           https://github.com/shawn-ms/hadoop_script
#Date:          2020-08-06
#FileName:      centos_mysql.sh
#Description:   The script for centos to install mysql5.7
#********************************************************************
cd ~

# 脚本中需要生成密码，这里使用的是 mkpasswd
yum install -y expect

# 下载MySQL的repository
wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm

# 安装MySQL源
yum -y install mysql57-community-release-el7-10.noarch.rpm

# 通过yum安装MySQL
yum -y install mysql-community-server

# 启动MySQL
systemctl start  mysqld.service
# 查看其状态
systemctl status mysqld.service
# mysql8 和 mysql5.7一样安装并启动生成的密码在  /var/log/mysqld.log 中
MYSQL_PASSWD=`cat /var/log/mysqld.log | grep password | head -1 | rev  | cut -d ' ' -f 1 | rev`

# 生成新的密码, 并删除密码中的双引号和单引号
NEW_PASSWORD='123456'

# mysql的安全策略不能通过命令行加密码的方式，执行命令。可以把用户名和密码写在配置文件中。
# mysql: [Warning] Using a password on the command line interface can be insecure.
cat > ~/.my.cnf <<EOT
[mysql]
user=root
password="$MYSQL_PASSWD"
EOT

# mysql安全策略 交换模式下，使用  --connect-expired-password 这个选项
# Please use --connect-expired-password option or invoke mysql in interactive mode.


mysql  --connect-expired-password  -e "set global validate_password_policy=0;"
mysql  --connect-expired-password  -e "set global validate_password_length=1;"
mysql  --connect-expired-password  -e "alter user 'root'@'localhost' identified by '$NEW_PASSWORD';"
cat > ~/.my.cnf <<EOT
[mysql]
user=root
password="$NEW_PASSWORD"
EOT
mysql  --connect-expired-password  -e "use mysql;"
mysql  --connect-expired-password  -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$NEW_PASSWORD' WITH GRANT OPTION;"
mysql  --connect-expired-password  -e "flush privileges;"

echo "mysql密码123456"
