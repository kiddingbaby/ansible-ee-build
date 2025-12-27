variable "VERSION" {
}

variable "GITHUB_SHA" {
}

variable "REGISTRY" {
  default = "ghcr.io/kiddingbaby"
}

variable "DEBIAN_MIRROR" {
  default = "mirrors.tuna.tsinghua.edu.cn"
}

variable "PIP_MIRROR" {
  default = "https://pypi.tuna.tsinghua.edu.cn/simple/"
}

locals {
  GITHUB_REPOSITORY = "https://github.com/kiddingbaby/ansible-ee-build"

  IMAGE_BASE = "ansible-ee-base"
  IMAGE_K3S  = "ansible-ee-k3s"
}

target "_common" {
  labels = {
    "org.opencontainers.image.source"   = local.GITHUB_REPOSITORY
    "org.opencontainers.image.version"  = VERSION
    "org.opencontainers.image.revision" = GITHUB_SHA
    "org.opencontainers.image.licenses" = "MIT"
    "org.opencontainers.image.vendor"   = "HomeLab"
  }

  args = {
    DEBIAN_MIRROR = DEBIAN_MIRROR
  }
}

target "base" {
  inherits   = ["_common"]
  context    = "ansible-ee-base"
  dockerfile = "Dockerfile"

  labels = {
    "org.opencontainers.image.title"       = "Ansible Execution Environment Base"
    "org.opencontainers.image.description" = "Minimal Ansible EE with Python 3.11, Ansible Core and Runner"
  }

  args = {
    PIP_MIRROR = PIP_MIRROR
  }

  tags = [
    "${REGISTRY}/${local.IMAGE_BASE}:${VERSION}"
  ]
}

target "k3s" {
  inherits   = ["_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"

  contexts = {
    base_image = "target:base"
  }

  args = {
    PIP_MIRROR = PIP_MIRROR
  }

  labels = {
    "org.opencontainers.image.title"       = "Ansible EE for k3s"
    "org.opencontainers.image.description" = "Ansible Execution Environment for k3s cluster management"
  }

  tags = [
    "${REGISTRY}/${local.IMAGE_K3S}:${VERSION}"
  ]
}

group "all" {
  targets = ["base", "k3s"]
}
