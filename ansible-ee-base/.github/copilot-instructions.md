# Copilot 指南 — ansible-ee-base

# Copilot 使用指南 — `ansible-ee-base`

简要说明

此仓库构建通用 Ansible 执行环境（EE）镜像，采用多阶段 `Dockerfile`（`builder` → `release`）。镜像包含虚拟环境 `/opt/venv`，以及常用的 linters/formatters，便于在 CI 与容器内统一运行检查。

快速命令

- 构建镜像（本地或 CI）：`make build`
- 进入交互 shell：`make shell`

关键文件（快速索引）

- `Dockerfile` — 构建逻辑（复制 `/opt/venv` 与 collections）。
- `ansible.cfg` — 镜像内的 Ansible 配置（位于 `/ansible/ansible.cfg`）。
- `requirements.txt` — 镜像内安装的 Python 依赖（包含 linters），镜像包含 `ansible-runner`以支持 `ansible-runner` CLI 与 `ansible-builder` 的兼容性。
- `Makefile` — 常用任务（构建、lint、shell 等）。

约定与注意事项

- 所有运行时与检查相关的 Python 依赖在 `requirements.txt`（仓库根）中管理；修改后需重建镜像。
- 不要在基础镜像中硬编码应用级的 Ansible collection；如需 collection，请在上层或应用仓库单独安装并复制到 `/root/.ansible/collections`。
- 本镜像包含 `ansible-runner`，CLI 位于 `/opt/venv/bin/ansible-runner`（镜像 PATH 已包含 `/opt/venv/bin`）。
- 镜像构建支持代理与镜像源参数：`http_proxy` / `https_proxy` / `DEBIAN_MIRROR` / `PIP_MIRROR`。

调试与常见问题

- 构建失败：检查 Docker build 上下文与路径，或直接运行：

```bash
docker build -f Dockerfile -t ansible-ee:base .
```
- 进入容器 shell：`make shell`，或手动运行：

```bash
docker run --rm -it ansible-ee:base /bin/bash
```

