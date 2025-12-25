# 多阶段镜像：
# - `release`：基于通用 EE，安装 k3s collection（应用相关内容）
# - `dev`：在 release 基础上添加调试/测试工具（用于开发）
ARG BASE_IMAGE=ghcr.io/kiddingbaby/ansible-ee-build/ansible-ee-base:1.0.0 
FROM ${BASE_IMAGE} AS release

ARG DEBIAN_MIRROR=mirrors.tuna.tsinghua.edu.cn
ARG PIP_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/

COPY requirements.txt /tmp/requirements.txt
RUN /opt/venv/bin/pip install --no-cache-dir -i "${PIP_MIRROR}" -r /tmp/requirements.txt

COPY requirements.yml /tmp/requirements.yml
RUN /opt/venv/bin/ansible-galaxy collection install -r /tmp/requirements.yml

# dev 阶段：为开发/调试添加工具（仅用于本地开发镜像）
FROM release AS dev

# 切换为 root 以便安装系统包（release 阶段使用非 root 用户）
USER root

# 安装常用调试工具
RUN sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g; s|security.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    vim \
    nano \
    curl \
    jq \
    iputils-ping \
    tree \
    && rm -rf /var/lib/apt/lists/*

# 确保文件归 ansible 用户所有（release 阶段创建的目录可能被 root 修改）
RUN chown -R ansible:ansible /opt/venv /ansible /usr/share/ansible /runner || true

# 恢复为非 root 用户，保持与 release 阶段一致
USER ansible

CMD ["/bin/bash"]

