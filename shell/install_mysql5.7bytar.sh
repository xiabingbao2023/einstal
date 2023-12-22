#!/bin/bash

# 检测是否存在MariaDB
if rpm -qa | grep mariadb* &> /dev/null; then
    echo "错误：检测到系统中已安装MariaDB。请确保两者不会冲突。"
    exit 1
fi

# 检测是否存在MySQL
if rpm rpm -qa | grep mysql* &> /dev/null; then
    echo "错误：检测到系统中已安装MySQL。请确保两者不会冲突。"
    exit 1
fi

MYSQL_TAR="mysql-5.7.44-linux-glibc2.12-x86_64.tar.gz"
MYSQL_DIR="mysql-5.7.44-linux-glibc2.12-x86_64"

# 检查wget是否已安装
if ! command -v wget &> /dev/null; then
    echo "错误：未安装wget，请在运行此脚本之前手动安装wget。"
    exit 1
fi

# 检测本地是否已有压缩包
if [ -e "$MYSQL_TAR" ]; then
    echo "本地已存在MySQL压缩包，将跳过下载步骤。"
else
    # 下载MySQL
    echo "正在下载MySQL..."
    wget https://cdn.mysql.com//Downloads/MySQL-5.7/$MYSQL_TAR
fi

# 解压MySQL
echo "正在解压MySQL..."
tar -zxvf $MYSQL_TAR

# 移动文件到安装目录
mkdir -p /usr/local/mysql57
mv ./$MYSQL_DIR/* /usr/local/mysql57/
rm -rf ./$MYSQL_DIR

# 创建目录并设置权限
echo "正在创建目录并设置权限..."
mkdir -p /var/lib/mysql57data
useradd -r -m -s /bin/false mysql
chown -R mysql:mysql /usr/local/mysql57/
chown -R mysql:mysql /var/lib/mysql57data/

# 创建MySQL配置文件
echo "正在创建MySQL配置文件..."
echo "[mysqld]
basedir=/usr/local/mysql57
datadir=/var/lib/mysql57data
socket=/usr/local/mysql57/mysql.sock
user=mysql
character-set-server=utf8
default-storage-engine=INNODB
log-error=/var/log/mysql/error.log
slow-query-log=1
slow-query-log-file=/var/log/mysql/slow-query.log
long_query_time=1

[client]
socket=/usr/local/mysql57/mysql.sock
default-character-set=utf8" | sudo tee -a /etc/my.cnf

# 创建日志目录并设置权限
echo "正在创建日志目录并设置权限..."
mkdir -p /var/log/mysql/
chown -R mysql:mysql /var/log/mysql/

# 初始化MySQL
echo "正在初始化MySQL..."
sudo /usr/local/mysql57/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql57 --datadir=/var/lib/mysql57data

# 启动MySQL服务器
echo "正在启动MySQL服务器..."
/usr/local/mysql57/support-files/mysql.server start

# 复制MySQL服务器到系统服务
echo "正在复制MySQL服务器到系统服务..."
cp /usr/local/mysql57/support-files/mysql.server /etc/init.d/mysqld

# 将MySQL Bin目录添加到PATH
echo "正在配置环境变量..."
echo "export PATH=\$PATH:/usr/local/mysql57/bin/" >> /etc/profile
source /etc/profile

# 查看临时密码并保存到临时文件
temp_password=$(grep 'temporary password' /var/log/mysql/error.log | awk '{print $NF}')
echo "临时密码：$temp_password" > /tmp/mysql_temp_password

# 使用临时密码登录MySQL并更改密码
echo "正在使用临时密码登录MySQL并更改密码..."
mysql --connect-expired-password -uroot -p"$temp_password" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';"

# 允许远程登录
echo "正在允许远程登录..."
mysql -uroot -proot -e "use mysql; update user set user.Host='%' where user.User='root'; flush privileges;"

# 停止先前的MySQL服务
echo "正在停止先前的MySQL服务..."
service mysqld stop

# 创建systemd服务文件
echo "正在创建systemd服务文件..."
echo "[Unit]
Description=MySQL Server
After=network.target
After=syslog.target
[Service]
User=mysql
Group=mysql
Type=forking
PermissionsStartOnly=true
ExecStart= /etc/init.d/mysqld start
ExecStop= /etc/init.d/mysqld stop
ExecReload= /etc/init.d/mysqld restart
LimitNOFILE = 5000
[Install]
WantedBy=multi-user.target" | sudo tee -a /usr/lib/systemd/system/mysqld.service

# 启动服务
echo "正在启动服务..."
systemctl start mysqld

# 查看服务状态
echo "正在查看服务状态..."
status=$(systemctl status mysqld)
echo "$status"

# 检查服务状态是否包含 "active (running)"
if [[ "$status" == *"active (running)"* ]]; then
    echo "MySQL安装成功！"
    # 删除本地的MySQL压缩包
    rm -f $MYSQL_TAR
else
    echo "MySQL安装可能出现问题，请检查日志文件和输出信息。"
fi

