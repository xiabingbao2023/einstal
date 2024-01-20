#!/bin/bash

# 检查是否安装wget和gcc，如果不存在则安装
if ! command -v wget &> /dev/null; then
    echo "正在安装 wget..."
    yum install -y wget
fi

if ! command -v gcc &> /dev/null; then
    echo "正在安装 gcc..."
    yum install -y gcc
fi

# 下载Redis源码
echo "正在下载Redis源码..."
wget https://download.redis.io/releases/redis-6.2.14.tar.gz

# 解压
echo "正在解压..."
tar -zxvf redis-6.2.14.tar.gz

# 进入目录
cd redis-6.2.14

# 编译
echo "正在编译..."
make MALLOC=libc

# 安装
echo "正在安装..."
make install

# 创建配置文件存放目录
echo "正在创建配置文件目录..."
mkdir -p /etc/redis

# 复制配置文件
echo "正在复制配置文件..."
cp redis.conf /etc/redis/6379.conf

# 修改配置文件让Redis变为后台启动
echo "正在修改配置文件..."
sudo sed -i 's/^daemonize no$/daemonize yes/' /etc/redis/6379.conf

# 复制启动脚本
echo "正在复制启动脚本..."
cp utils/redis_init_script /etc/init.d/redis

# 制作成服务
echo "
[Unit]
Description=Redis 服务器
After=network.target
After=syslog.target
[Service]
Type=forking
PermissionsStartOnly=true
ExecStart= /etc/init.d/redis start
ExecStop= /etc/init.d/redis stop
ExecReload= /etc/init.d/redis restart
[Install]
WantedBy=multi-user.target
" | sudo tee -a /usr/lib/systemd/system/redis.service

# 启动服务
echo "正在启动Redis服务..."
systemctl start redis

# 检测服务是否启动成功
if systemctl is-active --quiet redis; then
    echo "安装成功！Redis服务已成功启动。"
else
    echo "安装失败，请手动排查。"
fi

# 开机自动启动
echo "正在设置开机自动启动..."
systemctl enable redis
