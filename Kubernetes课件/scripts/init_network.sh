#!/bin/bash

# 导入日志模块和检查工具模块
source $(dirname "$0")/logger.sh
source $(dirname "$0")/check_utils.sh
source $(dirname "$0")/utils.sh

# 检查是否以root用户运行
if [ "$(id -u)" != "0" ]; then
    log_error "此脚本必须以root用户运行"
    exit 1
fi

# 获取用户输入的IP配置
log "请输入IP地址（例如：192.168.1.100）："
read ip_input
while ! validate_ip "$ip_input"; do
    log_warn "IP地址格式不正确，请重新输入："
    read ip_input
done

log "请输入子网掩码位数（例如：24）："
read netmask
while ! [[ "$netmask" =~ ^[0-9]+$ ]] || [ "$netmask" -lt 1 ] || [ "$netmask" -gt 32 ]; do
    log_warn "子网掩码位数不正确，请输入1-32之间的数字："
    read netmask
done

# 获取用户输入的网关地址
log "请输入网关地址（例如：192.168.1.1）："
read gateway_input
while ! validate_ip "$gateway_input"; do
    log_warn "网关地址格式不正确，请重新输入："
    read gateway_input
done

# 获取网卡名称
NIC_NAME=""
if [ -d "/etc/NetworkManager/system-connections" ]; then
    # 查找第一个有效的网卡配置文件
    for file in /etc/NetworkManager/system-connections/*.nmconnection; do
        if [ -f "$file" ]; then
            # 从配置文件中提取网卡名称
            temp_name=$(grep -Po '^interface-name=\K.*' "$file" || grep -Po '^id=\K.*' "$file")
            if [ -n "$temp_name" ]; then
                NIC_NAME="$temp_name"
                break
            fi
        fi
    done
fi

# 如果没有找到网卡名称，使用默认值
if [ -z "$NIC_NAME" ]; then
    NIC_NAME="ens160"
    log_warn "未找到现有网卡配置，使用默认网卡名称：${NIC_NAME}"
fi

# 定义IP配置
IP_ADDRESS="${ip_input}/${netmask}"
DNS_SERVERS="114.114.114.114;114.114.115.115"

# 检查网卡是否存在
check_nic "$NIC_NAME"

# 检查网卡配置文件是否存在
CONFIG_FILE="/etc/NetworkManager/system-connections/${NIC_NAME}.nmconnection"
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"

# 获取原配置文件的UUID
if [ -f "$CONFIG_FILE" ]; then
    # 检查是否已配置固定IP
    if grep -q "method=manual" "$CONFIG_FILE" && grep -q "$IP_ADDRESS" "$CONFIG_FILE"; then
        log "网卡 ${NIC_NAME} 已配置为固定IP ${IP_ADDRESS}，无需重复配置"
        exit 0
    fi
    
    # 备份原配置文件
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    log_info "已备份原配置文件到 ${BACKUP_FILE}"
    
    # 获取原UUID
    UUID=$(grep -Po '^uuid=\K.*' "$CONFIG_FILE" || uuidgen)
else
    # 如果配置文件不存在，生成新的UUID
    UUID=$(uuidgen)
    log_info "创建新的网卡配置文件"
fi

# 创建新的网卡配置文件
cat > "$CONFIG_FILE" << EOF
[connection]
id=${NIC_NAME}
type=ethernet
interface-name=${NIC_NAME}
uuid=${UUID}
autoconnect=true

[ethernet]

[ipv4]
method=manual
address1=${IP_ADDRESS}
gateway=${gateway_input}
dns=${DNS_SERVERS}

[ipv6]
method=disabled
EOF

# 设置配置文件权限
chmod 600 "$CONFIG_FILE"
log_info "已设置配置文件权限"

# 检查网卡状态并启用
log_info "正在检查网卡状态..."
if nmcli d show "$NIC_NAME" | grep -q "disconnected"; then
    log_info "网卡处于断开状态，正在启用网卡..."
    nmcli d connect "$NIC_NAME"
    sleep 2
fi

# 重启网络设备和连接
log_info "正在重启网络设备和连接..."
nmcli d r "$NIC_NAME"
nmcli c r "$NIC_NAME"
nmcli c u "$NIC_NAME"

log_info "网卡配置完成，当前IP地址：${IP_ADDRESS}"