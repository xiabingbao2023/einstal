#!/bin/bash

# 菜单函数
show_menu() {
    clear
    echo "=== 菜单 ==="
    echo "1. 关闭SELinux和firewalld"
    echo "1. 安装JDK"
    echo "2. 安装Nginx"
    echo "3. 退出"
}

# 安装JDK函数
SElinux_disable() {
    echo "正在安装JDK..."
    # 在这里添加安装JDK的实际命令
    echo "JDK安装完成！"
}


# 安装JDK函数
install_jdk() {
    echo "正在安装JDK..."
    # 在这里添加安装JDK的实际命令
    echo "JDK安装完成！"
}

# 安装Nginx函数
install_nginx() {
    echo "正在安装Nginx..."
    # 在这里添加安装Nginx的实际命令
    echo "Nginx安装完成！"
}

# 主循环
while true; do
    show_menu
    read -p "请选择操作（输入选项数字）: " choice

    case $choice in
        1)
            install_jdk
            ;;
        2)
            install_nginx
            ;;
        3)
            echo "退出脚本。"
            break
            ;;
        *)
            echo "无效选项，请重新选择。"
            ;;
    esac

    read -p "按Enter继续..."
done
