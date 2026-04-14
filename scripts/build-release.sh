#!/usr/bin/env bash
#
# Build system images and bundles using the version pinned by prepare-release.sh.
#
# Usage:
#   ./scripts/build-release.sh <system> [<system> ...]
#
# Examples:
#   ./scripts/build-release.sh customized-efi-amd64
#   ./scripts/build-release.sh customized-efi-amd64 customized-pi5

set -euo pipefail

if [ ! -f .release-env ]; then
    echo "[ERROR] .release-env not found — run ./scripts/prepare-release.sh first"
    exit 1
fi

. .release-env

if [ $# -eq 0 ]; then
    echo "[ERROR] no systems specified"
    echo "usage: $0 <system> [<system> ...]"
    exit 1
fi

for system in "$@"; do
    echo "[INFO] building image for '$system' (version: $VERSION)"
    ./run-bakery bake image "$system" --release-version "$VERSION"
    echo "[INFO] building bundle for '$system' (version: $VERSION)"
    ./run-bakery bake bundle "$system" --release-version "$VERSION"
    IMG_PATH="build/$system/system.img"
    if [ -e "$IMG_PATH" ]; then
        echo "[INFO] compressing '$system' image"
        xz "$IMG_PATH"
    fi
done
