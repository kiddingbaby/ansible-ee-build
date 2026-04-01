# syntax=docker/dockerfile:1.7
FROM base_image

ARG PIP_MIRROR

USER root

COPY ansible_collections/infra/dns /tmp/infra-dns
COPY images/services/requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
      --no-cache-dir \
      --index-url "${PIP_MIRROR}" \
      -r /tmp/requirements.txt \
 && rm -f /tmp/requirements.txt

COPY images/services/requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install \
      -r /tmp/requirements.yml \
 && rm -f /tmp/requirements.yml \
 && rm -rf /tmp/infra-dns

USER ansible
