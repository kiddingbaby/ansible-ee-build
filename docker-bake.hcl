variable "GITHUB_SHA" { default = "unknown" }
variable "IMAGE_BASE_TAG" { default = "dev" }
variable "IMAGE_K3S_TAG" { default = "dev" }

variable "REGISTRY" { default = "ghcr.io/kiddingbaby" }
variable "DEBIAN_MIRROR" { default = "mirrors.tuna.tsinghua.edu.cn" }
variable "PIP_MIRROR" { default = "https://pypi.tuna.tsinghua.edu.cn/simple/" }
variable "PLATFORMS" { default = "linux/amd64" }

target "_common" {
  platforms = split(",", "${PLATFORMS}")
  cache_to  = ["type=gha,mode=max"]

  labels = {
    "org.opencontainers.image.source"   = "https://github.com/kiddingbaby/ansible-ee-build"
    "org.opencontainers.image.revision" = "${GITHUB_SHA}"
    "org.opencontainers.image.licenses" = "MIT"
    "org.opencontainers.image.vendor"   = "HomeLab"
  }
}

target "base" {
  inherits   = ["_common"]
  context    = "images/base"
  dockerfile = "Dockerfile"

  labels = {
    "org.opencontainers.image.title"       = "Ansible Execution Environment Base"
    "org.opencontainers.image.description" = "Minimal Ansible EE with Python 3.11, Ansible Core and Runner"
    "org.opencontainers.image.version"     = "${IMAGE_BASE_TAG}"
  }

  args = {
    DEBIAN_MIRROR = "${DEBIAN_MIRROR}"
    PIP_MIRROR    = "${PIP_MIRROR}"
  }

  tags = ["${REGISTRY}/ansible-base:${IMAGE_BASE_TAG}"]
}

target "k3s" {
  inherits   = ["_common"]
  context    = "images/k3s"
  dockerfile = "Dockerfile"
  cache_from = ["type=gha"]

  contexts = {
    base_image = "target:base"
  }

  args = {
    PIP_MIRROR = "${PIP_MIRROR}"
  }

  labels = {
    "org.opencontainers.image.title"       = "Ansible EE for k3s"
    "org.opencontainers.image.description" = "Ansible Execution Environment for k3s cluster management"
    "org.opencontainers.image.version"     = "${IMAGE_K3S_TAG}"
  }

  tags = ["${REGISTRY}/ansible-k3s:${IMAGE_K3S_TAG}"]
}

group "all" {
  targets = ["base", "k3s"]
}
