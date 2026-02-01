# infra.dns Collection Spec

## 元数据

| 字段 | 值 |
| ---- | --- |
| namespace | infra |
| name | dns |
| version | 1.0.0 |
| license | Apache-2.0 |
| repository | <https://github.com/kiddingbaby/ansible-dns> |
| requires_ansible | >=2.15.0 |

## Roles

### bind9

BIND9 DNS 服务器部署。

**默认变量** (`defaults/main.yml`)：

| 变量 | 默认值 | 说明 |
| ---- | ------ | ---- |
| `bind9_listen_on` | `[127.0.0.1, {{ ansible_default_ipv4.address }}]` | IPv4 监听地址 |
| `bind9_listen_on_v6` | `[::1]` | IPv6 监听地址 |
| `bind9_allow_recursion` | `[localhost, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, fd00::/8]` | 允许递归查询的网段 |
| `bind9_allow_query` | 同上 | 允许查询的网段 |
| `bind9_forward` | `only` | 转发模式 |
| `bind9_forwarders` | `[{address: 127.0.0.1, port: 5353}]` | 转发目标（DNSCrypt Proxy） |
| `bind9_dnssec_validation` | `auto` | DNSSEC 验证模式 |

**任务流程**：安装 BIND9 → 配置 named.conf.options → 启动服务

### dnscrypt_proxy

DNSCrypt Proxy 加密 DNS 代理部署。

**默认变量** (`defaults/main.yml`)：

| 变量 | 默认值 | 说明 |
| ---- | ------ | ---- |
| `dnscrypt_proxy_listen_addresses` | `[127.0.0.1:5353]` | 监听地址 |
| `dnscrypt_proxy_server_names` | `[cisco-open-dns, adguard-dns, cloudflare, ...]` | 上游 DNS 服务器 |
| `dnscrypt_proxy_http_proxy` | `""` | HTTP 代理（可选） |
| `dnscrypt_proxy_cache` | `true` | 启用缓存 |
| `dnscrypt_proxy_cache_size` | `512` | 缓存大小 |
| `dnscrypt_proxy_cache_min_ttl` | `60` | 最小 TTL |
| `dnscrypt_proxy_cache_max_ttl` | `86400` | 最大 TTL |
| `dnscrypt_proxy_require_dnssec` | `true` | 要求 DNSSEC |
| `dnscrypt_proxy_max_clients` | `250` | 最大客户端数 |
| `dnscrypt_proxy_log_file` | `/var/log/dnscrypt-proxy/dnscrypt-proxy.log` | 日志文件 |
| `dnscrypt_proxy_query_log` | `/var/log/dnscrypt-proxy/query.log` | 查询日志 |
| `dnscrypt_proxy_nx_log` | `/var/log/dnscrypt-proxy/nx.log` | NXDOMAIN 日志 |
| `dnscrypt_proxy_sources_url` | `https://download.dnscrypt.info/...` | 解析器列表 URL |
| `dnscrypt_proxy_sources_cache` | `/var/cache/dnscrypt-proxy/public-resolvers.md` | 解析器缓存路径 |
| `dnscrypt_proxy_sources_key` | `RWQf6LRCGA9i53ml...` | Minisign 公钥 |
| `dnscrypt_proxy_sources_refresh_delay` | `99999` | 刷新延迟（秒） |

**任务流程**：安装 DNSCrypt Proxy → 配置 dnscrypt-proxy.toml → 启动服务

## Playbooks

| Playbook | 说明 |
| -------- | ---- |
| `deploy_bind9.yml` | 仅部署 BIND9 |
| `deploy_dnscrypt_proxy.yml` | 仅部署 DNSCrypt Proxy |

## 目录结构

```text
ansible_collections/infra/dns/
├── CHANGELOG.md
├── galaxy.yml
├── LICENSE
├── README.md
├── meta/
│   └── runtime.yml
├── playbooks/
│   ├── deploy_bind9.yml
│   └── deploy_dnscrypt_proxy.yml
└── roles/
    ├── bind9/
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   ├── tasks/main.yml
    │   └── templates/
    │       ├── named.conf.j2
    │       ├── named.conf.local.j2
    │       ├── named.conf.options.j2
    │       └── zone.j2
    └── dnscrypt_proxy/
        ├── defaults/main.yml
        ├── handlers/main.yml
        ├── tasks/main.yml
        └── templates/dnscrypt-proxy.toml.j2
```

## Lint 检查

```bash
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/work \
  -w /work \
  -e HOME=/tmp \
  -e ANSIBLE_COLLECTIONS_PATH=/work \
  ghcr.io/kiddingbaby/ansible-ci:dev \
  ansible-lint ansible_collections/infra/dns/
```
