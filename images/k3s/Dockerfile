# syntax=docker/dockerfile:1.7
FROM base_image

ARG PIP_MIRROR

USER root

# k3s Python deps
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
      --no-cache-dir \
      --index-url "${PIP_MIRROR}" \
      -r /tmp/requirements.txt \
 && rm -f /tmp/requirements.txt

# k3s Ansible collections
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install \
      -r /tmp/requirements.yml \
 && rm -f /tmp/requirements.yml

USER ansible
