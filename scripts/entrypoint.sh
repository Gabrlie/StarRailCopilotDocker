#!/bin/bash
set -e

# 配置文件路径
CONFIG_FILE="/app/config/deploy.yaml"
TEMPLATE_FILE="/app/deploy.template-linux.yaml"

# 如果配置文件不存在，从模板复制
if [ ! -f "$CONFIG_FILE" ]; then
    echo "配置文件不存在，从模板创建: $CONFIG_FILE"
    if [ -f "$TEMPLATE_FILE" ]; then
        cp "$TEMPLATE_FILE" "$CONFIG_FILE"
        echo "✓ 配置文件已创建"
    else
        echo "✗ 错误: 模板文件不存在: $TEMPLATE_FILE"
        exit 1
    fi
else
    echo "✓ 配置文件已存在: $CONFIG_FILE"
fi

# 执行传入的命令
exec "$@"
