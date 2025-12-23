SHELL := /bin/bash

# --- Variables ---
# Default to docker (compatible with nerdctl-docker-shim)
DOCKER ?= docker
# Build command: 'build' for nerdctl/legacy docker, 'buildx build' for modern docker multi-arch
BUILD_CMD ?= build
# Platforms for multi-arch build (e.g. linux/amd64,linux/arm64)
PLATFORMS ?= linux/amd64
# Registry prefix (e.g. ghcr.io/username/repo)
REGISTRY ?= 
PREFIX ?= $(if $(REGISTRY),$(REGISTRY)/,)

VERSION ?= $(shell cat VERSION 2>/dev/null || echo latest)

# Base Image Config
BASE_DIR := ansible-ee-base
BASE_DOCKERFILE := $(BASE_DIR)/Dockerfile
BASE_IMAGE_NAME := $(PREFIX)ansible-ee-base
BASE_IMAGE_TAG  := $(VERSION)
BASE_IMAGE_FULL := $(BASE_IMAGE_NAME):$(BASE_IMAGE_TAG)

# K3s Image Config
K3S_DIR := ansible-ee-k3s
K3S_DOCKERFILE := $(K3S_DIR)/Dockerfile
K3S_IMAGE_NAME := $(PREFIX)ansible-ee-k3s
K3S_IMAGE_TAG  := $(VERSION)
K3S_RELEASE_FULL := $(K3S_IMAGE_NAME):$(K3S_IMAGE_TAG)
K3S_DEV_FULL     := $(K3S_IMAGE_NAME):dev-$(K3S_IMAGE_TAG)

# Build Args (Proxy, Mirrors)
BUILD_ARGS :=
ifdef http_proxy
BUILD_ARGS += --build-arg http_proxy=$(http_proxy)
endif
ifdef https_proxy
BUILD_ARGS += --build-arg https_proxy=$(https_proxy)
endif
ifdef DEBIAN_MIRROR
BUILD_ARGS += --build-arg DEBIAN_MIRROR=$(DEBIAN_MIRROR)
endif
ifdef PIP_MIRROR
BUILD_ARGS += --build-arg PIP_MIRROR=$(PIP_MIRROR)
endif

.PHONY: help all base k3s k3s-dev clean clean-base clean-k3s shell-base shell-k3s shell-k3s-dev images push push-base push-k3s

help:
	@echo "Ansible EE Build System (Version: $(VERSION))"
	@echo "Build Targets:"
	@echo "  all            - Build all images (base -> k3s)"
	@echo "  base           - Build ansible-ee-base"
	@echo "  k3s            - Build ansible-ee-k3s (release)"
	@echo "  k3s-dev        - Build ansible-ee-k3s (dev)"
	@echo "Push Targets:"
	@echo "  push           - Push all images to registry"
	@echo "  push-base      - Push base image"
	@echo "  push-k3s       - Push k3s image"
	@echo "Shell Targets:"
	@echo "  shell-base     - Run bash in base image"
	@echo "  shell-k3s      - Run bash in k3s release image"
	@echo "  shell-k3s-dev  - Run bash in k3s dev image"
	@echo "Clean Targets:"
	@echo "  clean          - Remove all images"
	@echo "  clean-base     - Remove base images"
	@echo "  clean-k3s      - Remove k3s images"
	@echo "Misc:"
	@echo "  images         - List built images"

all: base k3s

# --- Base Image Targets ---
base:
	@echo ">>> Building $(BASE_IMAGE_FULL) for $(PLATFORMS)..."
	$(DOCKER) $(BUILD_CMD) --platform $(PLATFORMS) \
		-f $(BASE_DOCKERFILE) \
		-t $(BASE_IMAGE_FULL) \
		-t $(BASE_IMAGE_NAME):latest \
		$(BUILD_ARGS) $(BASE_DIR)/

shell-base:
	@echo ">>> Starting shell in $(BASE_IMAGE_FULL)..."
	$(DOCKER) run --rm -it -v $$(pwd):/ansible -w /ansible --entrypoint /bin/bash $(BASE_IMAGE_FULL)

clean-base:
	@echo ">>> Removing base images..."
	-@$(DOCKER) rmi -f $(BASE_IMAGE_FULL) $(BASE_IMAGE_NAME):latest || true

# --- K3s Image Targets ---
k3s: base
	@echo ">>> Building $(K3S_RELEASE_FULL) for $(PLATFORMS)..."
	$(DOCKER) $(BUILD_CMD) --platform $(PLATFORMS) \
		-f $(K3S_DOCKERFILE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE_FULL) \
		--target release \
		-t $(K3S_RELEASE_FULL) \
		-t $(K3S_IMAGE_NAME):latest \
		$(BUILD_ARGS) $(K3S_DIR)/

k3s-dev: k3s
	@echo ">>> Building $(K3S_DEV_FULL) for $(PLATFORMS)..."
	$(DOCKER) $(BUILD_CMD) --platform $(PLATFORMS) \
		-f $(K3S_DOCKERFILE) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE_FULL) \
		--target dev \
		-t $(K3S_DEV_FULL) \
		$(BUILD_ARGS) $(K3S_DIR)/

shell-k3s:
	@echo ">>> Starting shell in $(K3S_RELEASE_FULL)..."
	$(DOCKER) run --rm -it -v $$(pwd):/ansible -w /ansible --entrypoint /bin/bash $(K3S_RELEASE_FULL)

shell-k3s-dev:
	@echo ">>> Starting shell in $(K3S_DEV_FULL)..."
	$(DOCKER) run --rm -it -v $$(pwd):/ansible -w /ansible --entrypoint /bin/bash $(K3S_DEV_FULL)

clean-k3s:
	@echo ">>> Removing k3s images..."
	-@$(DOCKER) rmi -f $(K3S_DEV_FULL) $(K3S_RELEASE_FULL) $(K3S_IMAGE_NAME):latest || true

# --- Utilities ---
# Check builder status
check-builder:
	@echo "Checking builder ($(DOCKER))..."
	@$(DOCKER) version
	@echo "Ensure buildkitd is running if using nerdctl."

clean: clean-k3s clean-base

images:
	@$(DOCKER) images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' | grep -E '$(BASE_IMAGE_NAME)|$(K3S_IMAGE_NAME)' || true
