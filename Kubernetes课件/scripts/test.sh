#!/bin/bash

# 导入日志模块和检查工具模块
source $(dirname "$0")/logger.sh
source $(dirname "$0")/check_utils.sh
source $(dirname "$0")/utils.sh

# 定义测试用例
test_cases=(
    "extract_archive"
)

tmp_dir=/tmp/$(basename $1 .tar.gz)-$(date +%s)

# 运行测试用例
for test_case in "${test_cases[@]}"; do
    if "$test_case" $1 $tmp_dir; then
        log_info "$test_case 测试通过"
    else
        log_error "$test_case 测试失败"
    fi
done