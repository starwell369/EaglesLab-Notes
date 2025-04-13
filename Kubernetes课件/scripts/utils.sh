#!/bin/bash

# 导入日志模块
source $(dirname "$0")/logger.sh

# 验证IP地址格式
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        for i in {1..4}; do
            if [ $(echo "$ip" | cut -d. -f$i) -gt 255 ]; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# 解压压缩包至指定目录
extract_archive() {
    local archive_file=$1
    local extract_dir=$2
    
    command -v tar >/dev/null || {
        log_error "tar命令未找到，请确保tar已安装"
        return 1
    }

    check_archive "$archive_file" || return 1

    mkdir -p "$extract_dir"

    log_info "正在解压 '$archive_file' 到 '$extract_dir'..."
    if ! tar -xzf "$archive_file" -C "$extract_dir" >/dev/null 2>&1; then
        log_error "解压失败: '$archive_file'"
        return 1
    fi
    log_info "解压成功!"
    return 0
}