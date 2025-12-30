#!/usr/bin/env bash
# Generate environment variables for image tags
# Usage: generate-build-env.sh [mode]
# Output: IMAGE_TARGET_TAG=version (one per line)

mode=${1:-auto}

for dir in images/*; do
    [ -d "$dir" ] || continue
    target=$(basename "$dir")

    # Get version using the existing script
    # Note: get-version.sh must be in the path or referenced relatively
    # We assume this script is run from the repo root
    tag=$(scripts/get-version.sh "$target" "$mode")

    # Log to stderr (visible in CI logs but doesn't pollute stdout)
    echo "Target: $target | Mode: $mode | Tag: $tag" >&2

    # Format: IMAGE_TARGET_TAG=value
    var_name="IMAGE_$(echo "$target" | tr '[:lower:]' '[:upper:]')_TAG"
    echo "$var_name=$tag"
done
