#!/bin/bash
set -e

# 清理旧构建产物
rm -rf dist
mkdir -p dist

# 获取变更的目录
get_changed_directories() {
    # 检查是否在 CI 环境中
    if [ -n "$GITHUB_SHA" ]; then
        # 在 GitHub Actions 中，获取当前提交的所有文件
        git diff --name-only ${{ github.event.before }} $GITHUB_SHA | cut -d'/' -f1 | sort -u
    else
        # 在本地开发环境中，获取所有包含 SUMMARY.md 的目录
        find . -name "SUMMARY.md" -exec dirname {} \; | cut -d'/' -f2
    fi
}

# 构建指定目录的文档
build_course() {
    local course=$1
    echo "Building $course..."
    if [ -d "$course" ] && [ -f "$course/SUMMARY.md" ]; then
        (
            cd "$course"
            gitbook install
            gitbook build
            mkdir -p ../dist/"$course"
            mv _book/* ../dist/"$course"/
            rm -rf _book
        )
    fi
}

# 获取需要构建的目录列表
changed_courses=$(get_changed_directories)

# 构建每个变更的目录
for course in $changed_courses; do
    if [ -n "$course" ]; then
        build_course "$course"
    fi
done

# 检查是否有构建成功的目录
if [ -z "$(ls -A dist)" ]; then
    echo "Warning: No courses were built!"
    exit 1
fi