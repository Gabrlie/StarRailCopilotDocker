# 多阶段构建 StarRailCopilot Docker 镜像
# 基于官方 Python 镜像,包含所有必要的依赖

# ============================================
# 阶段 1: 构建阶段
# ============================================
FROM python:3.9-slim AS builder

# 设置工作目录
WORKDIR /build

# 安装构建依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# 复制 StarRailCopilot 源代码
COPY StarRailCopilot/requirements.txt .

# 安装 Python 依赖到临时目录
RUN pip install --no-cache-dir --user -r requirements.txt

# ============================================
# 阶段 2: 运行阶段
# ============================================
FROM python:3.9-slim

# 构建参数
ARG COMMIT_HASH=unknown
LABEL org.opencontainers.image.source="https://github.com/LmeSzinc/StarRailCopilot"
LABEL org.opencontainers.image.description="StarRailCopilot - Honkai: Star Rail auto bot"
LABEL org.opencontainers.image.revision="${COMMIT_HASH}"

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

# 安装运行时依赖
# 安装运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    adb \
    python3-opencv \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 从构建阶段复制 Python 包
COPY --from=builder /root/.local /root/.local

# 设置 PATH
ENV PATH=/root/.local/bin:$PATH

# 创建应用目录
WORKDIR /app

# 复制 StarRailCopilot 源代码
COPY StarRailCopilot/ .

# 复制配置模板
RUN if [ -f config/deploy.template-cn.yaml ]; then \
    cp config/deploy.template-cn.yaml config/deploy.yaml; \
    fi

# 创建必要的目录
RUN mkdir -p logs screenshots config

# 暴露 WebUI 端口 (默认 22367)
EXPOSE 22367

# 健康检查
# 注意: WebUI 需要较长时间启动,因此设置了 60 秒的启动等待期
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:22367/ || exit 1

# 设置入口点
ENTRYPOINT ["python", "gui.py", "--run", "src"]

# 默认命令参数
CMD []
