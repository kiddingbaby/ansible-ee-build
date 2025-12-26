# ---------------------------
# Variables
# ---------------------------
variable "VERSION" {
  default = "dev"
}

variable "REGISTRY" {
  default = "ghcr.io/kiddingbaby"
}

# ---------------------------
# Common configuration
# ---------------------------
target "_common" {
  labels = {
    "org.opencontainers.image.source"  = "https://github.com/kiddingbaby/ansible-ee-build"
    "org.opencontainers.image.version" = "${VERSION}"
    "org.opencontainers.image.licenses" = "MIT"
  }
  args = {
    VERSION = "${VERSION}"
  }
}

# ---------------------------
# Base image target
# ---------------------------
target "base" {
  inherits   = ["_common"]
  context    = "ansible-ee-base"
  dockerfile = "Dockerfile"
  tags       = ["${REGISTRY}/ansible-ee-base:${VERSION}"]
}

# ---------------------------
# K3s image target
# ---------------------------
target "k3s" {
  inherits   = ["_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"
  target     = "release"
  # 关键点：将 target "base" 的输出映射为 base_image 上下文
  contexts = {
    base_image = "target:base"
  }
  tags = ["${REGISTRY}/ansible-ee-k3s:${VERSION}"]
}

# ---------------------------
# Build Groups
# ---------------------------
group "all" {
  targets   = ["base", "k3s"]
}