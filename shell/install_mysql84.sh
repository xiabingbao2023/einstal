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
#复制配置文件到etc目录下
sudo cp my.cnf /etc/
#初始化数据库
sudo /usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --datadir=/data/mysql-data/
#创建服务
#复制服务到系统服务目录下
sudo cp mysqld.service /lib/systemd/system/
#启动服务
sudo systemctl daemon-reload
sudo systemctl start mysqld
# 将MySQL Bin目录添加到PATH
#配置环境变量还存在些问题
echo "正在配置环境变量..."
sudo -u root echo "export PATH=\$PATH:/usr/local/mysql/bin/" >> /etc/profile
source /etc/profile
#允许远程登录
mysql -uroot -pmysql12#$ -e "use mysql; update user set user.Host='%' where user.User='root'; flush privileges;"
#修改密码
mysql -uroot  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysql12#$';"