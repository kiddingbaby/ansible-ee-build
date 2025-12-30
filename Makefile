# ========================================
# LOCAL DEVELOPMENT BUILD ONLY
# For CI/CD, GitHub Actions uses docker buildx bake directly
# ========================================

VERSION  	?= dev-$(shell git rev-parse --short=7 HEAD)
GITHUB_SHA  ?= $(shell git rev-parse HEAD)
TARGETS  	?= base

.PHONY: help print build clean

help:
	@echo "=========================================="
	@echo "Local Development Build (NOT for CI/CD)"
	@echo "=========================================="
	@echo ""
	@echo "Usage:"
	@echo "  make build              Build base image with default version"
	@echo "  make build VERSION=X.Y  Build base image with custom version"
	@echo "  make build TARGETS=k3s  Build k3s image"
	@echo "  make print              Print bake config (for debugging)"
	@echo "  make clean              Remove images"
	@echo ""
	@echo "Examples:"
	@echo "  make build VERSION=1.2.0"
	@echo "  make build VERSION=1.2.0 TARGETS=k3s"
	@echo ""

print:
	VERSION=$(VERSION) docker buildx bake \
		-f docker-bake.hcl \
		--print \
		$(TARGETS)

build:
	VERSION=$(VERSION) docker buildx bake \
		-f docker-bake.hcl \
		--load \
		$(TARGETS)

clean:
	docker image rm -f \
		$(REGISTRY)/ansible-base:$(VERSION) \
		$(REGISTRY)/ansible-k3s:$(VERSION) || true
