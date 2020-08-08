#!/bin/bash
#
#********************************************************************
#Author:        ms
#URL:           https://github.com/shawn-ms/hadoop_script
#Date:          2020-08-06
#FileName:      centos_hadoop_install.sh
#Description:   The script for centos to install hive
#********************************************************************
echo 安装hive前，请安装启动hadoop,mysql
sleep 2
cd ~
if [ -f "~/apache-hive-1.2.2-bin.tar.gz" ];then
echo "文件存在，准备解压"
else
wget https://mirrors.aliyun.com/apache/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz
echo "文件下载完毕"
fi
sleep 10
tar -zxvf apache-hive-1.2.2-bin.tar.gz  -C /usr/local
if  [ -d "/usr/local/apache-hive-1.2.2-bin" ];then
  wget https://mirrors.huaweicloud.com/mysql/Downloads/Connector-J/mysql-connector-java-5.1.48.tar.gz
else
  wait
fi
sleep 10;
tar -xvf mysql-connector-java-5.1.48.tar.gz;
sleep 5;
cd /usr/local;
mv apache-hive-1.2.2-bin/ hive;
sleep 2
chown -R hadoop ./hive;
echo "修改环境变量"
sleep 3
echo "export HIVE_HOME=/usr/local/hive" >> /etc/profile;
echo "export HIVE_CONF_DIR=\$HIVE_HOME/conf" >> /etc/profile;
echo "alias cdha='cd /usr/local/hive'">> /etc/profile;
echo "export PATH=.:\$PATH:\$HIVE_HOME/bin" >> /etc/profile;
sleep 2;
source /etc/profile;
sleep 1.5;
cd /usr/local/hive/conf;
cp hive-env.sh.template hive-env.sh;
echo "正在安装hive"
if  [ -f "hive-env.sh" ];then
touch hive-site.xml;
sleep 1.5

echo "<configuration>
  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/user/hive/warehouse</value>
    <description>location of default database for the warehouse</description>
  </property>
  <property>
    <name>hive.exec.scratchdir</name>
    <value>/tmp/hive</value>
  </property>
  <property>
    <name>java.io.tmpdir</name>
    <value>/usr/local/hive/tmp</value>
  </property>
  <property>
    <name>user.name</name>
    <value>root</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
    <description>Driver class name for a JDBC metastore</description>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://localhost:3306/hive?createDatabaseIfNotExist=true&amp;characterEncoding=UTF-8&amp;useSSL=false</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>root</value>
    <description>上面的root为MySQL数据库登录名</description>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>123456</value>
    <description>上面的123456为MySQL数据库密码</description>
  </property>
</configuration>" >> hive-site.xml;

else
  wait;
fi
sleep 1.5
sleep 2
echo "在hdfs中建立/user/hive/warehouse并设置权限"
hadoop fs -mkdir -p /user/hive/warehouse;
hadoop fs -chmod -R 777 /user/hive/warehouse;
# 在hdfs中建立/tmp/hive/并设置权限
hadoop fs -mkdir -p /tmp/hive/;
hadoop fs -chmod -R 777 /tmp/hive;
sleep 10
cd /usr/local/hive;
mkdir tmp;
sleep 2;
chmod -R 777 tmp/;
sleep 5;
cd /usr/local/hive/conf;
if  [ -f  "hive-env.sh" ];then
  echo "export HIVE_AUX_JARS_PATH=/usr/local/hive/lib
export HIVE_CONF_DIR=/usr/local/hive/conf
export HADOOP_HOME=/usr/local/hadoop" >> hive-env.sh;
else
  wait;
fi

sleep 5;
cd ~;
cp mysql-connector-java-5.1.48/mysql-connector-java-5.1.48-bin.jar  /usr/local/hive/lib;
sleep 5
schematool -initSchema -dbType mysql;
echo -e "\033[0;32mHive安装完成,正在启动Hive!\n\033[0m";
sleep 5
hive;

