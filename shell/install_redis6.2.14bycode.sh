#!/bin/bash
# 检查是否安装wget和gcc，如果不存在则安装
if ! command -v wget &> /dev/null; then
    echo "正在安装 wget..."
    yum install -y wget
fi

if ! command -v gcc &> /dev/null; then
    echo "正在安装 gcc..."
    yum install -y gcc make
fi

# 下载Redis源码
echo "正在下载Redis源码..."
wget https://download.redis.io/releases/redis-6.2.14.tar.gz

# 解压
echo "正在解压..."
tar -zxvf redis-6.2.14.tar.gz
cd redis-6.2.14
# 编译
echo "正在编译..."
make
echo "正在安装..."
make PREFIX=/opt/redis6.2.14 install
ln -s -T /opt/redis6.2.14/ /opt/redis
# 创建配置文件存放目录
echo "正在创建配置文件目录..."
mkdir -p /etc/redis

# 复制配置文件
echo "正在复制配置文件..."
cp redis.conf /etc/redis/6379.conf

# 修改配置文件让Redis变为后台启动
echo "正在修改配置文件..."
sudo sed -i 's/^daemonize no$/daemonize yes/' /etc/redis/6379.conf
#开启持久化
mkdir -p /opt/redis6.2.14/{rdb,aof}
sed -i 's/^# save 3600 1$/save 3600 1/' /etc/redis/6379.conf
sed -i 's/^# save 300 100$/save 300 100/' /etc/redis/6379.conf
sed -i 's/^# save 60 10000$/save 60 10000/' /etc/redis/6379.conf
sed -i 's/^appendonly no$/appendonly yes/' /etc/redis/6379.conf
sed -i '/dir ./a dir /opt/redis6.2.14/rdb' /etc/redis/6379.conf
sed -i '456,457d' /etc/redis/6379.conf
sed -i '/appendfilename "appendonly.aof"/a dir /opt/redis6.2.14/aof' /etc/redis/6379.conf
sed -i 's/^appendonly no$/appendonly yes/' /etc/redis/6379.conf
sed -i '/dir .//a dir /opt/redis6.2.14/rdb' /etc/redis/6379.conf
#配置密码
sed -i 's/^# requirepass foobared$/requirepass redis/' /etc/redis/6379.conf
#配置redis到环境变量
echo "export PATH=\$PATH:/opt/redis/bin" >> /etc/profile
source /etc/profile
# 复制启动脚本
echo "正在复制启动脚本..."
cp utils/redis_init_script /etc/init.d/redis
sudo sed -i 's/usr/opt/g' /etc/init.d/redis
sudo sed -i 's/local/redis/g' /etc/init.d/redis
# 制作成服务
chkconfig --add redis
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

