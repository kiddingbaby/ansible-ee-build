# Sec-Scan 镜像 Spec

## 概述

安全扫描专用 Ansible Execution Environment，覆盖代码安全（SAST + secret detection）和制品安全（漏洞扫描 + SBOM + 签名）。采用 `sec-` 前缀命名体系，便于未来扩展 `sec-runtime`、`sec-comply` 等镜像。

## 设计

- **基于 base 镜像**：继承所有 Ansible 运行时能力
- **职责分离**：安全工具仅在 sec-scan 镜像中，运行时镜像保持精简
- **多架构支持**：Go binary 工具支持 amd64/arm64，Semgrep 仅 amd64
- **版本锁定**：所有工具版本通过 `ARG` 固定，便于 Renovate/Dependabot 自动升级

## 包含组件

| 组件 | 版本 | 类型 | 职责 |
| ---- | ---- | ---- | ---- |
| 基础 | base 镜像全部组件 | — | Ansible 运行时 |
| Semgrep | 1.67.0 | Python pip | SAST 静态代码分析 (amd64 only) |
| Gitleaks | 8.21.2 | Go binary | Git 密钥泄露检测 |
| Trivy | 0.58.2 | Go binary | 容器/依赖漏洞扫描 |
| Syft | 1.18.1 | Go binary | SBOM 生成 (SPDX/CycloneDX) |
| Cosign | 2.4.1 | Go binary | 容器镜像签名 + 验证 |

## 关键文件

```text
images/sec-scan/
├── Dockerfile          # 基于 base 镜像安装安全工具
├── VERSION             # 版本号
├── requirements.txt    # Python 依赖（semgrep）
└── tests/smoke-test/
    ├── inventory/hosts.yml
    └── project/verify-tools.yml
```

## 构建

```bash
just build sec-scan
```

## 测试

```bash
docker run --rm \
  -v $(pwd)/images/sec-scan/tests/smoke-test:/runner:Z \
  ghcr.io/kiddingbaby/ansible-sec-scan:dev \
  ansible-runner run /runner -p verify-tools.yml
```

## 使用

### Semgrep SAST 扫描

```bash
docker run --rm \
  -v $(pwd):/work:ro \
  -w /work \
  ghcr.io/kiddingbaby/ansible-sec-scan:dev \
  semgrep scan --config auto .
```

### Gitleaks 密钥检测

```bash
docker run --rm \
  -v $(pwd):/work:ro \
  -w /work \
  ghcr.io/kiddingbaby/ansible-sec-scan:dev \
  gitleaks detect --source /work
```

### Trivy 漏洞扫描

```bash
docker run --rm \
  -v $(pwd):/work:ro \
  -w /work \
  ghcr.io/kiddingbaby/ansible-sec-scan:dev \
  trivy fs /work
```

### Syft SBOM 生成

```bash
docker run --rm \
  -v $(pwd):/work:ro \
  -w /work \
  ghcr.io/kiddingbaby/ansible-sec-scan:dev \
  syft /work -o spdx-json
```

### Cosign 镜像签名验证

```bash
docker run --rm \
  ghcr.io/kiddingbaby/ansible-sec-scan:dev \
  cosign verify --key cosign.pub ghcr.io/example/image:tag
```

## 注意事项

| 事项 | 说明 |
| ---- | ---- |
| Semgrep arm64 | 无官方 wheel，Dockerfile 通过 `TARGETARCH` 条件跳过 |
| Release URL 命名 | Gitleaks 用 `x64`/`arm64`，Trivy 用 `64bit`/`ARM64`，Syft/Cosign 用 `amd64`/`arm64` |
| 版本升级 | 修改 Dockerfile `ARG` 和 `requirements.txt` |
