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

| Image              | Description                                                                         | Context             |
| ------------------ | ----------------------------------------------------------------------------------- | ------------------- |
| `ansible-base`     | Foundation. Python 3.11, Ansible Core 2.17, Ansible Runner, system libraries.       | `./images/base`     |
| `ansible-k3s`      | Extends `base`. Adds Kubernetes tools (`kubectl`, `helm`), K3s Ansible collections. | `./images/k3s`      |
| `ansible-harbor`   | Harbor registry integration (experimental).                                         | `./images/harbor`   |
| `ansible-keycloak` | Keycloak authentication integration (experimental).                                 | `./images/keycloak` |

## 📂 Project Structure

```text
.
├── images/
│   ├── base/              # Base image (required)
│   │   ├── VERSION        # Version file (or dev-<sha>)
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── ansible.cfg
│   │   └── tests/         # Test suite
│   │       └── smoke-test/
│   ├── k3s/               # K3s extension (extends base)
│   │   ├── VERSION
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── requirements.yml
│   ├── harbor/            # Harbor extension (experimental)
│   └── keycloak/          # Keycloak extension (experimental)
├── docker-bake.hcl        # BuildKit HCL definition
├── Makefile               # Build wrapper
├── test.sh                # Dynamic version scanner
└── .github/workflows/     # GitHub Actions (auto-detect changes)
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

## ⚙️ Versioning

**Per-Image Versions** (via `VERSION` file)

- Each image can have its own `images/<name>/VERSION` file containing a version string.
- If file exists: used as tag (e.g., `ansible-base:1.0.0`).
- If missing: falls back to `dev-<short-git-sha>`.

### Build Variables

| Variable   | Default               | Description                                            |
| :--------- | :-------------------- | :----------------------------------------------------- |
| `VERSION`  | `dev-<short-sha>`     | Global version (can be overridden per image).          |
| `REGISTRY` | `ghcr.io/kiddingbaby` | Container registry for push.                           |
| `TARGETS`  | `all`                 | Targets to build: `base`, `k3s`, `harbor`, `keycloak`. |

Examples:

```bash
# Build locally with default versions from VERSION files or git SHA
make build

# Build with custom version
make build VERSION=1.2.0

# Build only base
make build TARGETS=base
```

## 🏃 Usage

### Build

```bash
# Build all images locally
make load

# Build specific image
make load TARGETS=base
```

### Run and Test

**Test base image** (see [images/base/tests/smoke-test](./images/base/tests/smoke-test)):

```bash
make build VERSION=1.0.0 TARGETS=base
docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:1.0.0 \
  ansible-runner run /runner -p site.yml
```

**Interactive shell**:

```bash
docker run -it ghcr.io/kiddingbaby/ansible-base:1.0.0 bash
```

**Run playbook** (mount your playbooks):

```bash
docker run -it --rm \
  -v $(pwd)/playbooks:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:1.0.0 \
  ansible-runner run /runner -p site.yml
```

**K3s image** (extends base):

```bash
docker run -it ghcr.io/kiddingbaby/ansible-k3s:1.0.0 bash
```

## 🔄 CI/CD Workflow

- **Auto-detection**: GitHub Actions detects which `images/` subdirs changed.
- **Version computation**: Reads per-image `VERSION` file or generates `dev-<sha>` tag.
- **Smart build**: Only rebuilds affected images and their dependents (e.g., changing `base` triggers rebuild of `k3s`).
- **Registry push**: On tag push, builds and publishes to GHCR (if not PR).

## 🛠️ Development

### Extending the Build

To add a new image variant:

1. Create `images/<name>/` with `Dockerfile`, `requirements.txt`, and optionally `requirements.yml`.
2. (Optional) Add `images/<name>/VERSION` file with semantic version.
3. Update `docker-bake.hcl` if the image needs custom build args or cache logic.
4. GitHub Actions will auto-detect and include it.

### Testing

Run the smoke test suite:

```bash
make build VERSION=1.0.0 TARGETS=base
docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:1.0.0 \
  ansible-runner run /runner -p site.yml
```

## 📝 License

MIT
