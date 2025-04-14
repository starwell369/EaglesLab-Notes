#!/bin/bash

# 测试convert_filename_to_image函数
test_convert_filename_to_image() {
    # 测试用例包含完整版本号(包括v前缀)的处理
    local test_cases=(
        "calico-node-v3.26.1.tar:calico/node:v3.26.1"
        "calico-cni-v3.26.1.tar:calico/cni:v3.26.1"
        "registry.k8s.io-ingress-nginx-kube-webhook-certgen-v20231011-8b53cabe0.tar:registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20231011-8b53cabe0"
        "registry.k8s.io-ingress-nginx-controller-v1.8.1.tar:registry.k8s.io/ingress-nginx/controller:v1.8.1"  # 新增：测试无v前缀的版本号
        )

    local failed=0
    for test_case in "${test_cases[@]}"; do
        local input="${test_case%%:*}"
        local expected="${test_case#*:}"
        local result=$(convert_filename_to_image "$input")
        
        if [ "$result" = "$expected" ]; then
            log_info "测试通过: $input -> $result"
        else
            log_error "测试失败: $input"
            log_error "期望结果: $expected"
            log_error "实际结果: $result"
            failed=1
        fi
    done

    if [ $failed -eq 0 ]; then
        log_info "所有测试用例通过!"
        return 0
    else
        log_error "存在失败的测试用例"
        return 1
    fi
}
