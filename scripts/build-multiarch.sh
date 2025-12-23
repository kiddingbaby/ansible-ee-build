#!/usr/bin/env bash
set -euo pipefail

# Build multi-arch image using buildx. Requires docker buildx and a registry for --push.
# Edit IMAGE and TAG as needed.
IMAGE=your-registry/ansible-ee-base
TAG=latest

# Example: enable experimental if needed
# export DOCKER_CLI_EXPERIMENTAL=enabled

# Create builder if doesn't exist
docker buildx create --use --name ansible-builder || true

# Build and push multi-arch image (amd64 + arm64)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ${IMAGE}:${TAG} \
  --push \
  ansible-ee-base/
