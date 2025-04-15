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

# 设置解压相关变量
tmp_name=$(basename $1 .tar.gz)
hash_file="/tmp/.image_archive_hash"
extract_base_dir="/tmp/$tmp_name-latest"
extract_dir="$extract_base_dir/$tmp_name"

# 检查压缩包是否需要解压
check_archive_unchanged "$1" "$hash_file" "$extract_base_dir"
case $? in
    0)  # 压缩包未变更，无需解压
        ;;
    1)  # 解压失败
        exit 1
        ;;
    2)  # 解压成功
        ;;
esac

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
        # 使用新函数转换镜像名称
        image_name_tag=$(convert_filename_to_image "$image")
        
        # 检查镜像是否已存在
        if docker inspect --type=image "$image_name_tag" >/dev/null 2>&1; then
            log_info "✓ 镜像已存在，跳过加载: $image_name_tag"
            continue
        fi
        
        log_info "正在加载镜像 ($current_file/$total_files): $image_name_tag"
        
        if docker load < "$image"; then
            log_info "✓ 成功加载镜像: $image_name_tag"
        else
            log_error "✗ 加载失败: $image_name_tag"
        fi
    fi
done < <(find "$extract_dir" -type f -name "*.tar")

log_info "镜像加载完成，共处理 $current_file 个文件"