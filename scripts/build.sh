#!/bin/bash

# 清理旧构建产物
rm -rf dist
mkdir -p dist

# 课程列表（需与目录名一致）
changed_courses=$(git diff --name-only HEAD^ HEAD | cut -d'/' -f1 | uniq)
for course in $changed_courses; do
    echo "Building $course..."
    cd "$course"
    gitbook install   # 安装插件（如需要）
    gitbook build
    mkdir -p ../dist/"$course"
    mv _book/* ../dist/"$course"/
    rm -rf _book
    cd ..
done