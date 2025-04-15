# 创建测试用的tar.gz文件
create_test_archive() {
    local archive_file="$1"
    local content="$2"
    local temp_dir="/tmp/test_content_$$"
    
    mkdir -p "$temp_dir"
    echo "$content" > "$temp_dir/test.txt"
    tar -czf "$archive_file" -C "$temp_dir" test.txt
    rm -rf "$temp_dir"
}

# 测试 check_archive_unchanged 函数
test_check_archive_unchanged() {
    local test_dir="/tmp/test_archive_check"
    local test_file="$test_dir/test.tar.gz"
    local hash_file="$test_dir/test_hash"
    local extract_dir="$test_dir/extract"
    
    # 清理测试环境
    rm -rf "$test_dir"
    mkdir -p "$test_dir"
    
    # 创建测试文件
    create_test_archive "$test_file" "test content"
    
    log_info "开始测试 check_archive_unchanged 函数..."
    
    # 测试用例1: 首次解压（无hash文件）
    log_info "测试用例1: 首次解压（无hash文件）"
    check_archive_unchanged "$test_file" "$hash_file" "$extract_dir"
    local result=$?
    if [ $result -eq 2 ]; then
        log_info "测试通过: 首次解压返回值正确(2)"
    else
        log_error "测试失败: 首次解压返回值错误(期望:2, 实际:$result)"
        return 1
    fi
    
    # 测试用例2: 再次解压（hash未变化）
    log_info "测试用例2: 再次解压（hash未变化）"
    check_archive_unchanged "$test_file" "$hash_file" "$extract_dir"
    result=$?
    if [ $result -eq 0 ]; then
        log_info "测试通过: hash未变化返回值正确(0)"
    else
        log_error "测试失败: hash未变化返回值错误(期望:0, 实际:$result)"
        return 1
    fi
    
    # 测试用例3: 文件内容变化后解压
    log_info "测试用例3: 文件内容变化后解压"
    create_test_archive "$test_file" "modified content"
    check_archive_unchanged "$test_file" "$hash_file" "$extract_dir"
    result=$?
    if [ $result -eq 2 ]; then
        log_info "测试通过: 内容变化后返回值正确(2)"
    else
        log_error "测试失败: 内容变化后返回值错误(期望:2, 实际:$result)"
        return 1
    fi
    
    # 测试用例4: 无效文件测试
    log_info "测试用例4: 无效文件测试"
    check_archive_unchanged "/nonexistent/file" "$hash_file" "$extract_dir"
    result=$?
    if [ $result -eq 1 ]; then
        log_info "测试通过: 无效文件返回值正确(1)"
    else
        log_error "测试失败: 无效文件返回值错误(期望:1, 实际:$result)"
        return 1
    fi
    
    # 清理测试环境
    rm -rf "$test_dir"
    
    log_info "所有测试用例执行完成!"
    return 0
}