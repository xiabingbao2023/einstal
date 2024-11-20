#!/bin/bash
# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi
wget https://download.osgeo.org/postgis/source/postgis-3.5.0.tar.gz
tar -xvf postgis-3.5.0.tar.gz
cd postgis-3.5.0
./configure --with-pgconfig=/opt/postgresql/pg12.20server/bin/pg_config --with-xml2config=/opt/postgis/libxml2/bin/xml2-config --with-geosconfig=/opt/postgis/geos/bin/geos-config --without-protobuf
# 安装libxml2（postgis依赖于它）
wget https://download.gnome.org/sources/libxml2/2.13/libxml2-2.13.4.tar.xz
tar -xvf libxml2-v2.13.4.tar.gz
cd libxml2-v2.13.4
./configure --prefix=/opt/postgis/libxml2
yum -y install python-devel
make -s -j$(nproc)
make install
#安装geos（postgis依赖于它）
wget https://download.osgeo.org/geos/geos-3.12.2.tar.bz2
yum install -y bzip2
tar -jxf geos-3.12.2.tar.bz2
cd geos-3.12.2
mkdir _build
cd _build
/root/cmake-3.13.4-Linux-x86_64/bin/cmake     -DCMAKE_BUILD_TYPE=Release   /root/geos-3.12.2
make -s -j$(nproc)
make install
#安装cmake
wget https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.tar.gz
tar -zxvf cmake-3.13.4-Linux-x86_64.tar.gz
#安装gcc
yum install scl-utils -y
sudo yum install centos-release-scl -y
yum install devtoolset-7 -y
source /opt/rh/devtoolset-7/enable
#安装proj（postgis依赖于它）
wget https://download.osgeo.org/proj/proj-6.1.1.tar.gz
tar -xvf proj-6.1.1.tar.gz
cd proj-6.1.1
/root/cmake-3.13.4-Linux-x86_64/bin/cmake ..
mkdir build  
cd build 
make -s -j$(nproc)
#安装sqlite3（proj依赖它）
wget https://www.sqlite.org/2022/sqlite-autoconf-3400000.tar.gz  
cd /root/sqlite-autoconf-3400000
./configure
make -s -j$(nproc)
make install
#安装gdal（postgis依赖它）
wget https://github.com/OSGeo/gdal/releases/download/v3.6.1/gdal-3.6.1.tar.gz  
tar -zxvf gdal-3.6.1.tar.gz
mkdir build  
cd build  
/root/cmake-3.13.4-Linux-x86_64/bin/cmake ..
source /opt/rh/devtoolset-7/enable
#不要使用多线程编译 会导致编译失败
make
make install
#TODO暂时先不编译
#安装protobuf（postgis依赖它）
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.11.4/protobuf-all-3.11.4.tar.gz
tar -zxvf protobuf-all-3.11.4.tar.gz
cd protobuf-3.11.4/
./configure
make -s -j$(nproc)
make install
#TODO暂时先不编译
#安装protobuf-c（postgis依赖它）
wget https://github.com/protobuf-c/protobuf-c/releases/download/v1.3.3/protobuf-c-1.3.3.tar.gz
tar -zxvf protobuf-c-1.3.3.tar.gz 
cd protobuf-c-1.3.3
export PATH=/usr/local/protobuf/bin:$PATH
export PKG_CONFIG_PATH=/usr/local/protobuf/lib/pkgconfig:$PKG_CONFIG_PATH  
./configure --prefix=/usr/local/protobuf-c 
make -s -j$(nproc)

