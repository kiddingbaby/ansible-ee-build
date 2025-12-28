REGISTRY ?= ghcr.io/kiddingbaby
VERSION  ?= dev-$(shell git rev-parse --short=7 HEAD)
TARGETS  ?= all

BAKE := docker buildx bake

SMOKE_PROJECT := tests/smoke-test/project

.PHONY: build clean smoke

build:
	$(BAKE) \
		-f docker-bake.hcl \
		--load \
		--set VERSION=$(VERSION) \
		--set GITHUB_SHA=$(shell git rev-parse HEAD) \
		--set REGISTRY=$(REGISTRY) \
		$(TARGETS)

smoke:
	@if [ ! -d "$(SMOKE_PROJECT)" ]; then \
	  echo "Smoke test project not found: $(SMOKE_PROJECT)"; exit 1; \
	fi
	docker run --rm \
	  -v $(PWD)/$(SMOKE_PROJECT):/runner/project:ro \
	  $(REGISTRY)/ansible-ee-base:$(VERSION) \
	  ansible-runner run /runner -p site.yml

clean:
	docker image rm -f \
		$(REGISTRY)/ansible-ee-base:$(VERSION) \
		$(REGISTRY)/ansible-ee-k3s:$(VERSION) || true
