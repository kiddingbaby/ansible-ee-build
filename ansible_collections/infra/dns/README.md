# kiddingbaby.bind9

生产就绪的 BIND9 Ansible Collection

## 使用方法

1. 将现有的 `/etc/bind/` 配置文件放置在 `roles/bind9/files/custom/`

2. 在 `tests/inventory.yml` 中更新 DNS 服务器 IP

3. 部署：

```bash
ansible-playbook -i tests/inventory.yml playbooks/deploy.yml
```

## 结构

- `roles/bind9/tasks/install.yml` - 安装系统 bind9 包
- `roles/bind9/tasks/configure.yml` - 启动并启用 bind9 服务
- `roles/bind9/tasks/deploy_custom_configs.yml` - 部署自定义配置并重载 bind9
- `roles/bind9/files/custom/` - 你现有的 /etc/bind/ 文件
