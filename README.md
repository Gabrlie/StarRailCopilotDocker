# StarRailCopilot Docker 自动化构建

[![Docker Pulls](https://img.shields.io/docker/pulls/gabrlie/starrailcopilot)](https://hub.docker.com/r/gabrlie/starrailcopilot)
[![Docker Image Size](https://img.shields.io/docker/image-size/gabrlie/starrailcopilot/latest)](https://hub.docker.com/r/gabrlie/starrailcopilot)

> 自动化构建 [StarRailCopilot](https://github.com/LmeSzinc/StarRailCopilot) 的 Docker 镜像,每天自动检查更新并推送到 Docker Hub。

## ✨ 特性

- 🤖 **全自动化**: 使用 GitHub Actions 每天定时检查上游更新
- 🐳 **开箱即用**: 预构建的 Docker 镜像,无需手动编译
- 🏗️ **多架构支持**: 同时支持 `amd64` 和 `arm64` 架构
- 📦 **版本管理**: 使用 commit hash 和日期作为镜像标签,便于版本追踪
- ⚡ **持续更新**: 自动跟随上游仓库更新

## 🚀 快速开始

### 使用 Docker Compose (推荐)

1. **下载配置文件**

```bash
wget https://raw.githubusercontent.com/gabrlie/StarRailCopilotDocker/main/docker-compose.example.yml -O docker-compose.yml
```

2. **启动容器**

```bash
docker-compose up -d
```

3. **访问 WebUI**

打开浏览器访问: http://localhost:22367

### 使用 Docker 命令

```bash
# 拉取最新镜像
docker pull gabrlie/starrailcopilot:latest

# 运行容器
docker run -d \
  --name starrailcopilot \
  -p 22367:22367 \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/logs:/app/logs \
  -v $(pwd)/screenshots:/app/screenshots \
  -e TZ=Asia/Shanghai \
  gabrlie/starrailcopilot:latest
```

## 📋 配置说明

### 目录结构

```
.
├── config/          # 配置文件目录
│   └── deploy.yaml  # 主配置文件
├── logs/            # 日志目录
└── screenshots/     # 截图目录
```

### 配置文件

**首次启动时**，容器会自动检查 `config/deploy.yaml` 是否存在：
- ✅ 如果不存在，会自动从 `config/deploy.template-linux.yaml` 模板创建
- ✅ 如果已存在，则使用现有配置

这样即使你映射了一个空的 `config` 目录，也不用担心配置文件丢失。

**修改配置**：

首次启动后，你可以直接修改宿主机上的 `config/deploy.yaml` 文件：

```bash
# 编辑配置文件
vim ./config/deploy.yaml

# 重启容器使配置生效
docker-compose restart
```

**主要配置项**：

- **模拟器配置**: 设置模拟器类型和连接方式
- **游戏服务器**: 选择国服/国际服
- **任务设置**: 配置每日任务、体力清理等
- **WebUI 密码**: 默认为 `EnterYourPasswordHere`，建议修改 (见下文 [安全配置](#-安全配置-修改默认密码))

详细配置说明请参考: [StarRailCopilot Wiki](https://github.com/LmeSzinc/StarRailCopilot/wiki)

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `TZ` | 时区设置 | `Asia/Shanghai` |

### 🔐 安全配置 (修改默认密码)

默认的 WebUI 密码为 `EnterYourPasswordHere`。为了您的数据安全，**强烈建议**在首次启动后立即修改此密码。

1. **编辑配置文件**

   ```bash
   vim ./config/deploy.yaml
   ```

2. **修改密码字段**

   找到 `Webui` 部分下的 `Password` 字段，将其修改为您自定义的密码：

   ```yaml
   Webui:
     # ...
     # --key. Password of web ui
     Password: 您的强密码
     # ...
   ```

3. **重启容器**

   修改完成后，重启容器使配置生效：

   ```bash
   docker-compose restart
   ```

## 🏷️ 镜像标签

| 标签 | 说明 |
|------|------|
| `latest` | 最新构建版本 |
| `{commit-hash}` | 特定 commit 版本 (前7位) |
| `{YYYYMMDD}` | 特定日期构建版本 |

示例:
```bash
# 使用最新版本
docker pull gabrlie/starrailcopilot:latest

# 使用特定 commit 版本
docker pull gabrlie/starrailcopilot:a1b2c3d

# 使用特定日期版本
docker pull gabrlie/starrailcopilot:20231230
```

## 🔧 高级配置

### 连接宿主机模拟器

如果模拟器运行在宿主机上,需要使用 `host` 网络模式:

```yaml
services:
  starrailcopilot:
    network_mode: "host"
```

### 连接 Android 设备

如需连接真实 Android 设备:

```yaml
services:
  starrailcopilot:
    devices:
      - /dev/bus/usb:/dev/bus/usb
    privileged: true
```

### 资源限制

限制容器资源使用:

```yaml
services:
  starrailcopilot:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

## 🛠️ 手动构建

如果你想自己构建镜像:

### 前置要求

- Docker 20.10+
- Docker Buildx

### 构建步骤

1. **克隆本仓库**

```bash
git clone https://github.com/gabrlie/StarRailCopilotDocker.git
cd StarRailCopilotDocker
```

2. **克隆上游仓库**

```bash
git clone https://github.com/LmeSzinc/StarRailCopilot.git
```

3. **构建镜像**

```bash
# 单架构构建
docker build -t starrailcopilot:local .

# 多架构构建
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t starrailcopilot:local \
  --load .
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request!

### Fork 并配置自动构建

1. **Fork 本仓库**

2. **配置 GitHub Secrets**

   在你的仓库 `Settings -> Secrets and variables -> Actions` 中添加:
   - `DOCKERHUB_USERNAME`: 你的 Docker Hub 用户名
   - `DOCKERHUB_TOKEN`: 你的 Docker Hub 访问令牌

3. **手动触发构建**

   进入 `Actions` 标签页,选择 `Build and Push` 工作流,点击 `Run workflow`

4. **等待构建完成**

   构建完成后,镜像会自动推送到你的 Docker Hub 仓库

## 📝 常见问题

### Q: 如何查看容器日志?

```bash
docker logs -f starrailcopilot
```

### Q: 如何进入容器调试?

```bash
docker exec -it starrailcopilot bash
```

### Q: 如何更新到最新版本?

```bash
docker-compose pull
docker-compose up -d
```

### Q: 容器无法连接模拟器?

确保:
1. 模拟器 ADB 端口已开放
2. 容器网络配置正确 (使用 `host` 模式或正确的端口映射)
3. 配置文件中的模拟器序列号正确

### Q: WebUI 无法访问?

检查:
1. 端口映射是否正确 (`-p 22367:22367`)
2. 防火墙是否允许该端口
3. 容器是否正常运行 (`docker ps`)

## 📄 许可证

本项目采用 MIT 许可证。

上游项目 [StarRailCopilot](https://github.com/LmeSzinc/StarRailCopilot) 采用 GPL-3.0 许可证。

## 🙏 致谢

- [StarRailCopilot](https://github.com/LmeSzinc/StarRailCopilot) - 崩坏:星穹铁道脚本
- [LmeSzinc](https://github.com/LmeSzinc) - 原作者

## 📮 联系方式

- 提交 Issue: [GitHub Issues](https://github.com/gabrlie/StarRailCopilotDocker/issues)
- 上游项目问题: [StarRailCopilot Issues](https://github.com/LmeSzinc/StarRailCopilot/issues)

---

⭐ 如果这个项目对你有帮助,请给个 Star!
