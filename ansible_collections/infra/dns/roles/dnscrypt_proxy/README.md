# DNSCrypt Proxy Role

安装和配置 DNSCrypt Proxy，用于加密 DNS 解析。

## 变量

```yaml
# 监听地址
dnscrypt_listen_addresses:
  - '127.0.0.1:5353'

# DNS 提供商
dnscrypt_server_names:
  - cloudflare
  - quad9-dnscrypt-ip4-filter-pri

# HTTP 代理（用于受限网络）
dnscrypt_http_proxy: ""

# 缓存设置
dnscrypt_cache: true
dnscrypt_cache_size: 512

# 安全
dnscrypt_require_dnssec: true
```

所有变量见 `defaults/main.yml`。

## 使用方法

```yaml
- name: Deploy DNSCrypt Proxy
  hosts: dns_servers
  roles:
    - infra.dns.dnscrypt_proxy
```

### 配合 BIND9

```yaml
- hosts: dns_servers
  roles:
    - infra.dns.dnscrypt_proxy  # 监听 127.0.0.1:5353
    - infra.dns.bind9           # 转发到 DNSCrypt
```

架构：`客户端 → BIND9 (:53) → DNSCrypt (:5353) → 加密 DNS`

## 验证

```bash
# 服务状态
systemctl status dnscrypt-proxy

# 测试 DNS
dig @127.0.0.1 -p 5353 cloudflare.com

# 日志
journalctl -u dnscrypt-proxy -f
```
