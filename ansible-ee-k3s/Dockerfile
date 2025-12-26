# syntax=docker/dockerfile:1.7

############################
# Builder stage
############################
ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS builder

LABEL maintainer="HomeLab User" \
      org.opencontainers.image.title="K3S Runtime Ansible EE" \
      org.opencontainers.image.description="Ansible Execution Environment for k3s cluster management" \
      org.opencontainers.image.vendor="HomeLab" \
      org.opencontainers.image.licenses="MIT"

ARG PIP_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/
ARG ANSIBLE_GALAXY_SERVER=https://galaxy.ansible.com

# 容器内工作目录
WORKDIR /runner

USER root

### Python 依赖（仅 k3s 特有模块）
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/venv/bin/pip install \
    --no-cache-dir \
    --index-url "${PIP_MIRROR}" \
    -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt

### k3s 相关 Ansible Collections
COPY requirements.yml /tmp/requirements.yml
RUN /opt/venv/bin/ansible-galaxy collection install \
    -r /tmp/requirements.yml \
    --server "${ANSIBLE_GALAXY_SERVER}" \
    && rm -f /tmp/requirements.yml

############################
# Release stage
############################
FROM builder AS release

ARG DEBIAN_MIRROR=mirrors.tuna.tsinghua.edu.cn

# 安装开发/调试工具
RUN sed -i "s|http://deb.debian.org|https://${DEBIAN_MIRROR}|g; \
             s|http://security.debian.org|https://${DEBIAN_MIRROR}|g" \
        /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       vim \
       nano \
       curl \
       jq \
       iputils-ping \
       tree \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 修复权限，保证 ansible 用户可以访问所有资源
RUN chown -R ansible:ansible \
    /opt/venv \
    /usr/share/ansible \
    /runner || true

# 切换到 ansible 用户，保持与 base 镜像一致
USER ansible

# 默认 shell，用于挂载 /runner 执行 playbook
CMD ["/bin/bash"]
