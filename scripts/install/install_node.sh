#!/bin/bash

CURRENT_DIR=$(dirname "$0")
ROOT_DIR=$(cd "$CURRENT_DIR/.." && pwd)

# 导入日志模块和检查工具模块
source $ROOT_DIR/logger.sh
source $ROOT_DIR/utils/utils.sh

# 导入基础安装脚本
source $ROOT_DIR/install/install_base.sh
run_base_install

# Check and execute join command
JOIN_SCRIPT="$(dirname "$0")/join_command.sh"
if [ -f "$JOIN_SCRIPT" ]; then
    log_info "🔄 执行节点加入命令..."
    # Add containerd socket parameter to join command
    JOIN_CMD=$(cat "$JOIN_SCRIPT")
    JOIN_CMD="$JOIN_CMD --cri-socket unix:///var/run/cri-dockerd.sock"
    
    if eval "$JOIN_CMD"; then
        log_info "✅ 节点成功加入集群"
    else
        log_error "❌ 节点加入失败"
        exit 1
    fi
else
    log_warning "⚠️ 未找到节点加入命令脚本，请在master节点上执行以下命令生成join_command.sh："
    log_info "kubeadm token create --print-join-command > join_command.sh"
fi

log_info "🏁 所有组件安装完成，Kubernetes节点就绪"