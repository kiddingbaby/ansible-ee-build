# ========================================
# LOCAL DEVELOPMENT BUILD ONLY
# For CI/CD, GitHub Actions uses docker buildx bake directly
# ========================================

set dotenv-load

# Configuration
DEFAULT_TARGETS := env("DEFAULT_TARGETS", "base")
BAKE_FILE := env("BAKE_FILE", "docker-bake.hcl")

# Default recipe
default: help

# Show help
help:
    @echo "=========================================="
    @echo "Local Development Build (NOT for CI/CD)"
    @echo "=========================================="
    @echo ""
    @echo "Usage:"
    @echo "  just build              Build base image with version from VERSION file"
    @echo "  just build base         Build base image"
    @echo "  just build k3s          Build k3s image"
    @echo "  just print              Print default bake config (base)"
    @echo "  just print base         Print base bake config"
    @echo "  just print k3s          Print k3s bake config"
    @echo "  just clean              Clean default target (base)"
    @echo "  just clean k3s          Clean k3s images"
    @echo ""
    @echo "Examples:"
    @echo "  just build"
    @echo "  just build k3s"
    @echo "  just print k3s"
    @echo "  just clean k3s"
    @echo ""

# Print bake config
print targets=DEFAULT_TARGETS:
    #!/usr/bin/env bash
    export $(scripts/generate-build-env.sh)
    docker buildx bake -f {{BAKE_FILE}} --print {{targets}}

# Build images
build targets=DEFAULT_TARGETS:
    #!/usr/bin/env bash
    export $(scripts/generate-build-env.sh)
    docker buildx bake -f {{BAKE_FILE}} --load {{targets}}



clean targets=DEFAULT_TARGETS:
    #!/usr/bin/env bash
    registry=${REGISTRY:-ghcr.io/kiddingbaby}
    for target in {{targets}}; do
        version=$(scripts/get-version.sh $target)
        echo "Cleaning $target ($version)..."
        docker image rm -f $registry/ansible-$target:$version || true
    done
