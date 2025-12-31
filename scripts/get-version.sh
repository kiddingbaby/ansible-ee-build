#!/usr/bin/env bash
# Get version from VERSION file or git short hash
# Usage: get-version.sh <target> [mode]
# mode:
#   auto (default): use VERSION file if exists, else dev-hash
#   pr: force dev-hash (safe mode for Pull Requests)

target=${1:-base}
mode=${2:-auto}
version_file="images/$target/VERSION"

# Helper to get git hash
get_hash() {
    git rev-parse --short=7 HEAD 2>/dev/null || echo "unknown"
}

# SemVer Regex (ERE compatible)
SEMVER_REGEX='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$'

# PR Mode: Always return pr hash
if [[ "$mode" == "pr" ]]; then
    echo "pr-$(get_hash)"
    exit 0
fi

# Auto Mode: Check file first
if [ -s "$version_file" ]; then
    version=$(head -n 1 "$version_file" | tr -d '[:space:]')

    # Validate SemVer
    if [[ ! "$version" =~ $SEMVER_REGEX ]]; then
        echo "Error: Invalid SemVer format in $version_file: $version" >&2
        exit 1
    fi

    # If pre-release version (contains -), append git hash
    if [[ "$version" == *"-"* ]]; then
        echo "${version}-$(get_hash)"
    else
        echo "$version"
    fi
else
    echo "dev-$(get_hash)"
fi
