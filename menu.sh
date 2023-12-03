#!/bin/bash

# 菜单函数
show_menu() {
    clear
    echo "=== 在Linux上一键安装各种软件 V0.01 ==="
    echo "1. 关闭SELinux和firewalld"
    echo "2. 安装JDK1.8"
    echo "3. 通过yum源安装Nginx"
    echo "4. 通过yum源安装mysql5.7"
    echo "4. 通过yum源安装PG12"
    echo "0. 退出"
}

# 关闭SElinux函数
SElinux_disable() {

current_status=$(getenforce)

if [ "$current_status" == "Enforcing" ]; then
    echo "当前 SELinux 状态为 Enforcing，将关闭 SELinux。"
    # 临时关闭 SELinux
    setenforce 0
    # 修改配置文件以永久关闭 SELinux（需要重启系统才会生效）
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    echo "SELinux 已关闭。"
elif [ "$current_status" == "Permissive" ]; then
    echo "当前 SELinux 状态为 Permissive，将永久关闭 SELinux。"
    # 修改配置文件以永久关闭 SELinux（需要重启系统才会生效）
    sed -i 's/^SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
    echo "SELinux 已关闭。"
else
    echo "当前 SELinux 状态为 Disabled，无需操作。"
fi

}

# 关闭firewalld函数
firewalld_disable(){
# 检查当前 firewalld 状态
current_status=$(systemctl is-active firewalld)

if [ "$current_status" == "active" ]; then
    echo "当前 firewalld 状态为 active，将关闭 firewalld。"
    # 停止 firewalld 服务
    systemctl stop firewalld
    # 禁用 firewalld 服务，以防止开机启动
    systemctl disable firewalld
    echo "firewalld 已关闭。"
else
    echo "当前 firewalld 状态为 inactive，无需操作。"
fi

}

# 安装JDK函数
install_jdk() {
    echo "正在安装JDK..."
    # 在这里添加安装JDK的实际命令
    source ./shell/jdk_install.sh
    echo "JDK安装完成！"
}

# 安装Nginx函数
install_nginxByYum() {
    echo "正在安装Nginx..."
    source ./shell/nginx_installByYum.sh
    echo "Nginx安装完成！"
}
# 通过yum安装mysql5.7
install_mysql5.7ByYum（）{
    echo "正在通过yum安装MySQL5.7..."
    source ./shell/install_yum_mysql57.sh
    echo "MySQL5.7安装完成！"
}

# 主循环
while true; do
    show_menu
    read -p "请选择操作（输入选项数字）: " choice

    case $choice in
        1)
            SElinux_disable
            firewalld_disable
            ;;
        2)
            install_jdk
            ;;
        3)
            install_nginxByYum
            ;;
         3)
            install_mysql5.7ByYum
            ;;
        0)
            echo "退出脚本。"
            break
            ;;
        *)
            echo "无效选项，请重新选择。"
            ;;
    esac

    read -p "按Enter继续..."
done
