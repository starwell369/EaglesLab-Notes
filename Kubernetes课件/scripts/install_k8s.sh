#/bin/bash

# 初始化主节点
# kubeadm init\
#  --apiserver-advertise-address=192.168.173.100\
#  --image-repository registry.aliyuncs.com/google_containers\
#  --kubernetes-version 1.29.2\
#  --service-cidr=10.10.0.0/12\
#  --pod-network-cidr=10.244.0.0/16\
#  --ignore-preflight-errors=all\
#  --cri-socket unix:///var/run/cri-dockerd.sock

# # node 加入
# kubeadm join 192.168.173.100:6443 --token jghzcm.mz6js92jom1flry0 \
#         --discovery-token-ca-cert-hash sha256:63253f3d82fa07022af61bb2ae799177d2b0b6fe8398d5273098f4288ce67793  --cri-socket unix:///var/run/cri-dockerd.sock
        
# # work token 过期后，重新申请
# kubeadm token create --print-join-command

