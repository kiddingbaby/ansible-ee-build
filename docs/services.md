# Services 镜像 Spec

## 概述

`ansible-services` 是 host-level services 的标准执行环境，供后续 `infra-services` 这类仓库消费。

目标不是承载具体的 `ns1` 状态，而是提供一套稳定的执行面：

- `ansible-runner`
- Docker / Compose 相关 Python 依赖
- host-services 常用 collection
- 本地 `infra.dns` collection

## 镜像信息

| 项目 | 值 |
| ---- | --- |
| 基础镜像 | `ghcr.io/kiddingbaby/ansible-base:dev` |
| 包含 Collection | `community.docker`、`community.general`、`ansible.posix`、`infra.dns` |
| 镜像标签 | `ghcr.io/kiddingbaby/ansible-services:dev` |

## 关键文件

```text
images/services/
├── Dockerfile
├── requirements.txt
├── requirements.yml
├── VERSION
└── tests/smoke-test/
    ├── inventory/hosts.yml
    └── project/verify-services.yml
```

## 构建

```bash
just build services
```

## 冒烟测试

### 推荐入口

```bash
just smoke-services
```

默认会运行：

```bash
docker run --rm -t \
  -v "$PWD/images/services/tests/smoke-test:/runner:Z" \
  ghcr.io/kiddingbaby/ansible-services:dev \
  ansible-runner run /runner -p verify-services.yml
```

### Smoke 覆盖

当前 smoke 只验证最小执行合同：

- `ansible-runner` 可执行
- 必需 collection 已安装
- `community.docker` / `ansible.posix` 模块文档可加载
- Python 可以导入 `ansible_runner` 与 `docker`
- 可以完成一个最小 compose 样例渲染

## 运行约束

- 镜像继续以非 root 的 `ansible` 用户作为默认执行用户
- 本地 `infra.dns` collection 从仓库上下文复制进入镜像
- `infra-services` 只能依赖已发布的 `ansible-services` 行为，不能依赖 repo 中未发布的临时修改

## 适用边界

`ansible-services` 适合承载：

- Docker Compose 应用管理
- host-level service orchestration
- OpenResty / DNS 相关的 Ansible 执行依赖

`ansible-services` 不承载：

- `ns1` inventory
- 具体业务服务模板
- 任何仓库专属 secrets 或主机状态
