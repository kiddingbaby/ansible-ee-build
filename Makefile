REGISTRY ?= ghcr.io/kiddingbaby
VERSION  ?= dev-$(shell git rev-parse --short=7 HEAD)
BBAKE    ?= docker buildx bake

TARGETS ?= all

.PHONY: build load push clean

build:
	$(BBAKE) --file docker-bake.hcl \
		--set "VERSION=$(VERSION)" \
		--set "GITHUB_SHA=$(shell git rev-parse HEAD)" \
		--set "*.cache-from=type=gha" \
		--set "*.cache-to=type=gha,mode=max" \
		--push=true \
		$(TARGETS)

load:
	$(BBAKE) --file docker-bake.hcl \
		--set "VERSION=$(VERSION)" \
		--set "GITHUB_SHA=$(shell git rev-parse HEAD)" \
		--set "*.cache-from=type=gha" \
		--set "*.cache-to=type=gha,mode=max" \
		--push=false --load \
		$(TARGETS)

clean:
	docker image rm -f \
		$(REGISTRY)/ansible-ee-base:$(VERSION) \
		$(REGISTRY)/ansible-ee-k3s:$(VERSION) || true
