# Smoke Test

Basic functional tests for Ansible Execution Environment images.

## Directory Structure

- `project/site.yml`: Simple "Hello World" Playbook for validating `ansible-base` and `ansible-k3s` images.

## Running Tests

### Test Base Image

```bash
make build VERSION=1.0.0 TARGETS=base
docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-base:1.0.0 \
  ansible-runner run /runner -p site.yml
```

### Test K3s Image

```bash
make build VERSION=1.0.0 TARGETS=k3s
docker run --rm \
  -v $(pwd)/images/base/tests/smoke-test/project:/runner/project:ro \
  ghcr.io/kiddingbaby/ansible-k3s:1.0.0 \
  ansible-runner run /runner -p site.yml
```

## Success Criteria

- Playbook runs without errors.
- Output contains `"msg": "Hello from ansible-runner"`.
- No permission or dependency issues.
