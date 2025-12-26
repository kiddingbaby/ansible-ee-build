# syntax=docker/dockerfile:1.7

############################
# Builder stage
############################
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

############################
# Release stage
############################
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
    git \
    vim-tiny \
    gnupg \
    gpg-agent \
    tini \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /usr/share/ansible/collections /usr/share/ansible/collections

WORKDIR /ansible
COPY ansible.cfg /ansible/ansible.cfg

RUN mkdir -p /runner

RUN useradd -m -s /bin/bash ansible \
    && chown -R ansible:ansible /opt/venv /ansible /usr/share/ansible /runner

ENV ANSIBLE_COLLECTIONS_PATHS=/usr/share/ansible/collections

# 使用 tini 处理信号，防止容器孤儿进程
ENTRYPOINT ["/usr/bin/tini", "--"]

USER ansible

CMD ["ansible-runner", "run", "/runner"]
