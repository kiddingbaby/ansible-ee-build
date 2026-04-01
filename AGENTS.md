# AGENTS.md

This file is a thin adapter for agentic tools in `ansible-ee-build`.

Canonical repository automation guidance lives in:

- `automation/README.md`
- `automation/REPO-INDEX.json`

## Repo Rules

- use `docs/` for human-facing guidance and `automation/` for machine-facing discovery
- prefer stable `just` entrypoints for build and smoke operations
- validate automation changes with `python3 automation/tools/validate_repo_automation.py`
