# K3s 镜像测试

## 构建

```bash
just build k3s
```

## 部署

```bash
ansible-runner run /runner -p run-k3s-site.yml --ident "smoke-$(date +%s)"
```

## 验证

```bash
ansible server -i /runner/inventory/hosts.yml -m command \
  -a "k3s kubectl wait --for=condition=Ready node --all --timeout=120s --kubeconfig=/etc/rancher/k3s/k3s.yaml"
```
