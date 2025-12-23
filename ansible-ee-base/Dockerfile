# syntax=docker/dockerfile:1

# 阶段1：构建（包含构建依赖并安装 Python 依赖）
FROM python:3.11.14-slim-bookworm AS builder

ARG http_proxy
ARG https_proxy
ARG DEBIAN_MIRROR=mirrors.tuna.tsinghua.edu.cn
ARG PIP_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/

ENV HTTP_PROXY=$http_proxy \
    HTTPS_PROXY=$https_proxy \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# 使用清华镜像源并安装构建依赖（合并为单个 RUN，减少层）
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g; s|security.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    gcc \
    libssl-dev \
    python3-dev \
    build-essential \
    git \
    rsync \
    unzip \
    && rm -rf /var/lib/apt/lists/*


# 创建虚拟环境并升级打包工具
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install -i ${PIP_MIRROR} --upgrade pip setuptools wheel

COPY requirements.txt /tmp/requirements.txt

# 使用 BuildKit cache 加速 pip 安装（本地构建时请启用 DOCKER_BUILDKIT=1）
RUN --mount=type=cache,target=/root/.cache/pip /opt/venv/bin/pip install -i ${PIP_MIRROR} --upgrade-strategy=only-if-needed -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

# Ensure collections dir exists even if no collections were installed
RUN mkdir -p /usr/share/ansible/collections || true

# 阶段2：发布镜像（只包含运行时依赖与虚拟环境）
FROM python:3.11.14-slim-bookworm AS release

LABEL maintainer="HomeLab User" \
    org.opencontainers.image.title="Ansible Execution Environment Base" \
    org.opencontainers.image.description="Optimized base image with Ansible Core 2.17 and Runner" \
    org.opencontainers.image.vendor="HomeLab" \
    org.opencontainers.image.licenses="MIT"

ARG http_proxy
ARG https_proxy
ARG DEBIAN_MIRROR=mirrors.tuna.tsinghua.edu.cn

ENV ANSIBLE_CONFIG=/ansible/ansible.cfg \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# 仅安装运行时必须的系统包
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g; s|security.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    openssh-client \
    sshpass \
    git \
    iputils-ping \
    curl \
    vim-tiny \
    && rm -rf /var/lib/apt/lists/*

# 复制虚拟环境与 Ansible 集合
COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/share/ansible/collections /usr/share/ansible/collections

WORKDIR /ansible
COPY ansible.cfg /ansible/ansible.cfg

# Create runner directory for mount point
RUN mkdir -p /runner

# 创建非 root 用户并赋予 venv 与 collections 所有权
RUN useradd -m -s /bin/bash ansible \
    && chown -R ansible:ansible /opt/venv /ansible /usr/share/ansible /runner

ENV ANSIBLE_COLLECTIONS_PATHS=/usr/share/ansible/collections

USER ansible

# 默认运行命令：执行 ansible-runner
CMD ["ansible-runner", "run", "/runner", "-p", "site.yml"]
