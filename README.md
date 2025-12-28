# Ansible Execution Environment Build System

[English](./README.md) | [中文文档](./README.zh-CN.md)

A professional, reproducible build system for Ansible Execution Environments (EE), powered by Docker BuildKit and HCL.

## 🚀 Key Features

- **Modern Build System**: Uses `docker buildx bake` with HCL for declarative build definitions.
- **Optimized Images**:
  - **Multi-stage builds** for smaller image sizes.
  - **BuildKit Cache Mounts** (`pip`, `apt`) for faster rebuilds.
  - **Tini** init process for proper signal handling.
  - **Non-root user** (`ansible`) for security.
- **Dependency Management**: Local DAG resolution ensures `k3s` image builds correctly after `base` without intermediate pushes.
- **CI/CD Ready**: GitHub Actions workflow with automated versioning and GHCR publishing.

## 📦 Image Hierarchy

| Image          | Description                                                                                              | Context         |
| -------------- | -------------------------------------------------------------------------------------------------------- | --------------- |
| `ansible-base` | The foundation. Contains Python 3.11, Ansible Core 2.17, Ansible Runner, and essential system libraries. | `./images/base` |
| `ansible-k3s`  | Extends `base`. Adds Kubernetes tools (`kubectl`, `helm`) and K3s-specific Ansible collections.          | `./images/k3s`  |

## 📂 Project Structure

```text
.
├── images/
│   ├── base/      # Base image definition
│   │   ├── Dockerfile
│   │   ├── requirements.txt  # Python dependencies
│   │   └── ansible.cfg
│   └── k3s/       # K3s extension image
│       ├── Dockerfile
│       ├── requirements.txt  # K3s specific Python deps
│       └── requirements.yml  # Ansible collections
├── docker-bake.hcl       # BuildKit HCL definition
├── Makefile              # User interface wrapper
└── .github/              # CI/CD workflows
```

## 🛠️ Quick Start

### Prerequisites

- Docker (with Buildx support)
- Make

### Build Commands

The `Makefile` simplifies the `docker buildx bake` commands.

**Build and Load to Local Docker:**
This is the default for development. It builds the images and loads them into your local Docker daemon.

```bash
make load
```

**Build and Push to Registry:**
This builds the images and pushes them to the configured registry (default: `ghcr.io/kiddingbaby`).

```bash
make build
```

**Build Specific Target:**
You can build only the base image or the k3s image using the `TARGETS` variable.

```bash
make load TARGETS=base
make load TARGETS=k3s
```

**Clean Up:**
Remove the generated images from local Docker.

```bash
make clean
```

## ⚙️ Configuration

You can override default variables:

| Variable   | Default               | Description                                            |
| :--------- | :-------------------- | :----------------------------------------------------- |
| `VERSION`  | `dev-<short-sha>`     | The tag version for the images.                        |
| `REGISTRY` | `ghcr.io/kiddingbaby` | The container registry to push to.                     |
| `TARGETS`  | `all`                 | The bake target(s) to build (`base`, `k3s`, or `all`). |

Example:

```bash
make load VERSION=v1.0.0
```

## 🏃 Usage

Run the built image using Docker:

```bash
# Run ansible --version
# Run ansible --version
docker run --rm ghcr.io/kiddingbaby/ansible-base:dev-xxxxxxx ansible --version

# Run an interactive shell
docker run --rm -it ghcr.io/kiddingbaby/ansible-k3s:dev-xxxxxxx bash
```

## 📝 License

MIT
