#!/bin/bash

source $(dirname "$0")/install_base.sh

run_base_install

# 主节点初始化配置
# 集群状态检查
check_cluster() {
    if [ -f /etc/kubernetes/admin.conf ]; then
        log_warn "检测到已存在的集群配置"
		exit 0
    fi
}

log_info "开始初始化Kubernetes控制平面"
check_cluster

kubeadm init \
 --apiserver-advertise-address=${apiserver} \
 --image-repository registry.aliyuncs.com/google_containers \
 --kubernetes-version 1.29.2 \
 --service-cidr=10.10.0.0/12 \
 --pod-network-cidr=10.244.0.0/16 \
 --ignore-preflight-errors=all \
 --cri-socket unix:///var/run/cri-dockerd.sock

if [ $? -ne 0 ]; then
  log_error "控制平面初始化失败，请检查错误日志"
  exit 1
fi

# 生成join命令备份
log_info "保存节点加入命令到/join_command.txt"
kubeadm token create --print-join-command > /join_command.sh 2>/dev/null
chmod 600 /join_command.sh

# 配置kubectl访问权限
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

log_info "主节点初始化完成，节点加入命令已保存至/join_command.txt"