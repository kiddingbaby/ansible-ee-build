
# ansible-ee-build

[English](./README.md) | [中文文档](./README.zh-CN.md)

精简、可复现的 Ansible Execution Environments (EE) 镜像构建系统。

## 核心特性

- 构建引擎：Docker BuildKit + `docker buildx bake`（HCL）
- 构建定义：`docker-bake.hcl`（唯一事实源）
- 操作入口：`Makefile`（轻量封装）

## 镜像

- `ansible-ee-base`：运行时基础镜像（非 root 用户，预置 venv 与 collections）
- `ansible-ee-k3s`：基于 base 扩展，集成 K3s/Kubernetes 运维工具

## 快速开始

构建 base：

```bash
make build TARGET=base
```

构建 k3s（自动处理 base 依赖）：

```bash
make build TARGET=k3s
```

构建全部：

```bash
make build
```

推送（需登录 `ghcr.io` 且 PAT 包含 `write:packages`）：

```bash
make build TARGET=k3s PUSH=true
```

## 调试

交互式 shell：

```bash
docker run --rm -it ghcr.io/kiddingbaby/ansible-ee-build/ansible-ee-base:1.0.0 bash
```

## CI/CD

- CI 与本地使用相同的 bake 定义。
- 镜像版本由仓库根目录 `VERSION` 文件驱动。

## 维护者说明

- 构建逻辑（tags/platforms/args）应优先在 `docker-bake.hcl` 中定义。
- 避免在 Makefile/CI 中重复定义构建参数。

## 许可证

MIT
