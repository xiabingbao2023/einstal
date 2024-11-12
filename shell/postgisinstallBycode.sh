#!/bin/bash
# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi
wget https://postgis.net/stuff/postgis-3.6.0dev.tar.gz
tar -xvf postgis-3.6.0dev.tar.gz
cd postgis-3.6.0dev
./configure --with-pgconfig=/opt/postgresql/pg12.20server/bin/pg_config --with-xml2config=/opt/postgis/libxml2/bin/xml2-config

# 安装libxml2
wget https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.13.4/libxml2-v2.13.4.tar.gz
tar -xvf libxml2-v2.13.4.tar.gz
cd libxml2-v2.13.4
./configure --prefix=/opt/postgis/libxml2
yum -y install python-devel
make -s -j$(nproc)
make install
#安装geos
wget https://download.osgeo.org/geos/geos-3.9.5.tar.bz2
yum install -y bzip2