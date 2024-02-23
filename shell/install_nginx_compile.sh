#!/bin/bash
#预先准备编译环境
yum update 

yum -y install gcc pcre pcre-devel zlib zlib-devel openssl openssl-devel
#添加用户和组
groupadd www 

useradd -g www www
#下载
wget https://nginx.org/download/nginx-1.24.0.tar.gz
#解压并进入nginx目录
tar -xvf nginx-1.24.0.tar.gz
cd nginx-1.24.0
#配置
./configure \ --user=www \ --group=www \ --prefix=/usr/local/nginx \ --with-http_ssl_module \ --with-http_stub_status_module \ --with-http_realip_module \ --with-threads
#编译
make
#安装
make install
#验证安装是否成功
/usr/local/nginx/sbin/nginx -V
