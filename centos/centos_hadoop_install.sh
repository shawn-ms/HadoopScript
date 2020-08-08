#!/bin/bash
#
#********************************************************************
#Author:        ms
#URL:           https://github.com/shawn-ms/hadoop_script
#Date:          2020-08-06
#FileName:      centos_hadoop_install.sh
#Description:   The script for centos7 to install hadoop
#********************************************************************

HadoopLink='https://mirrors.aliyun.com/apache/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz'
JdkLink='https://repo.huaweicloud.com/java/jdk/8u191-b12/jdk-8u191-linux-x64.tar.gz'
 
installJDK()        #安装JDK
{
        echo -e "\033[0;34m正在安装jdk...\033[0m"
        sleep 1.5
        cd ~
        ls -l | grep hadoop-2.9.2.tar.gz
        if [ $? -ne 0 ] ; then
                echo -e "\033[0;34m正在下载JDK\033[0m"
                sleep 1.5
                wget echo $JdkLink
                echo -e "\033[0;34m下载完成 正在安装JDK...\033[0m"
                sleep 1.5
        fi
        tar -zxvf jdk-8u191-linux-x64.tar.gz  -C /usr/local
        echo -e "\033[0;32mJDK版本\n \033[0m"
        cd /usr/local/jdk1.8.0_191
        ./bin/java -version
        echo -e "\033[0;32mJDK安装完成!\n \033[0m"
}
 
InstallHadoop()        #安装hadoop
{
        cd ~
        ls -l | grep hadoop-2.9.2.tar.gz
        if [ $? -ne 0 ] ; then
                echo -e "\033[0;34m正在下载Hadoop\033[0m"
                sleep 1.5
                wget echo $HadoopLink
                echo -e "\033[0;34m下载完成 正在安装Hadoop...\033[0m"
                sleep 1.5
        fi
        tar -zxvf hadoop-2.9.2.tar.gz  -C /usr/local
        cd /usr/local
        mv hadoop-2.9.2/ hadoop
        chown -R hadoop ./hadoop
        #配置环境变量
        echo 'export JAVA_HOME=/usr/local/jdk1.8.0_191' >> /etc/profile
        echo "export HADOOP_HOME=/usr/local/hadoop" >> /etc/profile
        echo "alias cdha='cd /usr/local/hadoop'">> /etc/profile
        echo "export PATH=.:\$PATH:\$JAVA_HOME/bin:\$HADOOP_HOME/bin" >> /etc/profile
        sed -ie 's/export JAVA_HOME=${JAVA_HOME}/export JAVA_HOME=\/usr\/local\/jdk1.8.0_191/g' /usr/local/hadoop/etc/hadoop/hadoop-env.sh
        source /etc/profile
        cd /usr/local/hadoop
        ./bin/hadoop version
        echo -e "\033[0;32mHadoop安装完成!\n\033[0m"
        sleep 1.5
}
 
setSSHWithoutCode()        #设置ssh免密登陆
{
        echo -e "\033[0;34m正在设置SSH免密登录...\033[0m"
        sleep 1.5
        rm -rf /var/run/yum.pid 
        yum install openssh-server -y&&yum install openssh-clients -y
        #ssh localhost
        cd ~/.ssh/
        if [ $? -ne 0 ] ; then
                echo -e "\033[0;31m请先执行命令ssh localhost 后重试\033[0m"
                exit 1
        fi
        echo -e "\033[0;34m请按三次回车\033[0m"
        ssh-keygen -t rsa
        cat ./id_rsa.pub >> ./authorized_keys
        #ssh localhost
        echo -e "\033[0;32m免密设置完成! \033[0m"
        sleep 1.5
}
 
creatAccount()        #创建新用户
{
        echo -e "\033[0;34m正在创建hadoop用户...\033[0m"
        sleep 1.5
        userdel -r hadoop
        echo '创建新用户 :hadoop'
        echo '请输入密码 :'
        sudo useradd -m hadoop -s /bin/bash
        sudo passwd hadoop
        echo "hadoop ALL=(ALL)ALL" >>/etc/sudoers
        echo -e "\033[0;32m用户创建完成! \033[0m"
        sleep 1.5
}
 
SetHadoop()        #配置hadoop
{
        echo -e "\033[0;34m正在配置Hadoop...\033[0m"
        sleep 1.5
        echo "# Hadoop Environment Variables
        export HADOOP_HOME=/usr/local/hadoop
        export HADOOP_INSTALL=$HADOOP_HOME
        export HADOOP_MAPRED_HOME=$HADOOP_HOME
        export HADOOP_COMMON_HOME=$HADOOP_HOME
        export HADOOP_HDFS_HOME=$HADOOP_HOME
        export YARN_HOME=$HADOOP_HOME
        export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
        export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin" >> ~/.bashrc
        source ~/.bashrc
         
        cd /usr/local/hadoop/etc/hadoop/
        echo "<configuration>
        <property>
        <name>hadoop.tmp.dir</name>
        <value>file:/usr/local/hadoop/tmp</value>
        <description>Abase for other temporary directories.</description>
        </property>
        <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
        </property>
        </configuration>" > core-site.xml
 
        echo "<configuration>
        <property>
        <name>dfs.replication</name>
        <value>1</value>
        </property>
        <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/usr/local/hadoop/tmp/dfs/name</value>
        </property>
        <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/usr/local/hadoop/tmp/dfs/data</value>
        </property>
        </configuration>" >  hdfs-site.xml
 
        mv mapred-site.xml.template mapred-site.xml
        echo "<configuration>
        <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        </property>
        </configuration>" >mapred-site.xml
 
        echo "<configuration>
        <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
        </property>
        </configuration>" > yarn-site.xml
        cd /usr/local/hadoop/
        echo -e "\033[0;34m正在执行 NameNode 的格式化...\033[0m"
        ./bin/hdfs namenode -format
        echo -e "\033[0;34m正在开启 NaneNode 和 DataNode 守护进程...\033[0m"
        ./sbin/start-dfs.sh        #启动dfs
        echo -e "\033[0;34m正在启动YARN...\033[0m"
        ./sbin/start-yarn.sh                                                                #启动YARN
        ./sbin/mr-jobhistory-daemon.sh start historyserver         #开启历史服务器，才能在Web中查看任务运行情况
        if [ $? -ne 0 ] ; then
                echo -e "\033[0;32mHadoop配置失败 \033[0m"
                exit 2;
        fi
        echo -e "\033[0;32mHadoop配置并启动成功 请至http://localhost:50070和http://localhost:8088/cluster查看\033[0m"
        sleep 1.5
        jps
}
 
StartHadoop()
{
        cd /usr/local/hadoop/
        echo -e "\033[0;34m正在开启 NaneNode 和 DataNode 守护进程...\033[0m"
        ./sbin/start-dfs.sh        #启动dfs
        echo -e "\033[0;34m正在启动YARN...\033[0m"
        ./sbin/start-yarn.sh                                                                #启动YARN
        ./sbin/mr-jobhistory-daemon.sh start historyserver         # 开启历史服务器，才能在Web中查看任务运行情况
}
 
StopHadoop()
{
        echo -e "\033[0;34m正在关闭Hadoop...\033[0m"
        cd /usr/local/hadoop/
        ./sbin/stop-dfs.sh
        ./sbin/stop-yarn.sh
        ./sbin/mr-jobhistory-daemon.sh stop historyserver
}
 
RestartHadoop()
{
        echo -e "\033[0;34m正在重启Hadoop...\033[0m"
        cd /usr/local/hadoop/
        ./sbin/stop-dfs.sh
        ./sbin/stop-yarn.sh
        ./sbin/mr-jobhistory-daemon.sh stop historyserver
 
        echo -e "\033[0;34m正在开启 NaneNode 和 DataNode 守护进程...\033[0m"
        ./sbin/start-dfs.sh        #启动dfs
        echo -e "\033[0;34m正在启动YARN...\033[0m"
        ./sbin/start-yarn.sh        #启动YARN
        ./sbin/mr-jobhistory-daemon.sh start historyserver # 开启历史服务器，才能在Web中查看任务运行情况
 
}
MyMain()
{
        echo "请选择功能"
        echo "1. 一健安装Hadoop(请先执行2)"
        echo "2. 执行ssh localhost"
        echo "3. 启动Hadoop"
        echo "4. 关闭Hadoop"
        echo "5. 重启Hadoop"
        echo "q. 退出本脚本"
        read a
        case $a in
                1) creatAccount                        #创建新用户
                   setSSHWithoutCode        #设置ssh免密登录
                   installJDK  
                   InstallHadoop                #安装hadoop
                   SetHadoop;;                        #配置hadoop
                2) ssh localhost
                   exit;;
                3) StartHadoop;;
                    
                4) StopHadoop;;
                5) RestartHadoop;;
                 
                q) exit 0;;
                *) echo -e "\033[0;31m没有此选项\033[0m";;
         
        esac
}
MyMain