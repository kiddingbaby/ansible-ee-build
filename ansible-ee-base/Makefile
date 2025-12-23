SHELL := /bin/bash

# Simple Makefile for common tasks: build, lint, shell
IMAGE_BASE ?= ansible-ee:base

# Choose Dockerfile path depending on repository layout
DOCKERFILE := $(if $(wildcard ansible-ee-base/Dockerfile),ansible-ee-base/Dockerfile,Dockerfile)

# Build args collected from environment if present
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

.PHONY: help build shell images

# By default build only the runtime/base image.
build:
	@echo "Building $(IMAGE_BASE) using $(DOCKERFILE)"
	@docker build -f $(DOCKERFILE) -t $(IMAGE_BASE) $(BUILD_ARGS) .

shell:
	@echo "Starting shell in $(IMAGE_BASE) (runtime image)";
	docker run --rm -it -v $$(pwd):/ansible -w /ansible --entrypoint /bin/bash $(IMAGE_BASE)

images:
	docker images --format '{{.Repository}}:{{.Tag}} {{.Size}}' | egrep 'ansible-ee|vsc-ansible-ee-build|local/ansible-ee-build' || true
