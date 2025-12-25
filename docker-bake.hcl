############################################################
# Variables
############################################################

variable "VERSION" {}
variable "REGISTRY" {}
variable "PLATFORMS" {
  default = "linux/amd64,linux/arm64"
}
variable "PUSH" {
  default = "false"
}

############################################################
# Common
############################################################

target "_common" {
  platforms = split(",", PLATFORMS)

  output = PUSH == "true"
    ? ["type=registry"]
    : ["type=docker"]
}

############################################################
# Base
############################################################

target "base" {
  inherits   = ["_common"]
  context    = "ansible-ee-base"
  dockerfile = "Dockerfile"

  tags = [
    "${REGISTRY}/ansible-ee-base:${VERSION}",
  ]
}

############################################################
# K3s (depends on base)
############################################################

target "k3s" {
  inherits   = ["_common"]
  context    = "ansible-ee-k3s"
  dockerfile = "Dockerfile"
  target     = "release"

  depends_on = ["base"]

  args = {
    BASE_IMAGE = "${REGISTRY}/ansible-ee-base:${VERSION}"
  }

  tags = [
    "${REGISTRY}/ansible-ee-k3s:${VERSION}",
  ]
}

############################################################
# Groups
############################################################

group "default" {
  targets = ["base", "k3s"]
}
