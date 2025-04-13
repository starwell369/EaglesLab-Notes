#!/bin/bash

# 导入日志模块和检查工具模块
source $(dirname "$0")/logger.sh
source $(dirname "$0")/check_utils.sh
source $(dirname "$0")/utils.sh

# 检查并安装软件包
install_package() {
    if ! rpm -q "$1" &>/dev/null; then
        log_info "正在安装 $1"
        if ! yum -y install "$1"; then
            log_error "安装 $1 失败"
            return 1
        fi
    else
        log_info "软件包 $1 已安装"
    fi
    return 0
}

# Rocky 系统软件源更换
if ! grep -q "mirrors.aliyun.com" /etc/yum.repos.d/[Rr]ocky*.repo; then
    log_info "更换 Rocky Linux 软件源为阿里云源"
    sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
        -i.bak \
        /etc/yum.repos.d/[Rr]ocky*.repo
    dnf makecache
else
    log_info "已配置阿里云软件源"
fi

# 防火墙修改 firewalld 为 iptables
if systemctl is-active firewalld &>/dev/null; then
    log_info "停止并禁用 firewalld 服务"
    systemctl stop firewalld
    systemctl disable firewalld
fi

if ! install_package "iptables-services"; then
    log_error "安装 iptables-services 失败"
    exit 1
fi

if ! systemctl is-active iptables &>/dev/null; then
    log_info "启动并启用 iptables 服务"
    systemctl start iptables
    iptables -F
    systemctl enable iptables
    service iptables save
else
    log_info "iptables 服务已运行"
fi

# 禁用 SELinux
selinux_status=$(getenforce)
if [ "$selinux_status" != "Disabled" ]; then
    log "禁用 SELinux"
    setenforce 0
    if ! grep -q "^SELINUX=disabled" /etc/selinux/config; then
        sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
    fi
    if ! grep -q "selinux=0" /proc/cmdline; then
        grubby --update-kernel ALL --args selinux=0
    fi
else
    log "SELinux 已禁用"
fi

# 设置时区
current_timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')
if [ "$current_timezone" != "Asia/Shanghai" ]; then
    log "设置时区为 Asia/Shanghai"
    timedatectl set-timezone Asia/Shanghai
else
    log "时区已设置为 Asia/Shanghai"
fi

# 关闭 swap 分区
if grep -q "^/dev/mapper/rl-swap" /etc/fstab && ! grep -q "^#/dev/mapper/rl-swap" /etc/fstab; then
    log "关闭 swap 分区"
    swapoff -a
    sed -i 's:^/dev/mapper/rl-swap:#/dev/mapper/rl-swap:g' /etc/fstab
else
    log "swap 分区已禁用"
fi

# 更新hosts文件
log "更新hosts文件"
cp -f /etc/hosts /etc/hosts.bak
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF
cat /root/hosts >> /etc/hosts

# 获取当前IP地址并设置主机名
current_ip=$(ip route get 1 | awk '{print $7; exit}')
if [ -n "$current_ip" ]; then
    hostname_from_hosts=$(grep "$current_ip" /etc/hosts | awk '{print $2}')
    if [ -n "$hostname_from_hosts" ]; then
        log "根据IP地址 $current_ip 设置主机名为 $hostname_from_hosts"
        hostnamectl set-hostname "$hostname_from_hosts"
    else
        log "警告：在hosts文件中未找到IP $current_ip 对应的主机名记录"
    fi
else
    log "错误：无法获取当前IP地址"
    exit 1
fi

# 安装 ipvs
if ! install_package "ipvsadm"; then
    log "错误：安装 ipvsadm 失败"
    exit 1
fi

# 开启路由转发
if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    log "开启 IP 转发"
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    sysctl -p
else
    log "IP 转发已启用"
fi

# 加载 bridge 模块
if ! install_package "bridge-utils"; then
    log "错误：安装 bridge-utils 失败"
    exit 1
fi

if ! lsmod | grep -q "^br_netfilter"; then
    log "加载 br_netfilter 模块"
    modprobe br_netfilter
    if ! grep -q "^br_netfilter" /etc/modules-load.d/bridge.conf; then
        echo 'br_netfilter' >> /etc/modules-load.d/bridge.conf
    fi
else
    log "br_netfilter 模块已加载"
fi

# 配置 bridge-nf-call-iptables
if ! grep -q "^net.bridge.bridge-nf-call-iptables=1" /etc/sysctl.conf; then
    log "配置 bridge-nf-call-iptables"
    echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
    echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf
    sysctl -p
else
    log "bridge-nf-call-iptables 已配置"
fi

log "系统初始化配置完成"