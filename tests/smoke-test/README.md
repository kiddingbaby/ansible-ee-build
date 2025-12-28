# 冒烟测试 (Smoke Test)

本目录包含用于验证 `ansible-base` 镜像核心功能的测试用例。

## 目录结构

- `project/site.yml`: 一个简单的 "Hello World" Playbook。

## 如何运行测试

```bash
# 构建测试镜像
REGISTRY=ghcr.io/kiddingbaby TARGETS=base VERSION=dev-smoke-test
make build

# 测试运行
docker run --rm \
  -v $(pwd)/tests/smoke-test/project:/runner/project:ro \
  $(REGISTRY)/ansible-base:$(VERSION) \
  ansible-runner run /runner -p site.yml

# 清理测试镜像
docker image rm -f $(REGISTRY)/ansible-base:$(VERSION) || true
```

如果输出包含 `"msg": "Hello from ansible-runner template"`，则说明镜像功能正常。
