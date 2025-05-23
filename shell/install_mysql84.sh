#!/bin/bash
# 通过tar包在ubuntu上安装mysql8.4
#安装libaio1的依赖
sudo apt-get install libaio1
#创建用户组
sudo groupadd mysql
#创建用户
sudo useradd -r -g mysql -s /bin/false mysql
#解压mysql
xz -d mysql-8.4.5-linux-glibc2.28-x86_64.tar.xz
sudo tar -xvf mysql-8.4.5-linux-glibc2.28-x86_64.tar -C /usr/local/
#创建软链接
sudo ln -sf /usr/local/mysql-8.4.5-linux-glibc2.28-x86_64 /usr/local/mysql
#创建数据目录
sudo mkdir -p /data/mysql-data
#修改目录权限
sudo chown mysql:mysql /data/mysql-data/
sudo chmod 750 /data/mysql-data/
#初始化数据库
sudo /usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/data/mysql-data/