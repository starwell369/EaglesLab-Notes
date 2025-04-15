#!/bin/bash

# 读取部署配置
CONFIG=$(cat deploy-config.json)
# COURSES=("SRE" "Java" "Security")
COURSES=("SRE")

for course in "${COURSES[@]}"; do
    # 解析配置
    host=$(echo "$CONFIG" | jq -r ".${course}.host")
    user=$(echo "$CONFIG" | jq -r ".${course}.user")
    path=$(echo "$CONFIG" | jq -r ".${course}.path")

    # 同步文件
    echo "Deploying $course to $host..."
    rsync -avz --delete \
        # -e "ssh -i $HOME/.ssh/id_rsa" \
        "dist/$course/" \
        "$user@$host:$path"
done