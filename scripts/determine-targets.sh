#!/usr/bin/env bash
# Determine build targets based on changed files
# Usage: determine-targets.sh <ci_changed> <images_changed> <images_files_json>

ci_changed=${1:-false}
images_changed=${2:-false}
images_files=${3:-"[]"}

# 1. CI 配置变动 -> 全量构建
if [[ "$ci_changed" == "true" ]]; then
    echo "Reason: CI or bake definition changed" >&2
    echo "all"
    exit 0
fi

# 2. 无镜像文件变动 -> 跳过
if [[ "$images_changed" != "true" ]]; then
    echo "Reason: No image changes detected" >&2
    echo "none"
    exit 0
fi

# 3. 解析变动的目标 (依赖 jq)
# 输入示例: ["images/base/Dockerfile", "images/k3s/VERSION"]
# 输出示例: base,k3s
targets=$(echo "$images_files" | jq -r '[.[] | split("/")[1]] | unique | join(",")')

# 4. 特殊规则: base 变动 -> 全量构建
if [[ ",$targets," == *",base,"* ]]; then
    echo "Reason: base image changed, rebuilding all" >&2
    echo "all"
    exit 0
fi

# 5. 增量构建
echo "Reason: Incremental build for: $targets" >&2
echo "$targets"
