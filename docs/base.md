# Base 镜像 Spec

## 概述

核心 Ansible Execution Environment，提供 Python 3.11 + ansible-core + ansible-runner 运行环境。

## 设计

- **多阶段构建**：Builder 阶段编译 Python 依赖，Runtime 阶段精简
- **非 root 用户**：`ansible` (UID 1000)
- **工作目录**：`/runner`（ansible-runner 标准）
- **虚拟环境**：`/opt/venv`

## 包含组件

| 组件 | 版本 |
| ---- | ---- |
| Python | 3.11 (Debian Bookworm slim) |
| ansible-core | 2.17.14 |
| ansible-runner | 2.4.2 |
| 系统包 | openssh-client, sshpass, curl, git |

## 关键文件

```text
images/base/
├── Dockerfile          # 多阶段构建定义
├── requirements.txt    # Python 依赖
└── ansible.cfg         # Ansible 配置（启用 SSH pipelining）
```

## 标准路径

| 路径 | 用途 |
| ---- | ---- |
| `/runner/project` | Playbook 文件 |
| `/runner/inventory` | 清单文件 |
| `/runner/env` | 环境变量 |
| `/runner/artifacts` | ansible-runner 输出 |
| `/opt/venv` | Python 虚拟环境 |
| `/etc/ansible/ansible.cfg` | Ansible 配置 |

## 构建

```bash
just build base
```

## 测试

```bash
docker run --rm -it \
  -v $(pwd)/images/base/tests/smoke-test:/runner:Z \
  ghcr.io/kiddingbaby/ansible-base:dev \
  ansible-runner run /runner -p site.yml
```

## 验证

- 输出包含：`"msg": "Hello from ansible-runner"`
- 无错误退出
