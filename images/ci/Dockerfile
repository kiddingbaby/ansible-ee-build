# syntax=docker/dockerfile:1.7
FROM base_image

ARG PIP_MIRROR

USER root

COPY requirements.txt /tmp/requirements.txt
RUN pip install \
      --no-cache-dir \
      --index-url "${PIP_MIRROR}" \
      -r /tmp/requirements.txt \
 && rm -f /tmp/requirements.txt

USER ansible
