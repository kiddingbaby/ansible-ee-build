# This Makefile is only for local development and testing.
# CI/CD uses GitHub Actions and Docker Buildx Bake directly.

VERSION  	?= dev-$(shell git rev-parse --short=7 HEAD)
GITHUB_SHA  ?= $(shell git rev-parse HEAD)
TARGETS  	?= base

.PHONY: print build clean

print:
	docker buildx bake \
		-f docker-bake.hcl \
		--print \
		$(TARGETS)

build:
	docker buildx bake \
		-f docker-bake.hcl \
		--load \
		$(TARGETS)

clean:
	docker image rm -f \
		$(REGISTRY)/ansible-base:$(VERSION) \
		$(REGISTRY)/ansible-k3s:$(VERSION) || true
