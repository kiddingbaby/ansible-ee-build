# DNS 镜像烟雾测试指南

## 概述

这个测试环境用于验证 `ansible-bind9` 集合在 `ansible-dns` 容器中的集成。

## 测试环境组成

1. **dns-test-vm**: 一个 Debian 12 容器，模拟真实的目标主机
   - 运行 SSH 服务
   - 配置了 `ansible` 用户（密码：ansible）
   - 网络地址：172.20.0.10
   - 端口映射：2222 → 22

2. **ansible-dns 容器**: 包含 ansible-bind9 集合的执行环境

## 快速开始

### 1. 启动测试环境

```bash
cd images/dns/tests/smoke-test
docker compose up -d
```

### 2. 运行集成测试

```bash
# 测试集合集成和远程连接
docker run --rm \
  --network smoke-test_test-network \
  -v $PWD/project:/runner/project:Z \
  -v $PWD/inventory:/runner/inventory:Z \
  ghcr.io/kiddingbaby/ansible-dns:dev \
  ansible-runner run /runner -p test-without-systemd.yml
```

### 3. 运行本地验证

```bash
# 仅验证集合安装
docker run --rm \
  -v $PWD/project:/runner/project:Z \
  -v $PWD/inventory:/runner/inventory:Z \
  ghcr.io/kiddingbaby/ansible-dns:dev \
  ansible-runner run /runner -p test-localhost.yml
```

## 可用的测试 Playbook

### test-without-systemd.yml
验证 ansible-bind9 集合的完整集成：
- ✓ 检查集合角色文件存在性
- ✓ 测试 SSH 远程连接
- ✓ 验证 BIND9 软件包可用性
- ✓ 确认远程主机兼容性

### test-localhost.yml
快速验证集合本地安装：
- ✓ 列出已安装的集合
- ✓ 检查角色任务文件完整性

### run-dns-deploy.yml
完整的 BIND9 部署测试（需要 systemd 支持）

## 环境清理

```bash
docker compose down
```

## 故障排除

### 容器无法启动
```bash
docker compose logs dns-test-vm
```

### SSH 连接失败
```bash
# 检查容器状态
docker exec dns-test-vm systemctl status ssh
# 或手动测试 SSH
ssh -p 2222 ansible@localhost  # 密码：ansible
```

### 网络问题
```bash
# 检查网络
docker network inspect smoke-test_test-network
# 测试容器网络连通性
docker exec dns-test-vm ping -c 3 172.20.0.1
```

## 测试结果验证

成功的测试运行会显示：
```
✓ Role task file 'main.yml' verified
✓ Role task file 'install.yml' verified
✓ Role task file 'configure.yml' verified
✓ Role task file 'deploy_custom_configs.yml' verified
✓ BIND9 packages are available for installation
✓✓✓ ansible-bind9 collection is properly integrated and ready for deployment ✓✓✓
```

## 注意事项

1. 此测试环境使用简化的容器配置，不支持完整的 systemd 服务管理
2. 在 WSL2 环境中，完整的 systemd 容器可能无法正常工作
3. 测试主要验证：
   - 集合正确安装
   - SSH 连接正常
   - 软件包可用性
   - Playbook 语法正确
