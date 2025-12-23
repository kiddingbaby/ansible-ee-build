# 多阶段镜像：
# - `release`：基于通用 EE，安装 k3s collection（应用相关内容）
# - `dev`：在 release 基础上添加调试/测试工具（用于开发）
FROM ansible-ee:base AS release

COPY requirements.yml /tmp/requirements.yml
RUN test -s /tmp/requirements.yml || (echo "ERROR: requirements.yml not found or empty" >&2; exit 1) && \
    /opt/venv/bin/ansible-galaxy collection install -r /tmp/requirements.yml

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

# 在开发镜像中安装 nerdctl，以便在容器内测试 containerd/nerdctl 场景
ARG NERDCTL_VERSION=1.7.6
RUN curl -L -o /tmp/nerdctl.tar.gz "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz" \
    && tar -C /usr/local/bin -xzf /tmp/nerdctl.tar.gz \
    && rm /tmp/nerdctl.tar.gz \
    && ln -s /usr/local/bin/nerdctl /usr/local/bin/docker

# 安装开发/测试相关 Python 包
RUN pip install -i ${PIP_MIRROR} --no-cache-dir ansible-lint

CMD ["/bin/bash"]
