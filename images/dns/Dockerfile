# syntax=docker/dockerfile:1.7
FROM base_image

ARG PIP_MIRROR

USER root

# Copy BIND9 collection source from build context
COPY --from=ansible-bind9 . /tmp/ansible-bind9/

# DNS/BIND9 Ansible collections
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install \
      -r /tmp/requirements.yml \
 && rm -rf /tmp/requirements.yml /tmp/ansible-bind9

USER ansible
