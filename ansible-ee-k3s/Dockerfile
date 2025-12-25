ARG BASE_IMAGE=ghcr.io/kiddingbaby/ansible-ee-build/ansible-ee-base:1.0.0

############################
# release stage
############################
FROM ${BASE_IMAGE} AS release

ARG PIP_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple/
ARG ANSIBLE_GALAXY_SERVER=https://galaxy.ansible.com

WORKDIR /runner

USER root

# ---- Python deps ----
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/venv/bin/pip install \
      --no-cache-dir \
      --index-url "${PIP_MIRROR}" \
      -r /tmp/requirements.txt

# ---- Ansible collections ----
COPY requirements.yml /tmp/requirements.yml
RUN /opt/venv/bin/ansible-galaxy collection install \
      -r /tmp/requirements.yml \
      --server "${ANSIBLE_GALAXY_SERVER}"

############################
# dev stage
############################
FROM release AS dev

ARG DEBIAN_MIRROR=mirrors.tuna.tsinghua.edu.cn

# Debian 12 使用 debian.sources
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

# 一致性修复
RUN chown -R ansible:ansible \
      /opt/venv \
      /usr/share/ansible \
      /runner || true

USER ansible

CMD ["/bin/bash"]
