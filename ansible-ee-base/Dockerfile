# syntax=docker/dockerfile:1.7

############################
# Builder
############################
FROM python:3.11-slim-bookworm AS builder

ARG DEBIAN_MIRROR
ARG PIP_MIRROR

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g; \
            s|security.debian.org|${DEBIAN_MIRROR}|g" \
        /etc/apt/sources.list.d/debian.sources \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      gcc \
      python3-dev \
      libssl-dev \
      git \
 && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv \
 && /opt/venv/bin/pip install \
      --no-cache-dir \
      --index-url "${PIP_MIRROR}" \
      --upgrade pip setuptools wheel

COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    /opt/venv/bin/pip install \
      --no-cache-dir \
      --index-url "${PIP_MIRROR}" \
      -r /tmp/requirements.txt \
 && rm -f /tmp/requirements.txt

############################
# Runtime
############################
FROM python:3.11-slim-bookworm

ARG DEBIAN_MIRROR

ENV PATH="/opt/venv/bin:$PATH" \
    ANSIBLE_CONFIG=/ansible/ansible.cfg \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    sed -i "s|deb.debian.org|${DEBIAN_MIRROR}|g; \
            s|security.debian.org|${DEBIAN_MIRROR}|g" \
        /etc/apt/sources.list.d/debian.sources \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-client \
      sshpass \
      curl \
      git \
      gnupg \
      tini \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv

WORKDIR /ansible
COPY ansible.cfg /ansible/ansible.cfg

RUN useradd -m -s /bin/bash ansible \
 && mkdir -p /runner \
 && chown -R ansible:ansible /opt/venv /ansible /runner

USER ansible

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["ansible-runner", "run", "/runner"]
