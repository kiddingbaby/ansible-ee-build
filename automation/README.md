# Repository Automation Surface

This directory is the canonical home for machine-facing automation assets in
`ansible-ee-build`.

This repo uses a lighter automation surface than `infra-system-init` and
`infra-services`: it focuses on build and smoke entrypoints plus adapter
alignment.

## Start Here

- machine-readable repo index: `automation/REPO-INDEX.json`
- validation command: `python3 automation/tools/validate_repo_automation.py`

## Rules

- canonical machine-facing discovery lives in `automation/`
- human-facing explanations stay in `docs/`
- root adapter files stay thin pointers
- build and smoke entrypoints should be discovered through stable `just` targets

## Validation

```bash
python3 automation/tools/validate_repo_automation.py
```
