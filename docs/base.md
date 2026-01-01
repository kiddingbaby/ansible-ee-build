# Base 镜像测试

## 构建

```bash
just build base
```

## 测试

```bash
ansible-runner run /runner -p site.yml
```

## 成功

- 输出: `"msg": "Hello from ansible-runner"`
- 无错误
