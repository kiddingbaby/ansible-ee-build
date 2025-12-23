# Ansible Execution Environments (EE) 构建系统

本项目包含 Ansible 执行环境 (Execution Environments, EE) 的构建配置与自动化流程。

## 架构概览

- **CI/CD**: GitHub Actions (`.github/workflows/build.yml`)
- **构建定义**: `docker-bake.hcl` (基于 BuildKit)
- **镜像列表**:
  - `ansible-ee-base`: 包含 Ansible Core 的基础镜像。
  - `ansible-ee-k3s`: 继承自 Base，包含 K3s 管理工具的扩展镜像。

## 镜像说明

### ansible-ee-base

生产就绪的 Ansible 执行环境基础镜像。经过优化、安全加固且符合 OCI 标准。

**核心特性:**

- **极简体积**: 基于 Debian Slim，采用多阶段构建。
- **安全加固**: 以非 Root 用户 (`ansible`) 运行。
- **构建优化**: 集成 BuildKit 缓存，优化 `ansible.cfg` 配置。
- **标准兼容**: 预装 Ansible Core 2.17+ 和 Ansible Runner 2.4+。

**配置详情:**

- Roles/Collections 路径: `/usr/share/ansible`
- 日志格式: YAML (`stdout_callback = yaml`)
- SSH: 启用 Pipelining 和 ControlPersist。

**如何扩展:**

```dockerfile
FROM ansible-ee-base:latest
COPY project /runner/project
CMD ["ansible-runner", "run", "/runner", "-p", "site.yml"]
```

### ansible-ee-k3s

继承自 `ansible-ee-base`，额外包含了 K3s 管理所需的工具集。

## 本地开发指南

本项目开发环境（无论是宿主机还是 DevContainer）均预置了 Docker 兼容层（通过 `nerdctl` shim 或软链接实现）。你可以直接使用标准的 `docker` 命令。

### 1. 构建镜像 (Build)

**构建 Base 镜像:**

```bash
docker build -t ansible-ee-base:latest ansible-ee-base/
```

**构建 K3s 镜像:**

```bash
# BuildKit 会自动处理构建缓存
docker build \
  --build-arg BASE_IMAGE=ansible-ee-base:latest \
  -t ansible-ee-k3s:latest \
  ansible-ee-k3s/
```

### 2. 调试与 Shell (Debug)

启动交互式容器进行调试。

**进入 Base 镜像 Shell:**

```bash
docker run --rm -it \
  -v $(pwd):/ansible \
  -w /ansible \
  ansible-ee-base:latest bash
```

**进入 K3s 镜像 Shell:**

```bash
docker run --rm -it \
  -v $(pwd):/ansible \
  -w /ansible \
  ansible-ee-k3s:latest bash
```

### 3. 清理环境 (Clean)

```bash
docker rmi ansible-ee-base:latest ansible-ee-k3s:latest
```

## 高级构建 (Buildctl / Bake)

如果你希望直接与 BuildKit 交互（例如在 CI 或无 Daemon 环境中），可以使用 `buildctl` 或 `docker buildx bake`。

### 使用 Bake (推荐)

`docker-bake.hcl` 定义了完整的构建图。即使使用 `nerdctl`，你也可以通过安装 `docker-buildx` 插件来使用 bake 功能：

```bash
# 确保 buildx 指向 buildkitd socket
# export BUILDX_BUILDER=default 

# 查看构建计划
docker buildx bake --print

# 构建所有目标
docker buildx bake
```
