# 冒烟测试 (Smoke Test)

本目录包含用于验证 `ansible-ee-base` 镜像核心功能的测试用例。

## 目录结构

- `project/site.yml`: 一个简单的 "Hello World" Playbook。
- `inventory/`: 本地测试用的 Inventory。

## 如何运行测试

在构建完镜像后，挂载此目录到容器中运行：

```bash
# 在 ansible-ee-base 根目录下执行
docker run --rm \
  -v $(pwd)/tests/smoke-test/project:/runner/project \
  ansible-ee-base:latest
```

如果输出包含 `"msg": "Hello from ansible-runner template"`，则说明镜像功能正常。
