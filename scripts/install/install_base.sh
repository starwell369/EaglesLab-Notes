#!/bin/bash

CURRENT_DIR=$(dirname "$0")
ROOT_DIR=$(cd "$CURRENT_DIR/.." && pwd)

# 导入日志模块和检查工具模块
source $ROOT_DIR/logger.sh
source $ROOT_DIR/utils/check_utils.sh
source $ROOT_DIR/utils/utils.sh

# 定义安装步骤数组
STEPS=(
    "初始化网络配置:init_network.sh"
    "系统参数优化:init_system_config.sh"
    "安装Docker CE:install_docker_ce.sh"
    "安装cri-docker:install_cri_docker.sh "
    "加载容器镜像:load_images.sh ${images_path}"
    "安装kubelet:install_kubelet.sh ${kubernetes_path}"
)

# 检查root权限
if [ "$(id -u)" != "0" ]; then
  log_error "必须使用root用户执行安装脚本"
  exit 1
fi

# 执行脚本函数
execute_script() {
    local script=$1
    local name=$2
    local cmd="bash $(dirname "$0")/${script}"
    
    log_info "正在执行 ▶ ${name}"
    
    if [ "$script" = "load_images.sh" ]; then
        $cmd "$@" || { log_error "${name} 执行失败，终止安装流程"; exit 1; }
    else
        $cmd || { log_error "${name} 执行失败，终止安装流程"; exit 1; }
    fi
    
    log_info "${name} 完成"
}

# 执行基础安装流程
run_base_install() {
    for step in "${STEPS[@]}"; do
        IFS=':' read -r step_name step_script <<< "$step"
        execute_script "$step_script" "$step_name"
    done
}