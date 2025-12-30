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

| 镜像               | 描述                                                                    | 目录上下文          |
| ------------------ | ----------------------------------------------------------------------- | ------------------- |
| `ansible-base`     | 基础镜像。Python 3.11、Ansible Core 2.17、Ansible Runner 及系统库。     | `./images/base`     |
| `ansible-k3s`      | K3s 扩展。基于 `base`，增加 Kubernetes 工具和 K3s Ansible collections。 | `./images/k3s`      |
| `ansible-harbor`   | Harbor 注册表集成（实验性）。                                           | `./images/harbor`   |
| `ansible-keycloak` | Keycloak 身份认证集成（实验性）。                                       | `./images/keycloak` |

## 📂 项目结构

```text
.
├── images/
│   ├── base/              # 基础镜像（必需）
│   │   ├── VERSION        # 版本文件（若无则用 dev-<sha>）
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── ansible.cfg
│   │   └── tests/         # 测试套件
│   │       └── smoke-test/
│   ├── k3s/               # K3s 扩展（依赖 base）
│   │   ├── VERSION
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── requirements.yml
│   ├── harbor/            # Harbor 扩展（实验性）
│   └── keycloak/          # Keycloak 扩展（实验性）
├── docker-bake.hcl        # BuildKit HCL 定义
├── Makefile               # 构建封装
├── test.sh                # 动态版本扫描器
└── .github/workflows/     # GitHub Actions（自动检测变更）
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

## ⚙️ 版本管理

**单镜像版本**（通过 `VERSION` 文件）

- 每个镜像可在 `images/<name>/VERSION` 文件中定义版本号。
- 若文件存在：使用文件内容作为标签（如 `ansible-base:1.0.0`）。
- 若文件不存在：自动回退到 `dev-<短-git-sha>`。

### 构建变量

| 变量       | 默认值                | 描述                                                |
| :--------- | :-------------------- | :-------------------------------------------------- |
| `VERSION`  | `dev-<short-sha>`     | 全局版本（可被单镜像版本覆盖）。                    |
| `REGISTRY` | `ghcr.io/kiddingbaby` | 推送的目标镜像仓库。                                |
| `TARGETS`  | `all`                 | 要构建的目标：`base`、`k3s`、`harbor`、`keycloak`。 |

示例：

```bash
# 使用 VERSION 文件或 git SHA 的默认版本构建
make build

# 指定全局版本
make build VERSION=1.2.0

# 仅构建 base
make build TARGETS=base
```

## 🏃 使用方法

### 构建

```bash
# 本地构建所有镜像
make load

# 构建指定镜像
make load TARGETS=base
```

### 运行和测试

**测试 base 镜像**（见 [images/base/tests/smoke-test](./images/base/tests/smoke-test)）：

```bash
make build VERSION=1.0.0 TARGETS=base
docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:1.0.0 \
  ansible-runner run /runner -p site.yml
```

**交互式 shell**：

```bash
docker run -it ghcr.io/kiddingbaby/ansible-base:1.0.0 bash
```

**运行 Playbook**（挂载本地 Playbook）：

```bash
docker run -it --rm \
  -v $(pwd)/playbooks:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:1.0.0 \
  ansible-runner run /runner -p site.yml
```

**K3s 镜像**（扩展 base）：

```bash
docker run -it ghcr.io/kiddingbaby/ansible-k3s:1.0.0 bash
```

## 🔄 CI/CD 工作流

- **自动检测**：GitHub Actions 自动检测 `images/` 子目录变更。
- **版本计算**：读取单镜像 `VERSION` 文件或生成 `dev-<sha>` 标签。
- **智能构建**：仅重建受影响的镜像及其依赖（如修改 `base` 会触发 `k3s` 重构）。
- **仓库推送**：标签推送时自动构建并发布至 GHCR（非 PR 时）。

## 🛠️ 开发指南

### 扩展构建

添加新镜像变体：

1. 创建 `images/<name>/` 目录，包含 `Dockerfile` 和 `requirements.txt`，可选 `requirements.yml`。
2. （可选）创建 `images/<name>/VERSION` 文件写入语义版本号。
3. 若需特殊构建参数，更新 `docker-bake.hcl`。
4. GitHub Actions 会自动检测并包含该镜像。

### 测试

运行烟雾测试套件：

```bash
make build VERSION=1.0.0 TARGETS=base
docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:1.0.0 \
  ansible-runner run /runner -p site.yml
```

## 📝 许可证

MIT
