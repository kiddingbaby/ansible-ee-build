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
# Common target
# ---------------------------
target "_common" {
  labels = {
    "org.opencontainers.image.source"   = "https://github.com/kiddingbaby/ansible-ee-build"
    "org.opencontainers.image.version"  = "${VERSION}"
    "org.opencontainers.image.licenses" = "MIT"
  }

  args = {
    VERSION = "${VERSION}"
  }
}

# ---------------------------
# Base image
# ---------------------------
target "base" {
  inherits   = ["_common"]
  context    = "ansible-ee-base"
  dockerfile = "Dockerfile"
  tags       = ["${REGISTRY}/ansible-ee-base:${VERSION}"]
}

# ---------------------------
# K3s release image
# ---------------------------
target "k3s" {
  inherits   = ["_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"
  target     = "release"
  args = {
    # 拆分 bake 时必须替换为真实 base 镜像
    BASE_IMAGE = "${REGISTRY}/ansible-ee-base:${VERSION}"
  }
  tags = ["${REGISTRY}/ansible-ee-k3s:${VERSION}"]
}

# ---------------------------
# Groups
# ---------------------------
group "base-only" {
  targets = ["base"]
  platforms = ["linux/amd64", "linux/arm64"]
}

group "k3s-only" {
  targets = ["k3s"]
  platforms = ["linux/amd64", "linux/arm64"]
}
