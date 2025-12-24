# 多阶段镜像：
# - `release`：基于通用 EE，安装 k3s collection（应用相关内容）
# - `dev`：在 release 基础上添加调试/测试工具（用于开发）
ARG BASE_IMAGE=ansible-ee-base:latest
FROM ${BASE_IMAGE} AS release

COPY requirements.txt /tmp/requirements.txt
RUN /opt/venv/bin/pip install --no-cache-dir -i ${PIP_MIRROR} -r /tmp/requirements.txt

COPY requirements.yml /tmp/requirements.yml
RUN /opt/venv/bin/ansible-galaxy collection install -r /tmp/requirements.yml

# dev 阶段：为开发/调试添加工具（仅用于本地开发镜像）
FROM release AS dev

ARG DEBIAN_MIRROR=mirrors.tuna.tsinghua.edu.cn
ARG PIP_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/

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

CMD ["/bin/bash"]
