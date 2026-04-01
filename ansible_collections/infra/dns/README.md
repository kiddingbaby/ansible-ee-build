# infra.dns

`infra.dns` 是当前 `ansible-ee-build` 内置的本地 collection，提供：

- `infra.dns.bind9`
- `infra.dns.dnscrypt_proxy`

它被 `ansible-dns` 和 `ansible-services` 镜像直接打包进执行环境。

## 使用方法

仅部署 BIND9：

```bash
ansible-playbook -i inventory/hosts.yml ansible_collections/infra/dns/playbooks/deploy_bind9.yml
```

仅部署 DNSCrypt Proxy：

```bash
ansible-playbook -i inventory/hosts.yml ansible_collections/infra/dns/playbooks/deploy_dnscrypt_proxy.yml
```

如果你在本仓内验证 collection 集成，优先使用：

```bash
cd images/dns/tests/smoke-test
docker compose up -d
docker run --rm \
  --network smoke-test_test-network \
  -v "$PWD/project:/runner/project:Z" \
  -v "$PWD/inventory:/runner/inventory:Z" \
  ghcr.io/kiddingbaby/ansible-dns:dev \
  ansible-runner run /runner -p test-without-systemd.yml
```

## 结构

- `playbooks/deploy_bind9.yml` - 仅部署 BIND9
- `playbooks/deploy_dnscrypt_proxy.yml` - 仅部署 DNSCrypt Proxy
- `roles/bind9/tasks/main.yml` - 安装、模板渲染和服务启用
- `roles/dnscrypt_proxy/tasks/main.yml` - 安装、模板渲染和服务启用
- `roles/*/defaults/main.yml` - role 默认变量
