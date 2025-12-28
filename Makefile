VERSION  	?= dev-$(shell git rev-parse --short=7 HEAD)
GITHUB_SHA  ?= $(shell git rev-parse HEAD)
TARGETS  	?= base

.PHONY: print build clean

print:
	VERSION=$(VERSION) GITHUB_SHA=$(GITHUB_SHA) docker buildx bake \
		-f docker-bake.hcl \
		--print \
		$(TARGETS)

build:
	VERSION=$(VERSION) GITHUB_SHA=$(GITHUB_SHA) docker buildx bake \
		-f docker-bake.hcl \
		--load \
		$(TARGETS)

clean:
	docker image rm -f \
		$(REGISTRY)/ansible-base:$(VERSION) \
		$(REGISTRY)/ansible-k3s:$(VERSION) || true
