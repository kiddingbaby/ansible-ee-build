# syntax=docker/dockerfile:1

### Builder stage
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

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install -i "${PIP_MIRROR}" --upgrade pip setuptools wheel

COPY requirements.txt /tmp/requirements.txt

# BuildKit cache 加速
RUN --mount=type=cache,target=/root/.cache/pip /opt/venv/bin/pip install -i "${PIP_MIRROR}" --upgrade-strategy=only-if-needed -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

RUN mkdir -p /usr/share/ansible/collections || true

### Runtime stage
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

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g; s|security.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    openssh-client \
    sshpass \
    iputils-ping \
    curl \
    vim-tiny \
    gnupg \
    gpg-agent \
    tini \
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

# Use tini as init to handle signals correctly in container environments
ENTRYPOINT ["/usr/bin/tini", "--"]

USER ansible

# 默认运行命令：执行 ansible-runner
CMD ["ansible-runner", "run", "/runner", "-p", "site.yml"]

# Optional healthcheck (usually not necessary for short-lived ansible-runner containers)
# Uncomment and adjust if your deployment expects a long-running service:
# HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
#   CMD /opt/venv/bin/ansible-runner --version >/dev/null 2>&1 || exit 1
