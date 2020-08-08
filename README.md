<h2>hadoop及生态圈组件运维安装脚本（Hadoop operation and maintenance installation script）</h2>

>脚本主要用于方便学习，从不断配置环境中解脱出来,
版本为hadoop2最后一个版本，可自行修改脚本调整

版本信息为：

hadoop 2.9.2

hive 1.2.2(使用MapReduce引擎)

mysql 5.7.6

jdbc 5.1.48

<h3>centos<h3>
  
>切换为root用户
  
  ```shell
  su root
  ```

>(可选)centos7初始化脚本，centos其他版本可将脚本内换源地址修改为想用版本号

  主要为yum换源及基础工具安装
  
```shell
cd ~
curl -O https://cdn.jsdelivr.net/gh/shawn-ms/HadoopScript/centos/centos7_init.sh
chmod 766 centos7_init.sh
./centos7_init.sh
```
>安装hadoop

```shell
cd ~
curl -O https://cdn.jsdelivr.net/gh/shawn-ms/HadoopScript/centos/centos_hadoop_install.sh
chmod 766 centos_hadoop_install.sh
./centos_hadoop_install.sh
```
![](https://cdn.jsdelivr.net/gh/shawn-ms/HadoopScript/centos/hadoop.JPG)

<u>执行1.安装hadoop前要先执行2 ssh localhost</u>
>安装mysql

```shell
cd ~
curl -O https://cdn.jsdelivr.net/gh/shawn-ms/HadoopScript/centos/centos_mysql.sh
chmod 766 centos_mysql.sh
./centos_mysql.sh
```

>安装hive

```shell
cd ~
curl -O https://cdn.jsdelivr.net/gh/shawn-ms/HadoopScript/centos/hive.sh
chmod 766 hive.sh
./hive.sh
```
