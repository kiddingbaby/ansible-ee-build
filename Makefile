# Makefile for Ansible EE build

DOCKER ?= docker
TARGET ?= default
PUSH ?= false

VERSION  := $(shell cat VERSION)
OWNER    := kiddingbaby
REGISTRY_HOST ?= ghcr.io
REGISTRY ?= $(REGISTRY_HOST)/$(OWNER)

ifeq ($(PUSH),true)
    PUSH_FLAG := --push
else
    PUSH_FLAG := --load
endif

.PHONY: build
build:
	$(DOCKER) buildx bake \
		-f docker-bake.hcl \
		$(TARGET) \
		--set *.args.REGISTRY=$(REGISTRY) \
		--set *.args.VERSION=$(VERSION) \
		$(PUSH_FLAG)

.PHONY: clean
clean:
	-$(DOCKER) image rm $(REGISTRY)/ansible-ee-base:$(VERSION) || true
	-$(DOCKER) image rm $(REGISTRY)/ansible-ee-k3s:$(VERSION) || true
	-$(DOCKER) image rm $(REGISTRY)/ansible-ee-k3s-dev:$(VERSION) || true
