#!/bin/bash
# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "请以 root 用户身份运行此脚本。"
    exit 1
fi
wget https://postgis.net/stuff/postgis-3.6.0dev.tar.gz
tar -xvf postgis-3.6.0dev.tar.gz
cd postgis-3.6.0dev