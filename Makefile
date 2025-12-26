DOCKER ?= docker
TARGET ?= default
RUN_PUSH ?= false
VERSION ?= dev

PUSH_OPT := $(if $(filter true,$(RUN_PUSH)),--push,)

.PHONY: build clean

build:
	@echo "Building images (RUN_PUSH=$(RUN_PUSH))..."
	$(DOCKER) buildx bake -f docker-bake.hcl $(TARGET) --set *.args.VERSION=$(VERSION) $(PUSH_OPT)

clean:
	-$(DOCKER) image rm ghcr.io/kiddingbaby/ansible-ee-base:$(VERSION) || true
	-$(DOCKER) image rm ghcr.io/kiddingbaby/ansible-ee-k3s:$(VERSION) || true
