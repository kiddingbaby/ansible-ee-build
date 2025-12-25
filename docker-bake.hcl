############################################################
# docker-bake.hcl - Enterprise-grade, simplified
############################################################

# ---------------------------
# Variables
# ---------------------------
variable "VERSION" {
  default = "1.0.0"
}

variable "REGISTRY" {
  default = "ghcr.io/kiddingbaby"
}

variable "PLATFORMS" {
  default = "linux/amd64,linux/arm64"
}

# ---------------------------
# Common target
# ---------------------------
target "_common" {
  platforms = split(",", PLATFORMS)

  labels = {
    "org.opencontainers.image.source"   = "https://github.com/kiddingbaby/ansible-ee-build"
    "org.opencontainers.image.version"  = "${VERSION}"
    "org.opencontainers.image.licenses" = "MIT"
  }

  args = {
    VERSION  = "${VERSION}"
    REGISTRY = "${REGISTRY}"
  }
}

# ---------------------------
# Base target
# ---------------------------
target "base" {
  inherits   = ["_common"]
  context    = "ansible-ee-base"
  dockerfile = "Dockerfile"

  tags = [
    "${REGISTRY}/ansible-ee-base:${VERSION}",
  ]
}

# ---------------------------
# K3s release target
# ---------------------------
target "k3s" {
  inherits   = ["_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"
  target     = "release"
  depends_on = ["base"]

  args = {
    BASE_IMAGE = "${REGISTRY}/ansible-base:${VERSION}"
  }

  tags = [
    "${REGISTRY}/ansible-k3s:${VERSION}",
  ]
}

# ---------------------------
# K3s dev target (optional, for local dev/debug)
# ---------------------------
target "k3s-dev" {
  inherits   = ["_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"
  target     = "dev"
  depends_on = ["base"]

  args = {
    BASE_IMAGE = "${REGISTRY}/ansible-base:${VERSION}"
  }

  tags = [
    "${REGISTRY}/ansible-k3s-dev:${VERSION}",
  ]
}

# ---------------------------
# Default group (full release build)
# ---------------------------
group "default" {
  targets = ["base", "k3s"]
}
