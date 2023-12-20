#!/bin/bash

# 下载 MySQL 压缩包
MYSQL_VERSION="mysql-5.7.44-linux-glibc2.12-x86_64"
MYSQL_DOWNLOAD_URL="https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.44-linux-glibc2.12-x86_64.tar.gz"

wget $MYSQL_DOWNLOAD_URL -O $MYSQL_VERSION

# 解压缩
tar -zxvf $MYSQL_VERSION.tar.gz

# 移动到目标目录（可以根据实际情况修改）
MYSQL_INSTALL_DIR="/usr/local/mysql"
sudo mv $MYSQL_VERSION $MYSQL_INSTALL_DIR

# 创建 MySQL 数据存储目录
MYSQL_DATA_DIR="/var/lib/mysql"
sudo mkdir -p $MYSQL_DATA_DIR
sudo chown -R mysql:mysql $MYSQL_DATA_DIR

# 初始化 MySQL 数据库
sudo $MYSQL_INSTALL_DIR/bin/mysqld --initialize-insecure --user=mysql --basedir=$MYSQL_INSTALL_DIR --datadir=$MYSQL_DATA_DIR

# 启动 MySQL 服务
sudo $MYSQL_INSTALL_DIR/support-files/mysql.server start

# 设置 MySQL root 用户密码
MYSQL_ROOT_PASSWORD="your_password"
sudo $MYSQL_INSTALL_DIR/bin/mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"

echo "MySQL 5.7 安装完成，root 用户密码为: $MYSQL_ROOT_PASSWORD"
