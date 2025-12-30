#!/bin/bash
# 检查上游 StarRailCopilot 仓库是否有更新

set -e

UPSTREAM_REPO="https://github.com/LmeSzinc/StarRailCopilot.git"
RECORD_FILE=".last_build_commit"

# 获取远程仓库最新 commit hash
echo "🔍 检查上游仓库更新..."
LATEST_COMMIT=$(git ls-remote "$UPSTREAM_REPO" HEAD | cut -f1)
echo "最新 commit: $LATEST_COMMIT"

# 检查本地记录
if [ -f "$RECORD_FILE" ]; then
    LAST_COMMIT=$(cat "$RECORD_FILE")
    echo "上次构建: $LAST_COMMIT"
    
    if [ "$LATEST_COMMIT" = "$LAST_COMMIT" ]; then
        echo "✅ 无更新"
        echo "has_update=false"
        exit 0
    else
        echo "🔄 发现更新!"
        echo "has_update=true"
        echo "commit_hash=$LATEST_COMMIT"
        exit 0
    fi
else
    echo "🆕 首次检查"
    echo "has_update=true"
    echo "commit_hash=$LATEST_COMMIT"
    exit 0
fi
