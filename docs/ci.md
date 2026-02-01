# CI 镜像 Spec

## 概述

CI/CD 专用 Ansible Execution Environment，包含 ansible-lint、yamllint 等代码质量检查工具。

## 设计

- **基于 base 镜像**：继承所有 Ansible 运行时能力
- **职责分离**：运行时镜像保持精简，lint 工具仅在 CI 镜像中
- **可扩展**：后续可加入 molecule、pytest-ansible 等测试工具

## 包含组件

| 组件 | 版本 |
| ---- | ---- |
| 基础 | base 镜像全部组件 |
| ansible-lint | >=24.0.0 |
| yamllint | >=1.35.0 |

## 关键文件

```text
images/ci/
├── Dockerfile          # 基于 base 镜像安装 lint 工具
├── VERSION             # 版本号
└── requirements.txt    # Python 依赖（ansible-lint, yamllint）
```

## 构建

```bash
just build ci
```

## 使用

### Lint Ansible Collection

```bash
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/work \
  -w /work \
  -e HOME=/tmp \
  -e ANSIBLE_COLLECTIONS_PATH=/work \
  ghcr.io/kiddingbaby/ansible-ci:dev \
  ansible-lint ansible_collections/infra/dns/
```

### Lint 单个 Playbook

```bash
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/work \
  -w /work \
  -e HOME=/tmp \
  ghcr.io/kiddingbaby/ansible-ci:dev \
  ansible-lint playbook.yml
```

### YAML Lint

```bash
docker run --rm \
  -v $(pwd):/work:ro \
  -w /work \
  ghcr.io/kiddingbaby/ansible-ci:dev \
  yamllint .
```

## CI/CD 集成

### GitHub Actions 示例

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/kiddingbaby/ansible-ci:dev
    steps:
      - uses: actions/checkout@v4
      - name: Run ansible-lint
        run: ansible-lint ansible_collections/
        env:
          ANSIBLE_COLLECTIONS_PATH: ${{ github.workspace }}
```

## 环境变量

| 变量 | 说明 |
| ---- | ---- |
| `HOME` | 设为 `/tmp` 避免权限问题 |
| `ANSIBLE_COLLECTIONS_PATH` | Collection 搜索路径，lint collection 时需设置 |
