# CLAUDE.md

This file is a thin Claude Code adapter for `ansible-ee-build`.

Canonical repository automation guidance lives in:

- `automation/README.md`
- `automation/REPO-INDEX.json`

## Rules

- keep machine-facing discovery in `automation/`
- keep human-facing explanations in `docs/`
- prefer stable `just` entrypoints for build and smoke operations
- validate repo automation changes with `python3 automation/tools/validate_repo_automation.py`
