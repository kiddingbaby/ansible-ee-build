# K3s 镜像 Spec

## 概述

K3s 轻量级 Kubernetes 集群部署镜像，支持在线和离线安装。

## 镜像信息

| 项目 | 值 |
| ---- | --- |
| 基础镜像 | ghcr.io/kiddingbaby/ansible-base:dev |
| 包含 Collection | k3s-ansible (git commit 锁定) |
| 镜像标签 | ghcr.io/kiddingbaby/ansible-k3s:dev |

## 关键文件

```text
images/k3s/
├── Dockerfile          # 镜像构建定义
├── requirements.yml    # Collection 依赖（git 源，commit 锁定）
├── requirements.txt    # 额外 Python 依赖
└── VERSION             # 版本号
```

## 离线支持

镜像支持 airgap 安装，预下载的二进制文件位于 `/runner/offline`：

```text
/runner/offline/
├── k3s                 # k3s 二进制文件
└── k3s-airgap-images-*.tar  # 容器镜像
```

**注意**：离线文件较大，已 gitignore，需手动下载。

## 构建

```bash
just build k3s
```

## 测试

### 运行部署

```bash
docker run --rm -it \
  -v $(pwd)/images/k3s/tests/smoke-test:/runner:Z \
  -v ~/.ssh:/home/ansible/.ssh:ro,Z \
  ghcr.io/kiddingbaby/ansible-k3s:dev \
  ansible-runner run /runner -p run-k3s-site.yml --ident "smoke-$(date +%s)"
```

### 交互式测试

```bash
docker run --rm -it ghcr.io/kiddingbaby/ansible-k3s:dev bash
```

## 验证

部署后在目标主机验证：

```bash
# 等待所有节点就绪
k3s kubectl wait --for=condition=Ready node --all --timeout=120s

# 检查集群状态
k3s kubectl get nodes
k3s kubectl get pods -A
```

或通过 Ansible：

```bash
ansible server -i /runner/inventory/hosts.yml -m command \
  -a "k3s kubectl wait --for=condition=Ready node --all --timeout=120s --kubeconfig=/etc/rancher/k3s/k3s.yaml"
```

## 使用说明

- 镜像以 `ansible` 用户运行（非 root）
- SSH 密钥挂载到 `/home/ansible/.ssh`
- 工作目录为 `/runner`
- 清单文件需定义 `server` 和 `agent` 组
