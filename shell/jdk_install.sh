#!/bin/bash

# 定义 JDK 安装目录和环境变量配置文件
jdk_dir="/opt/jdk1.8"
profile_file="/etc/profile"

# 检查本地是否已经有 JDK 安装包
if [ -f "jdk1.8.tar.gz" ]; then
    echo "本地已存在 JDK 1.8 安装包。"
else
    # 下载 JDK 1.8（假设你有可用的 JDK 1.8 安装包链接）
    jdk_url="https://mirrors.tuna.tsinghua.edu.cn/Adoptium/8/jdk/x64/linux/OpenJDK8U-jdk_x64_linux_hotspot_8u382b05.tar.gz"
    echo "下载 JDK 1.8..."
    wget -q $jdk_url -O jdk1.8.tar.gz
fi

# 解压 JDK 1.8
echo "解压 JDK 1.8..."
tar -xzf jdk1.8.tar.gz -C /opt/
rm jdk1.8.tar.gz

# 配置环境变量
echo "配置环境变量..."
echo "export JAVA_HOME=$jdk_dir" >> $profile_file
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $profile_file

# 使环境变量生效
source $profile_file

echo "JDK 1.8 安装完成。"
