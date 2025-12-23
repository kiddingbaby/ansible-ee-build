# Ansible Execution Environment (Base)

这是一个生产就绪的 Ansible 执行环境基础镜像。它经过高度优化，安全且符合 OCI 标准，专为构建下游业务镜像或作为独立 Runner 使用而设计。

## 主要特性

- **极简体积**：基于 Debian Slim，多阶段构建，仅包含运行时依赖。
- **安全加固**：默认非 Root 用户 (`ansible`) 运行，遵循最小权限原则。
- **构建优化**：集成 BuildKit 缓存，支持 `bindep.txt` 系统依赖管理。
- **标准兼容**：预装 Ansible Core 2.17+ 和 Ansible Runner 2.4+。

## 快速开始

### 1. 构建镜像

```bash
DOCKER_BUILDKIT=1 docker build -t ansible-ee-base:latest .
```

### 2. 运行容器

**默认行为**：
容器启动时默认执行 `ansible-runner run /runner -p site.yml`。如果未挂载项目或项目内缺少 `site.yml`，容器将报错退出。

**运行 Playbook**（挂载项目目录）：

```bash
# 将当前目录挂载到容器内的 /runner/project
# 注意：当前目录必须包含 site.yml
docker run --rm -v $(pwd):/runner/project ansible-ee-base:latest
```

**覆盖默认命令**：

```bash
# 运行 ansible --version
docker run --rm ansible-ee-base:latest ansible --version

# 运行指定的 Playbook (例如 deploy.yml)
docker run --rm -v $(pwd):/runner/project ansible-ee-base:latest \
  ansible-runner run /runner -p deploy.yml
```

**交互式 Shell**：

```bash
docker run --rm -it ansible-ee-base:latest bash
```

## 配置说明

镜像内置了针对容器环境优化的 `ansible.cfg`：

- **路径适配**：Roles 和 Collections 路径指向 `/usr/share/ansible`，适配非 Root 用户。
- **日志优化**：`stdout_callback = yaml`，提供清晰易读的容器日志。
- **性能调优**：开启 SSH Pipelining 和 ControlPersist，显著提升大规模执行速度。

## 如何扩展（构建业务镜像）

在生产环境中，推荐基于此基础镜像构建包含业务代码的专用镜像。

**示例 Dockerfile**：

```dockerfile
FROM ansible-ee-base:latest

# 1. 安装系统依赖 (可选)
COPY bindep.txt /tmp/bindep.txt
RUN --mount=type=cache,target=/var/cache/apt \
    packages="$(grep -vE '^\s*#' /tmp/bindep.txt | tr '\n' ' ')" \
    && if [ -n "$packages" ]; then apt-get update && apt-get install -y --no-install-recommends $packages; fi \
    && rm -f /tmp/bindep.txt && rm -rf /var/lib/apt/lists/*

# 2. 复制项目代码
COPY project /runner/project

# 3. 安装 Python 依赖 (可选)
COPY requirements.txt /tmp/requirements.txt
RUN /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

# 4. 设置默认启动命令
CMD ["ansible-runner", "run", "/runner", "-p", "site.yml"]
```

## 目录结构

- `Dockerfile`: 核心构建文件。
- `ansible.cfg`: 针对容器环境优化的 Ansible 配置。
- `bindep.txt`: 基础系统依赖列表。
- `tests/`: 冒烟测试与验证脚本。

## CI/CD 集成

本仓库包含 GitHub Actions 示例配置，支持：

- BuildKit 高速构建
- Trivy 漏洞扫描
- Cosign 镜像签名

## 维护者

- HomeLab User
