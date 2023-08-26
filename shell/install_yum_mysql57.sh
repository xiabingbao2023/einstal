#!/bin/bash

# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi

# 添加 MySQL 的官方 yum 源
cat <<EOF > /etc/yum.repos.d/mysql57.repo
[mysql-connectors-community]
name=MySQL Connectors Community
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-connectors-community-el7-$basearch/
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql

[mysql-tools-community]
name=MySQL Tools Community
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-tools-community-el7-$basearch/
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql

[mysql-5.7-community]
name=MySQL 5.7 Community Server
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-$basearch/
enabled=1
gpgcheck=1
gpgkey=https://repo.mysql.com/RPM-GPG-KEY-mysql
EOF

# 安装 MySQL 5.7
yum install mysql-community-server -y

# 启动 MySQL 服务
systemctl start mysqld

# 配置 MySQL 开机启动
systemctl enable mysqld

# 获取临时 root 密码
temp_password=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# 设置默认 root 密码为 root!@34
mysql_secure_installation <<EOF

y
${temp_password}
root!@34
root!@34
y
y
y
y
EOF

echo "MySQL 5.7 安装完成，并已设置默认 root 用户的密码为 root!@34"
