#!/usr/bin/env bash
# Validate VERSION files contain valid SemVer
# Exit 0 if valid, 1 if invalid

SEMVER_REGEX='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

exit_code=0

for file in "$@"; do
    if [ -f "$file" ]; then
        version=$(head -n 1 "$file" | tr -d '[:space:]')
        if [[ ! "$version" =~ $SEMVER_REGEX ]]; then
            echo "ERROR: Invalid SemVer in $file: '$version'"
            echo "  Expected format: MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]"
            exit_code=1
        fi
    fi
done

exit $exit_code
