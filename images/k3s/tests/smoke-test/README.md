# k3s Smoke Test

前置要求：

- 三台可 SSH 访问的主机（1 server, 2 agents）
- 更新 `images/k3s/tests/smoke-test/inventory/hosts.yml` 中的主机 IP 和变量
- 确保你的 SSH 密钥已添加到目标主机

## 进入 devcontainer

## 测试 ping 连接

```bash
ansible all -i /runner/inventory/hosts.yml -m ping
```

## 部署 k3s

```bash
ansible-runner run /runner/ -p run-k3s-site.yml
```

## 验证

```bash
IDENT=smoke-$(date +%s)
ansible server -i /runner/inventory/hosts.yml -m command \
  -a "k3s kubectl wait --for=condition=Ready node --all --timeout=120s"
```
