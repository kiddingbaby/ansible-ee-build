# Ansible Execution Environment Build System

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
├── (optional) build wrappers (justfile)
├── test.sh                # Dynamic version scanner
└── .github/workflows/     # GitHub Actions (auto-detect changes)
```

## 🛠️ Quick Start

### Prerequisites

- Docker (with Buildx support)
- `just` (optional — used for local development tasks)
- `jq` (optional — used by some helper scripts)

### Build Commands (Local development)

This repository provides a `justfile` for local development. For advanced or CI-driven builds you can use `docker buildx bake` directly.

#### Build and Load to Local Docker (recommended for devcontainer)

```bash
just build
```

This command runs `docker buildx bake -f docker-bake.hcl all --load --set _common.platform=linux/amd64` and uses the defaults defined in `docker-bake.hcl`.

#### Print Build Commands

```bash
just print
```

#### Build Specific Target

You can target a specific image with positional parameters:

```bash
# Build base only (loads into local docker)
just build base

# Build k3s only
just build k3s

# Build with different platform
just build all linux/arm64
```

#### Advanced: Direct docker bake usage

For more control, use `docker buildx bake` directly:

```bash
# Build base with custom platform
docker buildx bake -f docker-bake.hcl base --load --set _common.platform=linux/amd64

# Build all and push
docker buildx bake -f docker-bake.hcl all --push
```

**Clean Up:**

```bash
just clean
```

## ⚙️ Versioning

**Per-Image Versions** (via `VERSION` file)

- Each image can have its own `images/<name>/VERSION` file containing a version string.
- If file exists: used as tag (e.g., `ansible-base:1.0.0`). If the version contains a pre-release suffix (e.g. `1.0.0-dev`), the build system appends the short git sha to produce `1.0.0-dev-<sha>` for uniqueness.
- If missing: falls back to `dev-<short-git-sha>`.

**Note:** The helper script `scripts/generate-build-env.sh` is used by the CI `compute-tags` action to populate image tag environment variables; for local `just` builds you do not need to `export $(scripts/generate-build-env.sh)` — the `docker-bake.hcl` defaults will be used unless you explicitly override variables via `--set` or environment variables.

### Build Variables

| Variable   | Default               | Description                                            |
| :--------- | :-------------------- | :----------------------------------------------------- |
| `VERSION`  | `dev-<short-sha>`     | Global version (can be overridden per image).          |
| `REGISTRY` | `ghcr.io/kiddingbaby` | Container registry for push.                           |
| `TARGETS`  | `all`                 | Targets to build: `base`, `k3s`, `harbor`, `keycloak`. |

Examples:

```bash
# Build locally with default versions from VERSION files or git SHA
just build

# Build with custom version (override bake variable)
docker buildx bake -f docker-bake.hcl --load --set IMAGE_BASE_TAG=1.2.0

# Build only base
docker buildx bake -f docker-bake.hcl --load --set targets=base
```

## 🏃 Usage

### Build

```bash
# Build all images locally (recommended)
just build

# Build specific image (base)
docker buildx bake -f docker-bake.hcl --load --set target.base.platforms=linux/amd64
```

### Run and Test

For detailed smoke-test instructions see [images/base/tests/smoke-test](./images/base/tests/smoke-test).

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

Run the smoke test suite — see `images/base/tests/smoke-test/README.md` for full details. Quick example:

```bash
just build
IMAGE=ghcr.io/kiddingbaby/ansible-base:1.0.0 docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  $IMAGE \
  ansible-runner run /runner -p site.yml
```

## 📝 License

MIT
