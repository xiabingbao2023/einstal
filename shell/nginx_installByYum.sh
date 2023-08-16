#!/bin/bash

# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi

# 检查是否已经安装 Nginx
if command -v nginx &>/dev/null; then
    echo "Nginx 已经安装，无需重复安装。"
    exit 0
fi

# 安装 EPEL 软件源
yum install epel-release -y

# 替换 EPEL 镜像源为清华大学的镜像源
sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!https\?://download\.fedoraproject\.org/pub/epel!https://mirrors.tuna.tsinghua.edu.cn/epel!g' \
    -e 's!https\?://download\.example/pub/epel!https://mirrors.tuna.tsinghua.edu.cn/epel!g' \
    -i /etc/yum.repos.d/epel*.repo

# 更新系统软件包列表
yum update -y

# 安装 Nginx
yum install nginx -y

# 启动 Nginx
systemctl start nginx

# 配置 Nginx 开机启动
systemctl enable nginx

# 显示 Nginx 服务状态
systemctl status nginx

echo "Nginx 安装完成。"
