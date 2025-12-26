# ---------------------------
# Variables
# ---------------------------
variable "VERSION" {
  default = "dev"
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
  platforms = split(",", replace(PLATFORMS, " ", ""))

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
  tags = ["${REGISTRY}/ansible-ee-base:${VERSION}"]
}

# ---------------------------
# K3s release image
# ---------------------------
target "k3s" {
  inherits   = ["_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"
  target     = "release"
  depends_on = ["base"]
  args = {
    BASE_IMAGE = "target:base"
  }
  tags = ["${REGISTRY}/ansible-ee-k3s:${VERSION}"]
}

# ---------------------------
# Groups
# ---------------------------
group "default" {
  targets = ["base", "k3s"]
}

group "base-group" {
  targets = ["base"]
}

group "k3s-group" {
  targets = ["k3s"]
}
