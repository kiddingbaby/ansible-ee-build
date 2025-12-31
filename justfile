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