# ========================================
# LOCAL DEVELOPMENT BUILD ONLY
# Build images for local development and testing(Devcontainer, etc.)
# For CI/CD, GitHub Actions uses docker buildx bake directly
# ========================================

set dotenv-load

# Default recipe
default: help

# Show help
help:
    @echo "=========================================="
    @echo "Local Development Build"
    @echo "=========================================="
    @echo ""
    @echo "Usage:"
    @echo "  just build [TARGET] [PLATFORM]  Build images (defaults: all, linux/amd64)"
    @echo "  just print [TARGET] [PLATFORM]  Print bake config"
    @echo "  just smoke-sec-scan [IMAGE]     Run sec-scan smoke test"
    @echo "  just smoke-services [IMAGE]     Run ansible-services smoke test"
    @echo ""
    @echo "Examples:"
    @echo "  just build                    # build all with linux/amd64"
    @echo "  just build base               # build only base"
    @echo "  just build all linux/arm64    # build all with arm64"
    @echo "  just print                    # print bake config"
    @echo ""

# Show bake config
print TARGET="all" PLATFORM="linux/amd64":
    docker buildx bake -f docker-bake.hcl {{TARGET}} --print --set _common.platform={{PLATFORM}}

# Build images
build TARGET="all" PLATFORM="linux/amd64":
    docker buildx bake -f docker-bake.hcl {{TARGET}} --load --set _common.platform={{PLATFORM}}

# Run ansible-services smoke test
smoke-services IMAGE="ghcr.io/kiddingbaby/ansible-services:dev":
    docker run --rm -t \
      -v "$PWD/images/services/tests/smoke-test:/runner:Z" \
      {{IMAGE}} \
      ansible-runner run /runner -p verify-services.yml

# Run sec-scan smoke test
smoke-sec-scan IMAGE="ghcr.io/kiddingbaby/ansible-sec-scan:dev":
    docker run --rm -t \
      -v "$PWD/images/sec-scan/tests/smoke-test:/runner:Z" \
      {{IMAGE}} \
      ansible-runner run /runner -p verify-tools.yml
