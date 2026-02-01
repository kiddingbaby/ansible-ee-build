# 构建流程 Spec

## Docker Bake 配置

构建配置文件：`docker-bake.hcl`

### 变量

| 变量 | 默认值 | 说明 |
| ---- | ------ | ---- |
| `REGISTRY` | ghcr.io/kiddingbaby | 镜像仓库 |
| `IMAGE_*_TAG` | dev | 镜像标签 |
| `DEBIAN_MIRROR` | mirrors.tuna.tsinghua.edu.cn | Debian APT 镜像源 |
| `PIP_MIRROR` | `https://pypi.tuna.tsinghua.edu.cn/simple/` | Python 包索引 |
| `PLATFORMS` | linux/amd64,linux/arm64 | 构建平台 |
| `GITHUB_SHA` | - | Git commit SHA |

### 目标

| 目标 | 说明 |
| ---- | ---- |
| `_common` | 公共配置（平台、缓存、标签） |
| `base` | 基础镜像 |
| `dns` | DNS 镜像 |
| `k3s` | K3s 镜像 |
| `all` | 构建所有镜像 |

## 构建上下文依赖

镜像使用 Docker Bake 的 `contexts` 特性处理依赖：

```hcl
# dns/k3s 依赖 base 镜像
base_image = "target:base"

# dns 引用本地 collection
ansible-bind9 = "./ansible_collections/infra/dns"
```

**影响**：

- Base 镜像必须先构建（或包含在 bake 目标中）
- Base 的更改会触发依赖镜像重新构建
- 推荐使用 `docker buildx bake all` 一起构建

## 构建脚本

```text
scripts/
├── get-version.sh           # 从 VERSION 文件获取版本
├── generate-build-env.sh    # 生成构建环境变量
└── determine-targets.sh     # 确定增量构建目标
```

## CI/CD

### GitHub Actions 工作流

文件：`.github/workflows/build.yml`

### 触发条件

- 推送到 `main`、`master`、`release/*`
- Pull requests
- 手动触发（支持 `force_build_all` 选项）

### 构建流程

1. **检测变更**：分析 `.github/workflows/**`、`docker-bake.hcl`、`images/**`、`ansible_collections/**`
2. **计算标签**：根据事件类型生成镜像标签（见 `.github/actions/compute-tags`）
3. **确定目标**：智能选择需要构建的镜像（见 `.github/actions/determine-targets`）
4. **构建推送**：使用 `docker/bake-action` 和 GitHub Actions 缓存

### 智能重建

- 仅构建变更的镜像
- CI 文件变更或 `force_build_all` 时构建全部
- 变更检测路径：
  - `images/{name}/**` → 构建对应镜像
  - `ansible_collections/**` → 构建 dns 镜像
  - `docker-bake.hcl` → 构建全部

### 镜像推送

```text
ghcr.io/kiddingbaby/ansible-base:{tag}
ghcr.io/kiddingbaby/ansible-dns:{tag}
ghcr.io/kiddingbaby/ansible-k3s:{tag}
```

## 本地开发工作流

1. **修改**镜像目录（如 `images/k3s/`）
2. **本地构建**：`just build k3s`
3. **测试**：运行冒烟测试
4. **提交推送**：CI 自动检测变更并构建

## 重要说明

- **镜像源**：默认使用清华镜像源，加速国内构建
- **构建缓存**：CI 使用 GHA 缓存；本地使用 Docker BuildKit 缓存
- **多平台**：CI 构建 `linux/amd64,linux/arm64`；本地默认当前平台
- **非 root**：所有镜像以 `ansible` 用户运行
