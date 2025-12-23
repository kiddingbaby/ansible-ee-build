############################################################
# Global variables
############################################################

variable "VERSION" {
  default = "latest"
}

variable "REGISTRY" {
  default = ""
}

variable "PLATFORMS" {
  default = "linux/amd64,linux/arm64"
}

############################################################
# Common definitions
############################################################

# 所有 EE 镜像统一规则
target "_ee_common" {
  platforms = split(",", PLATFORMS)

  labels = {
    "org.opencontainers.image.source" = "https://github.com/${REGISTRY}"
  }
}

############################################################
# Base EE (platform layer)
############################################################

target "ee-base" {
  inherits   = ["_ee_common"]
  context    = "ansible-ee-base"
  dockerfile = "Dockerfile"

  tags = [
    "${REGISTRY}/ansible-ee-base:${VERSION}",
    "${REGISTRY}/ansible-ee-base:latest",
  ]
}

############################################################
# K3s EE (application layer)
############################################################

target "ee-k3s" {
  inherits   = ["_ee_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"
  target     = "release"

  args = {
    BASE_IMAGE = "${REGISTRY}/ansible-ee-base:latest"
  }

  tags = [
    "${REGISTRY}/ansible-ee-k3s:${VERSION}",
    "${REGISTRY}/ansible-ee-k3s:latest",
  ]
}

############################################################
# Groups
############################################################

group "base" {
  targets = ["ee-base"]
}

group "apps" {
  targets = ["ee-k3s"]
}

group "default" {
  targets = ["ee-base", "ee-k3s"]
}
