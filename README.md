# Ansible Execution Environments (EE) 构建系统

本仓库用于构建和发布 **Ansible Execution Environments (EE)** 容器镜像，面向本地开发与 CI/CD 场景，采用 **Docker BuildKit + docker buildx bake** 作为唯一构建模型。

目标是：**可复现、低心智负担、企业级但不过度设计**。

---

## 一、整体架构

### 构建与发布

- **CI/CD**：GitHub Actions  
- **构建引擎**：Docker + BuildKit  
- **构建模型**：`docker-bake.hcl`（唯一事实源）
- **入口封装**：Makefile（thin wrapper）

### 镜像列表

| 镜像              | 说明                                      |
| ----------------- | ----------------------------------------- |
| `ansible-ee-base` | Ansible 执行环境基础镜像                  |
| `ansible-ee-k3s`  | 基于 base，扩展 K3s / Kubernetes 运维工具 |

---

## 二、镜像说明

### ansible-ee-base

生产就绪的 Ansible Execution Environment 基础镜像。

#### 核心特性

- **极简体积**
  - 基于 Debian Slim
  - 多阶段构建
- **安全默认**
  - 非 root 用户（`ansible`）
  - OCI 镜像规范
- **执行环境优化**
  - 预置 `ansible.cfg`
  - 启用 pipelining / ControlPersist
  - YAML 日志输出（`stdout_callback = yaml`）
- **版本策略**
  - Ansible Core ≥ 2.17
  - Ansible Runner ≥ 2.4

#### 关键路径

- Roles / Collections：`/usr/share/ansible`
- Project runtime：`/runner`

#### 扩展示例

```dockerfile
FROM ansible-ee-base:latest

COPY project /runner/project

CMD ["ansible-runner", "run", "/runner", "-p", "site.yml"]
```

---

### ansible-ee-k3s

在 `ansible-ee-base` 之上扩展，内置 K3s / Kubernetes 管理所需工具。

- 复用 base 中的 Ansible 运行环境
- 通过 `BASE_IMAGE` build-arg 显式依赖 base 镜像
- 构建依赖关系由 Bake 自动解析

---

## 三、构建模型说明（重要）

> **本项目的构建依赖、平台、tag、push/load 行为，全部定义在 `docker-bake.hcl` 中。**

- 不在 Makefile 中描述构建细节
- 不在 CI 中拼接 docker build 参数
- 不维护多套构建逻辑

### 构建依赖关系

```text
+-------------------+
| ansible-ee-base   |
+-------------------+
          |
          v
+-------------------+
| ansible-ee-k3s    |
+-------------------+

在 Bake 中通过 `depends_on` 声明，命令层无需关心顺序。

---

## 四、本地开发指南

### 前提条件

- Docker ≥ 24
- buildx 插件已启用（Docker Desktop / docker-buildx）
- 本项目默认 **docker-only**（不考虑 nerdctl / buildctl 直连）

---

### 1. 使用 Makefile（推荐）

#### 构建 base

```bash
make build TARGET=base
```

#### 构建 k3s（自动先构建 base）

```bash
make build TARGET=k3s
```

#### 构建全部镜像

```bash
make build
```

#### 推送到 Registry（CI / 发布）

```bash
make build TARGET=base PUSH=true
make build TARGET=k3s  PUSH=true
```

---

### 2. 直接使用 bake（无 Makefile）

适合 CI 或调试构建图。

```bash
# 查看构建计划
docker buildx bake --print

# 构建所有 targets
docker buildx bake

# 仅构建 base
docker buildx bake base

# 构建 k3s（自动触发 base）
docker buildx bake k3s
```

---

### 3. 调试与交互式 Shell

#### Base 镜像

```bash
docker run --rm -it \
  -v $(pwd):/workspace \
  -w /workspace \
  ansible-ee-base:latest \
  bash
```

#### K3s 镜像

```bash
docker run --rm -it \
  -v $(pwd):/workspace \
  -w /workspace \
  ansible-ee-k3s:latest \
  bash
```

---

### 4. 清理本地镜像

```bash
make clean
```

或手动：

```bash
docker image rm ansible-ee-base:latest ansible-ee-k3s:latest
```

---

## 五、CI / GitHub Actions 说明

- CI 使用 `docker buildx bake`
- 镜像 tag / 版本统一由：
  - `VERSION` 文件
  - GitHub Actions env
  - Bake variables
- 支持多架构构建（amd64 / arm64）

> CI 与本地 **使用完全相同的构建模型**，不存在“CI 特殊逻辑”。

---

## 六、设计原则（给维护者）

- **Bake 是构建真相**
- **Makefile 是 UX，不是构建系统**
- **不为暂不使用的 runtime 预留复杂度**
- **依赖关系只存在于构建模型中**

如果你需要：

- 多 tag（latest / git sha）
- build cache（gha / registry）
- SBOM / provenance
- 多环境 Registry

都应优先在 **docker-bake.hcl** 层扩展。

---

## 七、FAQ

### Q: 能否只构建单个镜像？

可以。直接指定 target，例如：

```bash
make build TARGET=base
```

### Q: 构建 k3s 会不会重复构建 base？

- 如果 base 已存在且 cache 命中，BuildKit 会自动复用
- 依赖顺序由 Bake 管理，无需人工干预

### Q: 为什么不支持 nerdctl？

这是一个 **明确的工程决策**：

- docker + buildx + bake 是当前最成熟、最稳定组合
- 避免为多 runtime 维护多套构建模型

---

## 八、许可证

MIT License
