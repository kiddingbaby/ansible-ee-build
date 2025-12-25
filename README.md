
# ansible-ee-build

[English](./README.md) | [中文文档](./README.zh-CN.md)

Minimal, reproducible build system for Ansible Execution Environments (EE) images.

## Key Features

- Build engine: Docker BuildKit + `docker buildx bake` (HCL)
- Build definition: `docker-bake.hcl` (single source of truth)
- Interface: `Makefile` (thin UX wrapper)

## Images

- `ansible-ee-base`: Runtime base image (non-root, preconfigured venv and collections)
- `ansible-ee-k3s`: Extends base with K3s/Kubernetes operational tools

## Targets

- `default`: build `base` + `k3s`
- `base`: build base image only
- `k3s`: build release image
- `k3s-dev`: build dev/debug image

## Quick Start

Build base:

```bash
make build TARGET=base
```

Build k3s (automatically builds base if needed):

```bash
make build TARGET=k3s
```

Build all:

```bash
make build
```

Push to registry (requires login to `ghcr.io` with a PAT that includes `write:packages`):

```bash
make build TARGET=k3s PUSH=true
```

**Note**:

- `PUSH=true` uses `docker buildx bake --push`.
- `PUSH=false` uses `docker buildx bake --load`.
- Default `PLATFORMS` is `linux/amd64,linux/arm64` (see `docker-bake.hcl`). When using `--load`, set a single platform, for example:

```bash
PLATFORMS=linux/amd64 make build TARGET=base
```

## Configuration

- Version: driven by the repository root `VERSION` file.
- Registry namespace defaults to `REGISTRY=$(REGISTRY_HOST)/$(OWNER)`.

Override examples:

```bash
make build TARGET=base REGISTRY_HOST=registry.example.com
make build TARGET=base REGISTRY=registry.example.com/team
```

## Debug

Interactive shell:

```bash
docker run --rm -it ghcr.io/kiddingbaby/ansible-ee-base:1.0.0 bash
```

## CI/CD

- CI uses the exact same bake definition as local builds.
- Image version is driven by the repository root `VERSION` file.

## Maintainer Notes

- Keep all build logic (tags, platforms, args) in `docker-bake.hcl`.
- Avoid duplicating build arguments or logic in Makefile/CI.

## License

MIT
