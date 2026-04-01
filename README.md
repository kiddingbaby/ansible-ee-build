# ansible-ee-build

构建可复用的 Ansible 执行环境镜像。

它是 `~/homelab/infra` 三仓平台里的执行环境合同层：

repo 级 machine-facing discovery 现在收敛到 `automation/`；`docs/` 继续保留给人读的镜像说明和构建细节。

- `ansible-ee-build`: 执行环境镜像与 smoke contract
- `infra-system-init`: 主机基础层、快照、runner
- `infra-services`: `ns1` 服务态、入口、DNS、deploy/verify/rollback

## 仓库边界

本仓库负责：

- 可复用 EE 镜像定义
- 共享 collections / runtime dependencies
- 本地构建与 smoke contract

本仓库不负责：

- 主机 baseline 或 runner 生命周期
- `ns1` 服务部署真相源
- OpenResty / DNS / `SearXNG` 运行态管理

下游仓库只应依赖已文档化的镜像行为和 smoke contract，不应依赖 repo 内部目录布局、测试文件组织方式或本地构建细节。

## 镜像

- `ansible-base`: 基础 EE
- `ansible-dns`: DNS / BIND9 / DNSCrypt EE
- `ansible-k3s`: k3s 部署 EE
- `ansible-services`: host services 部署 EE
- `ansible-ci`: lint / CI 校验 EE
- `ansible-sec-scan`: 安全扫描 EE

## 稳定入口

- `just build [target] [platform]`
- `just print [target] [platform]`
- `just smoke-services [image]`
- `just smoke-sec-scan [image]`

repo 级 automation 入口见：`automation/README.md` 与 `automation/REPO-INDEX.json`。

## 快速开始

```bash
just build base      # 构建 base
just build dns       # 构建 DNS EE
just build services  # 构建 host services EE
just build k3s       # 构建 k3s
just build ci        # 构建 CI EE
just build sec-scan  # 构建安全扫描 EE
just smoke-services  # 运行 ansible-services 冒烟测试
```

测试见 [docs/](docs/)。

如果你是在 `infra overall` 视角下工作，优先把这里当作“执行环境提供方”，而不是 host/service state 仓库。

许可证: MIT
