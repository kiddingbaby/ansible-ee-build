# ansible-ee-build

构建 Ansible 执行环境镜像。

## 镜像

- `ansible-base`: 基础 EE
- `ansible-k3s`: k3s 部署 EE
- `ansible-services`: host services 部署 EE

## 快速开始

```bash
just build base      # 构建 base
just build services  # 构建 host services EE
just build k3s       # 构建 k3s
just smoke-services  # 运行 ansible-services 冒烟测试
```

测试见 [docs/](docs/)。

许可证: MIT
