# BIND9 Role

安装和配置 BIND9 DNS 服务器，支持转发到 DNSCrypt Proxy。

## 变量

```yaml
# 监听地址
bind9_listen_on:
  - 127.0.0.1
  - 192.168.0.100

bind9_listen_on_v6:
  - "::1"

# 访问控制
bind9_allow_recursion:
  - localhost
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16

bind9_allow_query:
  - localhost
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16

# 转发（到 DNSCrypt Proxy）
bind9_forward: only
bind9_forwarders:
  - address: 127.0.0.1
    port: 5353

# DNSSEC
bind9_dnssec_validation: auto
```

所有变量见 `defaults/main.yml`。

## 使用方法

```yaml
- name: Deploy BIND9
  hosts: dns_servers
  roles:
    - infra.dns.bind9
```

### 配合 DNSCrypt Proxy

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
systemctl status named

# 测试 DNS
dig @127.0.0.1 google.com
dig @192.168.0.100 example.com

# 日志
journalctl -u named -f
```
