# BIND9 自定义配置目录

在运行部署 playbook 之前，请将现有的 BIND9 配置文件放置在此目录中。

## 必需文件

至少需要以下文件：

```
bind9-custom/
├── named.conf                 # 主配置文件
├── named.conf.options         # 选项和安全设置
├── named.conf.local           # 本地区域定义
└── named.conf.default-zones   # 默认区域（可选）
```

## 可选文件

如果有自定义区域：

```
bind9-custom/
└── zones/
    ├── db.example.local       # example.local 的区域文件
    ├── db.192.168.0           # 192.168.0.0/24 的反向区域
    └── db.yourdomain.com      # 你的自定义区域
```

## 配置示例

如果没有现有配置，可以创建一个最小化配置：

### named.conf

```bind
include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
```

### named.conf.options

```bind
options {
    directory "/var/cache/bind";

    dnssec-validation auto;

    listen-on { 127.0.0.1; 192.168.0.101; };
    listen-on-v6 { ::1; };

    allow-recursion { 127.0.0.1; ::1; localnets; };
    allow-query { any; };
    allow-query-cache { 127.0.0.1; ::1; localnets; };

    forwarders {
        127.0.2.1;  # DNSCrypt Proxy
    };
    forward first;

    version none;
    hostname none;
};
```

### named.conf.local

```bind
// 在此添加本地区域
// 示例：
// zone "example.local" {
//     type master;
//     file "/etc/bind/zones/db.example.local";
// };
```

### named.conf.default-zones

```bind
zone "." {
    type hint;
    file "/usr/share/dns/root.hints";
};

zone "localhost" {
    type master;
    file "/etc/bind/db.local";
};

zone "127.in-addr.arpa" {
    type master;
    file "/etc/bind/db.127";
};

zone "0.in-addr.arpa" {
    type master;
    file "/etc/bind/db.0";
};

zone "255.in-addr.arpa" {
    type master;
    file "/etc/bind/db.255";
};
```

## 部署

配置文件放置完成后，运行：

```bash
# 从仓库根目录
docker run --rm -it \
  -v $(pwd)/images/dns/tests/smoke-test:/runner:Z \
  ghcr.io/kiddingbaby/ansible-dns:dev \
  ansible-runner run /runner -p deploy-full-dns.yml
```

## 说明

- 所有配置文件在部署前会使用 `named-checkconf` 进行验证
- 任何更改前会自动创建备份
- 如果验证失败，部署将停止，当前配置保持不变
