#!/bin/bash
# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi
#在root目录下创建pgsource目录
mkdir /root/pgsource
cd /root/pgsource
#通过yum安装wget gcc make组件
yum install wget gcc make -y
if [ $? -ne 0 ]; then
    echo "安装wget gcc make组件失败，请检查网络环境"
    exit 1
fi
#下载readline源代码，并提示正在下载readline源代码
echo "正在下载readline源代码"
wget https://ftp.gnu.org/gnu/readline/readline-6.2.tar.gz
if [ $? -ne 0 ]; then
    echo "下载readline源代码失败，请检查网络环境"
    exit 1
fi
#下载zlib源代码,并提示下载zlib源代码
echo "正在下载zlib源代码"
wget --no-check-certificate https://www.zlib.net/fossils/zlib-1.2.7.3.tar.gz
if [ $? -ne 0 ]; then
    echo "下载zlib源代码失败，请检查网络环境"
    exit 1
fi
#下载ncurses源代码
wget https://ftp.gnu.org/gnu/ncurses/ncurses-5.9.tar.gz
if [ $? -ne 0 ]; then
    echo "下载ncurses源代码失败，请检查网络环境"
    exit 1
fi
#下载pgsql安装包
wget https://ftp.postgresql.org/pub/source/v12.20/postgresql-12.20.tar.gz
if [ $? -ne 0 ]; then
    echo "下载pgsql安装包失败，请检查网络环境"
    exit 1
fi
#对下载的readline源代码进行解压，并提示正在解压readline源代码
echo "正在解压readline源代码"
tar -xzf readline-6.2.tar.gz
if [ $? -ne 0 ]; then
    echo "解压readline源代码失败"
    exit 1
fi
#对下载的zlib源代码进行解压，并提示正在解压zlib源代码
echo "正在解压zlib源代码"
tar -xzf zlib-1.2.7.3.tar.gz
if [ $? -ne 0 ]; then
    echo "解压zlib源代码失败"
    exit 1
fi
#对下载的ncurses源代码进行解压，并提示正在解压ncurses源代码
echo "正在解压ncurses源代码"
tar -xzf ncurses-5.9.tar.gz
if [ $? -ne 0 ]; then
    echo "解压ncurses源代码失败"
    exit 1
fi
#对下载的pgsql安装包进行解压，并提示正在解压pgsql安装包
echo "正在解压pgsql安装包"
tar -xzf postgresql-12.20.tar.gz
if [ $? -ne 0 ]; then
    echo "解压pgsql源代码失败"
    exit 1
fi
#开始编译安装readline
echo "正在编译安装readline"
cd readline-6.2
./configure --prefix=/opt/postgresql-12.20/pg-dep
make && make install
cd -
#开始编译安装zlib
echo "正在编译安装zlib"
cd zlib-1.2.7.3
./configure --prefix=/opt/postgresql-12.20/pg-dep
make && make install
cd -
#开始编译安装ncurses
echo "正在编译安装ncurses"
cd ncurses-5.9
./configure --prefix=/opt/postgresql-12.20/pg-dep --without-cxx-binding
make && make install
cd -
#开始编译安装pg数据库
echo "正在编译安装pg数据库"
cd postgresql-12.20 
./configure --prefix=/opt/postgresql-12.20/pg12.20server --with-libraries=/opt/postgresql-12.20/pg-dep/lib/ --with-includes=/opt/postgresql-12.20/pg-dep/include/
make && make install
cd -
#创建postgresql软链接
ln -s -T /opt/postgresql-12.20/ /opt/postgresql
echo "正在创建postgresql软链接"
#创建postgres用户
echo "正在创建postgres用户"
useradd postgres
echo “!QAZ-pl,”| passwd --stdin postgres
#创建pg数据库目录
echo "正在创建pg数据库目录"
mkdir -p /opt/postgresql-12.20/pg12.20server/pgdata
#更改数据库权限
chown -R postgres:postgres /opt/postgresql-12.20
echo "正在初始化pg数据库"
su -c "/opt/postgresql-12.20/pg12.20server/bin/initdb -D /opt/postgresql-12.20/pg12.20server/pgdata" postgres
echo "正在配置pg数据库"
#配置启动服务器
cp /root/pgsource/postgresql-12.20/contrib/start-scripts/linux /etc/init.d/
chmod +x /etc/init.d/linux
mv /etc/init.d/linux /etc/init.d/postgresql
sed -i 's#prefix=/usr/local/pgsql#prefix=/opt/postgresql/pg12.20server/#g' /etc/init.d/postgresql
sed -i 's#PGDATA="/usr/local/pgsql/data"#PGDATA=/opt/postgresql/pg12.20server/pgdata/#g' /etc/init.d/postgresql
chkconfig --add postgresql
#允许postgresql远程登录
echo "正在配置远程登录"
sed -i 's#host    all             all             127.0.0.1/32            ident#host    all             all             0.0.0.0/0            md5#g' /opt/postgresql/pg12.20server/pgdata/pg_hba.conf
echo "host    all             all             0.0.0.0/0            md5" >> /opt/postgresql/pg12.20server/pgdata/pg_hba.conf
echo "listen_addresses = '*'" >> /opt/postgresql/pg12.20server/pgdata/postgresql.conf
#配置postgresql的bin目录到path环境变量
echo "export PATH=\$PATH:/opt/postgresql/pg12.20server/bin" >> /etc/profile
source /etc/profile
#启动数据库
systemctl daemon-reload
systemctl start postgresql
echo "正在启动数据库"
sleep 3
systemctl status postgresql
# 检测服务是否启动成功
if systemctl is-active --quiet postgresql; then
    echo "安装成功！postgresql服务已成功启动。"
    echo "默认允许所有地址访问"
    echo "postgres的用户名为postgresql"
    echo "ALTER USER postgres WITH PASSWORD 'postgresql';" | /opt/postgresql/pg12.20server/bin/psql -U postgres -h localhost
else
    echo "安装失败，请手动排查。"
fi
