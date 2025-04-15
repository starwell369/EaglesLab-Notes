#!/bin/bash

# 导入日志模块和检查工具模块
source $(dirname "$0")/logger.sh
source $(dirname "$0")/check_utils.sh
source $(dirname "$0")/utils.sh

source $(dirname "$0")/test/test_check_archive_unchanged.sh
source $(dirname "$0")/test/test_convert_filename_to_image.sh

# 运行所有测试
run_all_tests() {
    local failed=0
    
    log_info "开始执行所有测试..."
    
    # 测试 convert_filename_to_image
    if ! test_convert_filename_to_image; then
        ((failed++))
    fi
    
    # 测试 check_archive_unchanged
    if ! test_check_archive_unchanged; then
        ((failed++))
    fi
    
    if [ $failed -eq 0 ]; then
        log_info "所有测试用例通过!"
        return 0
    else
        log_error "存在 $failed 个测试套件失败"
        return 1
    fi
}

# 执行测试
run_all_tests