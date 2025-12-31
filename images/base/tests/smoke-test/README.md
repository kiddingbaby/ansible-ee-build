# Smoke Test

Basic functional tests for Ansible Execution Environment images.

## Directory Structure

- `project/site.yml`: Simple "Hello World" Playbook for validating `ansible-base` and `ansible-k3s` images.

## Running Tests

### Test Base Image

```bash
# Build base and load into local docker
just build base

docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:dev \
  ansible-runner run /runner -p site.yml
```

### Test K3s Image

```bash
# Build k3s and load into local docker
just build k3s

docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-k3s:dev \
  ansible-runner run /runner -p site.yml
```

## Success Criteria

- Playbook runs without errors.
- Output contains `"msg": "Hello from ansible-runner"`.
- No permission or dependency issues.
