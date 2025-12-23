
# Configurable variables
DOCKER ?= docker
DRY_RUN ?= false

BASE_DOCKERFILE := ansible-ee-base/Dockerfile
K3S_DOCKERFILE  := ansible-ee-k3s/Dockerfile

BASE_TAG := ansible-ee:base
K3S_RELEASE_TAG := ansible-ee-k3s:release
K3S_DEV_TAG := ansible-ee-k3s:dev

.PHONY: help build-base build-k3s-release build-k3s-dev build-all images clean

# When DRY_RUN=true, prefix docker invocations with echo for safety
ifeq ($(DRY_RUN),true)
DOCKER_BUILD := echo $(DOCKER) build
else
DOCKER_BUILD := $(DOCKER) build
endif

help:
	@echo "Usage: make [target] [VAR=value]"
	@echo
	@echo "Targets:"
	@echo "  build-base            Build base EE image"
	@echo "  build-k3s-release     Build k3s release image (no dev tools)"
	@echo "  build-k3s-dev         Build k3s dev image (with dev tools)"
	@echo "  build-all             Build base and k3s release images"
	@echo "  images                Show built images"
	@echo "  clean                 Remove built images (force)"
	@echo
	@echo "Examples:"
	@echo "  make build-base"
	@echo "  make build-k3s-dev DRY_RUN=true"

build-base:
	$(DOCKER_BUILD) -f $(BASE_DOCKERFILE) -t $(BASE_TAG) .

build-k3s-release: build-base
	$(DOCKER_BUILD) -f $(K3S_DOCKERFILE) --target release -t $(K3S_RELEASE_TAG) .

build-k3s-dev: build-k3s-release
	$(DOCKER_BUILD) -f $(K3S_DOCKERFILE) --target dev -t $(K3S_DEV_TAG) .

build-all: build-base build-k3s-release

images:
	@$(DOCKER) images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' | grep -E 'ansible-ee|ansible-ee-k3s' || true

clean:
	-@$(DOCKER) rmi -f $(K3S_DEV_TAG) $(K3S_RELEASE_TAG) $(BASE_TAG) || true
