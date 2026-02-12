# CLAUDE.md

本文件为 Claude Code 在此仓库中工作时提供指导。

## 构建命令

```bash
# justfile（本地开发）
just build [target] [platform]    # target: base, dns, k3s, sec-scan; platform: linux/amd64, linux/arm64
just print [target]               # 打印 bake 配置

# docker buildx bake（CI/CD）
docker buildx bake -f docker-bake.hcl [target] --load
```

## 镜像层级

```text
base (Python 3.11 + ansible-core 2.17.14 + ansible-runner 2.4.2)
├── dns      (base + infra.dns collection)
├── k3s      (base + k3s-ansible collection)
├── ci       (base + ansible-lint + yamllint)
└── sec-scan (base + Semgrep + Gitleaks + Trivy + Syft + Cosign)
```

## 目录结构

```text
images/                    镜像定义（Dockerfile, requirements.*）
ansible_collections/       本地 Ansible collections
docs/                      详细文档
scripts/                   构建脚本
.github/                   CI/CD 工作流
```

## 测试模式

所有镜像使用 `ansible-runner` 测试，结构：

```text
images/{image}/tests/smoke-test/
├── inventory/hosts.yml
└── project/*.yml
```

## 文档索引

| 文档 | 内容 |
| ---- | ---- |
| [docs/base.md](docs/base.md) | Base 镜像 spec |
| [docs/dns.md](docs/dns.md) | DNS 镜像 spec |
| [docs/k3s.md](docs/k3s.md) | K3s 镜像 spec |
| [docs/ci.md](docs/ci.md) | CI 镜像 spec |
| [docs/sec-scan.md](docs/sec-scan.md) | Sec-Scan 镜像 spec |
| [docs/build.md](docs/build.md) | 构建流程、CI/CD、配置详解 |
| [docs/collections/dns.md](docs/collections/dns.md) | infra.dns collection spec |
| [~/.claude/skills/workflow/docs/INDEX.md] | Workflow skill 文档索引（phase 流程、命令参考） |
