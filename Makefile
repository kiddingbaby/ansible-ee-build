DOCKER ?= docker
TARGET ?= default
PUSH ?= false

VERSION  := $(shell cat VERSION)
REGISTRY ?= ghcr.io/kiddingbaby/ansible-ee-build

.PHONY: build
build:
	$(DOCKER) buildx bake \
		-f docker-bake.hcl \
		$(TARGET) \
		--set *.args.VERSION=$(VERSION) \
		--set *.args.REGISTRY=$(REGISTRY) \
		--set *.args.PUSH=$(PUSH)

.PHONY: clean
clean:
	-docker image rm $(REGISTRY)/ansible-ee-base:$(VERSION)
	-docker image rm $(REGISTRY)/ansible-ee-k3s:$(VERSION)
