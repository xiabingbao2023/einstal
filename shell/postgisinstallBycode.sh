#!/bin/bash
# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi
echo "正在通过yum安装一些依赖"
yum install bzip2 python-devel centos-release-scl -y -q
sudo sed -e "s|^mirrorlist=|#mirrorlist=|g" \
    -e "s|^# baseurl=http://mirror.centos.org/centos/7|baseurl=https://mirrors.bfsu.edu.cn/centos-vault/7.9.2009|g" \
    -e "s|^#baseurl=http://mirror.centos.org/centos/7|baseurl=https://mirrors.bfsu.edu.cn/centos-vault/7.9.2009|g" \
    -i.bak \
    /etc/yum.repos.d/CentOS-SCLo-*.repo
echo "安装了sclo的yum源并替换源为https://mirrors.bfsu.edu.cn/centos-vault/7.9.2009"
echo "该源提供了更高版本的gcc"
#安装高版本gcc
yum install devtoolset-7 -y -q
source /opt/rh/devtoolset-7/enable
#安装cmake
echo "正在下载和安装cmake"
mkdir -p /opt/CMake
wget https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.tar.gz -O /opt/CMake/cmake.tar.gz 2>&1 | grep '%'
tar -zxf /opt/CMake/cmake.tar.gz -C /opt/CMake/
#安装geos（postgis依赖于它）
echo "正在下载和安装geos"
mkdir -p /opt/postgis/geos-3.12.2/_build
wget https://download.osgeo.org/geos/geos-3.12.2.tar.bz2 -O /opt/postgis/geos.tar.bz2 2>&1 | grep '%'
tar -jxf /opt/postgis/geos.tar.bz2 -C /opt/postgis/
cd /opt/postgis/geos-3.12.2/_build
source /opt/rh/devtoolset-7/enable
/opt/CMake/cmake-3.13.4-Linux-x86_64/bin/cmake -DCMAKE_BUILD_TYPE=Release /opt/postgis/geos-3.12.2
make -s -j$(nproc)
make install
#安装sqlite3（proj依赖它）
echo "正在下载和安装sqlite3"
wget https://www.sqlite.org/2022/sqlite-autoconf-3400000.tar.gz -O /opt/postgis/sqllite.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/sqllite.tar.gz -C /opt/postgis/
cd /opt/postgis/sqlite-autoconf-3400000
source /opt/rh/devtoolset-7/enable
./configure
make -s -j$(nproc)
make install
#安装proj（postgis依赖于它）
echo "正在下载和安装proj"
wget https://download.osgeo.org/proj/proj-6.1.1.tar.gz -O /opt/postgis/proj.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/proj.tar.gz -C /opt/postgis/
mkdir /opt/postgis/proj-6.1.1/build
cd /opt/postgis/proj-6.1.1/build
source /opt/rh/devtoolset-7/enable
/opt/CMake/cmake-3.13.4-Linux-x86_64/bin/cmake ..
make -s -j$(nproc)
make install
#安装gdal（postgis依赖它）
echo "正在下载和安装gdal"
wget https://github.com/OSGeo/gdal/releases/download/v3.6.1/gdal-3.6.1.tar.gz -O /opt/postgis/gdal.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/gdal.tar.gz -C /opt/postgis/
mkdir -p /opt/postgis/gdal-3.6.1/build
cd /opt/postgis/gdal-3.6.1/build
source /opt/rh/devtoolset-7/enable
/opt/CMake/cmake-3.13.4-Linux-x86_64/bin/cmake ..
#不要使用多线程编译 会导致编译失败
make
make install
# 安装libxml2（postgis依赖于它）
echo "正在下载和安装libxml2"
wget https://download.gnome.org/sources/libxml2/2.13/libxml2-2.13.4.tar.xz -O /opt/postgis/libxml2-2.13.4.tar.xz 2>&1 | grep '%'
tar -xf /opt/postgis/libxml2-2.13.4.tar.xz -C /opt/postgis/
cd /opt/postgis/libxml2-2.13.4
source /opt/rh/devtoolset-7/enable
./configure
make -s -j$(nproc)
make install
#安装protobuf（postgis依赖它同时protobuf-c依赖它）
echo "正在下载和安装protobuf"
wget https://github.com/protocolbuffers/protobuf/releases/download/v3.11.4/protobuf-all-3.11.4.tar.gz -O /opt/postgis/protobuf.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/protobuf.tar.gz -C /opt/postgis/
cd /opt/postgis/protobuf-3.11.4/
source /opt/rh/devtoolset-7/enable
./configure
make -s -j$(nproc)
make install
#安装protobuf-c（postgis依赖它）
echo "正在下载和安装protobuf-c"
wget https://github.com/protobuf-c/protobuf-c/releases/download/v1.3.3/protobuf-c-1.3.3.tar.gz -O /opt/postgis/protobuf-c.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/protobuf-c.tar.gz -C /opt/postgis/
cd /opt/postgis/protobuf-c-1.3.3
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
./configure
make -s -j$(nproc)
make install
#编译pcre
echo "正在下载和安装pcre"
wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.41/pcre2-10.41.tar.gz -O /opt/postgis/pcre2.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/pcre2.tar.gz -C /opt/postgis/
cd /opt/postgis/pcre2-10.41/
source /opt/rh/devtoolset-7/enable
./configure --enable-utf8
make -s -j$(nproc)
make install
#编译json-c
echo "正在下载和安装json-c"
wget https://github.com/json-c/json-c/archive/refs/tags/json-c-0.18-20240915.tar.gz -O /opt/postgis/json-c.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/json-c.tar.gz -C /opt/postgis/
mkdir -p /opt/postgis/json-c-json-c-0.18-20240915/build
cd /opt/postgis/json-c-json-c-0.18-20240915/build
source /opt/rh/devtoolset-7/enable
/opt/CMake/cmake-3.13.4-Linux-x86_64/bin/cmake ..
make -s -j$(nproc)
make install
#编译postgis
echo "正在下载和安装postgis"
wget https://download.osgeo.org/postgis/source/postgis-3.5.0.tar.gz -O /opt/postgis/postigs.tar.gz 2>&1 | grep '%'
tar -zxf /opt/postgis/postigs.tar.gz -C /opt/postgis/
cd /opt/postgis/postgis-3.5.0
source /opt/rh/devtoolset-7/enable
./configure --with-pgconfig=/opt/postgresql/pg12.20server/bin/pg_config
make -s -j$(nproc)
make install
ln -s -T /usr/local/lib64/libgeos_c.so.1.18.2 /lib64/libgeos_c.so.1
ln -s -T /usr/local/lib64/libproj.so.16.1.1 /lib64/libproj.so.16
ln -s -T /usr/local/lib/libprotobuf-c.so.1.0.0 /lib64/libprotobuf-c.so.1
ln -s -T /usr/local/lib64/libgeos.so.3.12.2 /lib64/libgeos.so.3.12.2
