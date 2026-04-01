#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import sys


def main() -> int:
    repo_root = Path(__file__).resolve().parents[2]
    required = [
        repo_root / "automation" / "README.md",
        repo_root / "automation" / "REPO-INDEX.json",
        repo_root / "AGENTS.md",
        repo_root / "CLAUDE.md",
        repo_root / ".github" / "copilot-instructions.md",
    ]
    errors: list[str] = []

    for path in required:
        if not path.exists():
            errors.append(f"missing required file: {path.relative_to(repo_root)}")

    try:
        index = json.loads((repo_root / "automation" / "REPO-INDEX.json").read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"failed to read automation/REPO-INDEX.json: {exc}")
        index = None

    if index is not None:
        for entry in index.get("human_docs", []):
            path = entry.get("path")
            if path and not (repo_root / path).exists():
                errors.append(f"missing indexed file: {path}")

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    print("repo-automation: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
