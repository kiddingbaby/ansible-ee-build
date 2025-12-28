# Ansible Execution Environment 构建系统

[English](./README.md) | [中文文档](./README.zh-CN.md)

基于 Docker BuildKit 和 HCL 的专业级、可复现 Ansible Execution Environments (EE) 镜像构建系统。

## 🚀 核心特性

- **现代构建系统**：使用 `docker buildx bake` 和 HCL 进行声明式构建定义。
- **镜像优化**：
  - **多阶段构建**：减小镜像体积。
  - **BuildKit 缓存挂载**：利用 `pip` 和 `apt` 缓存加速重复构建。
  - **Tini 集成**：作为 init 进程正确处理信号。
  - **非 Root 用户**：默认使用 `ansible` 用户，增强安全性。
- **依赖管理**：本地 DAG 解析确保 `k3s` 镜像在 `base` 构建后正确构建，无需中间推送。
- **CI/CD 就绪**：集成了 GitHub Actions 工作流，支持自动版本控制和 GHCR 发布。

## 📦 镜像层级

| 镜像              | 描述                                                                                                  | 目录上下文          |
| :---------------- | :---------------------------------------------------------------------------------------------------- | :------------------ |
| `ansible-ee-base` | 基础镜像。包含 Python 3.11, Ansible Core 2.17, Ansible Runner 及基础系统库。                          | `./ansible-ee-base` |
| `ansible-ee-k3s`  | 扩展镜像。基于 `base`，增加了 Kubernetes 工具 (`kubectl`, `helm`) 和 K3s 相关的 Ansible collections。 | `./ansible-ee-k3s`  |

## 📂 项目结构

```text
.
├── ansible-ee-base/      # 基础镜像定义
│   ├── Dockerfile
│   ├── requirements.txt  # Python 依赖
│   └── ansible.cfg
├── ansible-ee-k3s/       # K3s 扩展镜像
│   ├── Dockerfile
│   ├── requirements.txt  # K3s 特有 Python 依赖
│   └── requirements.yml  # Ansible collections
├── docker-bake.hcl       # BuildKit HCL 定义文件
├── Makefile              # 用户操作入口 (Wrapper)
└── .github/              # CI/CD 工作流
```

## 🛠️ 快速开始

### 前置要求

- Docker (支持 Buildx)
- Make

### 构建命令

`Makefile` 提供了对 `docker buildx bake` 的便捷封装。

**构建并加载到本地 Docker:**
这是开发时的默认操作。它会构建镜像并将其加载到本地 Docker 守护进程中。

```bash
make load
```

**构建并推送到仓库:**
构建镜像并将其推送到配置的镜像仓库（默认：`ghcr.io/kiddingbaby`）。

```bash
make build
```

**构建指定目标:**
你可以使用 `TARGETS` 变量仅构建 base 镜像或 k3s 镜像。

```bash
make load TARGETS=base
make load TARGETS=k3s
```

**清理:**
从本地 Docker 中删除生成的镜像。

```bash
make clean
```

## ⚙️ 配置

你可以覆盖默认变量：

| 变量       | 默认值                | 描述                                           |
| :--------- | :-------------------- | :--------------------------------------------- |
| `VERSION`  | `dev-<short-sha>`     | 镜像的版本标签。                               |
| `REGISTRY` | `ghcr.io/kiddingbaby` | 推送的目标镜像仓库。                           |
| `TARGETS`  | `all`                 | 要构建的 bake 目标 (`base`, `k3s`, 或 `all`)。 |

示例：

```bash
make load VERSION=v1.0.0
```

## 🏃 使用方法

使用 Docker 运行构建好的镜像：

```bash
# 查看 ansible 版本
docker run --rm ghcr.io/kiddingbaby/ansible-ee-base:dev-xxxxxxx ansible --version

# 运行交互式 Shell
docker run --rm -it ghcr.io/kiddingbaby/ansible-ee-k3s:dev-xxxxxxx bash
```

## 📝 许可证

MIT
