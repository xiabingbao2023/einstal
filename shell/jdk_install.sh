#!/bin/bash
# 检测并安装 wget 命令
if ! command -v wget &> /dev/null; then
    echo "wget 命令未安装，开始安装..."
    if [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get install wget -y
    elif [ -f /etc/redhat-release ]; then
        sudo yum install wget -y
    else
        echo "无法确定操作系统发行版，无法自动安装 wget。请手动安装 wget 后重新运行脚本。"
        exit 1
    fi
fi
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
    tar -xzf jdk1.8.tar.gz -C /opt/
    ln -s /opt/jdk8u* /opt/jdk1.8
fi

# 检查jdk安装是否成功
if [ $? -eq 0 ]; then
    rm jdk1.8.tar.gz  # 解压成功后删除安装包

    # 配置环境变量
    echo "配置环境变量..."
    echo "export JAVA_HOME=$jdk_dir" >> $profile_file
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $profile_file

    # 使环境变量生效
    source $profile_file

    echo "JDK 1.8 安装完成。"
else
    echo "JDK 1.8 解压失败，未配置环境变量。"
fi
