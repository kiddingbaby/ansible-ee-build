DOCKER ?= docker
TARGET ?= default
VERSION ?= dev
DO_PUSH ?= false

build:
	@echo "Building images (DO_PUSH=$(DO_PUSH))..."
	$(DOCKER) buildx bake -f docker-bake.hcl $(TARGET) \
		--set *.args.VERSION=$(VERSION) \
		$(if $(filter true,$(DO_PUSH)),--push,--load)

clean:
	@echo "Cleaning images..."
	-$(DOCKER) image rm -f ansible-ee-base:$(VERSION) || true
	-$(DOCKER) image rm -f ansible-ee-k3s:$(VERSION) || true
