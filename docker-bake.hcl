variable "VERSION" { default = "" }
variable "GITHUB_SHA" { default = "" }

variable "REGISTRY" { default = "ghcr.io/kiddingbaby" }
variable "DEBIAN_MIRROR" { default = "mirrors.tuna.tsinghua.edu.cn" }
variable "PIP_MIRROR" { default = "https://pypi.tuna.tsinghua.edu.cn/simple/" }
variable "GITHUB_REPOSITORY" { default = "https://github.com/kiddingbaby/ansible-ee-build" }

variable "IMAGE_BASE" { default = "ansible-base" }
variable "IMAGE_K3S" { default = "ansible-k3s" }

target "_common" {
  labels = {
    "org.opencontainers.image.source"   = "${GITHUB_REPOSITORY}"
    "org.opencontainers.image.version"  = "${VERSION}"
    "org.opencontainers.image.revision" = "${GITHUB_SHA}"
    "org.opencontainers.image.licenses" = "MIT"
    "org.opencontainers.image.vendor"   = "HomeLab"
  }

  args = {
    DEBIAN_MIRROR = "${DEBIAN_MIRROR}"
  }
}

target "base" {
  inherits   = ["_common"]
  context    = "images/base"
  dockerfile = "Dockerfile"
  cache_to = ["type=gha,mode=max"]

  labels = {
    "org.opencontainers.image.title"       = "Ansible Execution Environment Base"
    "org.opencontainers.image.description" = "Minimal Ansible EE with Python 3.11, Ansible Core and Runner"
  }

  args = {
    PIP_MIRROR = "${PIP_MIRROR}"
  }

  tags = ["${REGISTRY}/${IMAGE_BASE}:${VERSION}"]
}

target "k3s" {
  inherits   = ["_common"]
  context    = "images/k3s"
  dockerfile = "Dockerfile"
  cache_from = ["type=gha,src=base"]
  cache_to = ["type=gha,mode=max"]

  contexts = {
    base_image = "target:base"
  }

  args = {
    PIP_MIRROR = "${PIP_MIRROR}"
  }

  labels = {
    "org.opencontainers.image.title"       = "Ansible EE for k3s"
    "org.opencontainers.image.description" = "Ansible Execution Environment for k3s cluster management"
  }

  tags = ["${REGISTRY}/${IMAGE_K3S}:${VERSION}"]
}

group "all" {
  targets = ["base", "k3s"]
}
