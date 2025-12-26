DOCKER ?= docker
TARGET ?= default
PUSH ?= false
VERSION ?= dev

.PHONY: build clean

build:
	ifeq ($(PUSH),true)
		@echo "Building and pushing image..."
		$(DOCKER) buildx bake -f docker-bake.hcl $(TARGET) --set *.args.VERSION=$(VERSION) --push
	else
		@echo "Building and loading image locally..."
		$(DOCKER) buildx bake -f docker-bake.hcl $(TARGET) --set *.args.VERSION=$(VERSION) --load
	endif

clean:
	-$(DOCKER) image rm ghcr.io/kiddingbaby/ansible-ee-base:$(VERSION) || true
	-$(DOCKER) image rm ghcr.io/kiddingbaby/ansible-ee-k3s:$(VERSION) || true
