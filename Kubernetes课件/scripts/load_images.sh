#!/bin/bash

# 导入日志模块和检查工具模块
source $(dirname "$0")/logger.sh
source $(dirname "$0")/check_utils.sh
source $(dirname "$0")/utils.sh

# 检查是否提供了压缩包参数
if [ $# -ne 1 ]; then
    log_error "用法: $0 <压缩包路径>"
    exit 1
fi

# 检查压缩包是否存在并且可读
if ! check_archive "$1"; then
    exit 1
fi

# 检查docker是否存在
if ! check_command docker; then
    exit 1
fi 

log_info "开始处理镜像压缩包..."

# 解压压缩包
tmp_name=$(basename $1 .tar.gz)
tmp_dir=/tmp/$tmp_name-$(date +%s)
extract_archive "$1" "$tmp_dir" || exit 1
extract_dir=$tmp_dir/$tmp_name

# 统计总文件数
total_files=$(find "$extract_dir" -type f -name "*.tar" | wc -l)
if [ "$total_files" -eq 0 ]; then
    log_warn "在压缩包中没有找到.tar格式的镜像文件"
    exit 1
fi

# 遍历解压目录中的所有.tar文件
current_file=0
while IFS= read -r image; do
    if [ -f "$image" ]; then
        ((current_file++))
        # 从文件名提取镜像名称和标签
        image_name_tag=$(basename "$image" .tar | sed 's/__/:/g')
        
        # 检查镜像是否已存在
        if docker inspect --type=image "$image_name_tag" >/dev/null 2>&1; then
            log_info "✓ 镜像已存在，跳过加载: $image_name_tag"
            continue
        fi
        
        log_info "正在加载镜像 ($current_file/$total_files): $(basename "$image")"
        
        if docker load < "$image"; then
            log_info "✓ 成功加载镜像: $(basename "$image")"
        else
            log_error "✗ 加载失败: $(basename "$image")"
        fi
    fi
done < <(find "$extract_dir" -type f -name "*.tar")

log_info "镜像加载完成，共处理 $current_file 个文件"