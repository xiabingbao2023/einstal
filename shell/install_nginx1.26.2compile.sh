#!/bin/bash
#通过yum安装一些依赖
echo "正在通过yum安装编译环境"
yum install gcc make cmake gcc-c++ libtool openssh openssh-devel -y -q
mkdir -p /opt/source/nginx
cd /opt/source/nginx
echo "正在下载openssl源代码"
wget https://ctcc1-node.bt.cn/src/openssl-1.1.1q.tar.gz 2>&1 | grep '%'
if [ $? -ne 0 ]; then
    echo "下载openssl源代码失败，请检查网络环境"
    exit 1
fi
echo "正在下载pcre源代码"
wget https://ctcc1-node.bt.cn/src/pcre-8.43.tar.gz 2>&1 | grep '%'
if [ $? -ne 0 ]; then
    echo "下载pcre源代码失败，请检查网络环境"
    exit 1
fi
echo "正在下载zlib源代码"
wget --no-check-certificate https://www.zlib.net/fossils/zlib-1.2.7.3.tar.gz 2>&1 | grep '%'
if [ $? -ne 0 ]; then
    echo "下载zlib源代码失败，请检查网络环境"
    exit 1
fi
echo "正在下载nginx源代码"
wget https://nginx.org/download/nginx-1.26.2.tar.gz 2>&1 | grep '%'
if [ $? -ne 0 ]; then
    echo "下载nginx源代码失败，请检查网络环境"
    exit 1
fi
echo "正在解压各种依赖和nginx"
tar -zxf openssl-1.1.1q.tar.gz
tar -zxf pcre-8.43.tar.gz
tar -zxf nginx-1.26.2.tar.gz
tar -zxf zlib-1.2.7.3.tar.gz
echo "正在编译pcre"
cd pcre-8.43
./configure
make -s -j$(nproc)

echo "正在编译openssl"
cd -
cd openssl-1.1.1q
./config
make -s -j$(nproc)

echo "正在编译zlib"
cd -
cd zlib-1.2.7.3
./configure
make -s -j$(nproc)

echo "正在编译nginx"
cd -
cd nginx-1.26.2
./configure --prefix=/opt/nginx-1.26.2 --with-openssl=../openssl-1.1.1q --with-pcre=../pcre-8.43 --with-zlib=../zlib-1.2.7.3
make -s -j$(nproc)
make install
