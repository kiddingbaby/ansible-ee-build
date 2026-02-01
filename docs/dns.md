# DNS 镜像 Spec

## 概述

DNS 服务器管理镜像，包含 BIND9 + DNSCrypt Proxy 部署能力。

## 架构

```text
Client → BIND9 (:53) → DNSCrypt Proxy (:5353) → 加密 DNS 上游
```

- **BIND9**：本地 DNS 服务器，处理递归查询
- **DNSCrypt Proxy**：加密 DNS 代理，转发至安全上游

## 镜像信息

| 项目 | 值 |
| ---- | --- |
| 基础镜像 | ghcr.io/kiddingbaby/ansible-base:dev |
| 包含 Collection | infra.dns v1.0.0 |
| 镜像标签 | ghcr.io/kiddingbaby/ansible-dns:dev |

## 关键文件

```text
images/dns/
├── Dockerfile          # 镜像构建定义
├── requirements.yml    # Collection 依赖（引用本地上下文）
└── VERSION             # 版本号

ansible_collections/infra/dns/
├── galaxy.yml          # Collection 元数据
├── roles/
│   ├── bind9/          # BIND9 部署 role
│   └── dnscrypt_proxy/ # DNSCrypt Proxy 部署 role
└── playbooks/          # 部署 playbook
```

## 构建

```bash
just build dns
```

## 测试

### 验证 Collection 安装

```bash
docker run --rm ghcr.io/kiddingbaby/ansible-dns:dev \
  ansible-galaxy collection list | grep infra.dns
```

### 运行冒烟测试

```bash
docker run --rm -it \
  -v $(pwd)/images/dns/tests/smoke-test:/runner:Z \
  -v ~/.ssh:/home/ansible/.ssh:ro,Z \
  ghcr.io/kiddingbaby/ansible-dns:dev \
  ansible-runner run /runner -p run-dns-deploy.yml
```

### 交互式测试

```bash
docker run --rm -it ghcr.io/kiddingbaby/ansible-dns:dev bash
```

## 验证

部署后在目标主机验证：

```bash
# 检查 BIND9 服务
systemctl status named

# 检查 DNSCrypt Proxy 服务
systemctl status dnscrypt-proxy

# DNS 查询测试
dig @127.0.0.1 example.com
```

## 使用说明

- 镜像以 `ansible` 用户运行（非 root）
- SSH 密钥挂载到 `/home/ansible/.ssh`
- 工作目录为 `/runner`

## 相关文档

- [infra.dns Collection Spec](collections/dns.md)
