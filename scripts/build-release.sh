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
cd -- "$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f .release-env ]; then
    echo "[ERROR] .release-env not found — run ./scripts/prepare-release.sh first"
    exit 1
fi

# shellcheck source=/dev/null
. ./.release-env
: "${VERSION:?The prepared release must define VERSION}"

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
    if [[ ! -f "$IMG_PATH" ]]; then
        echo "[ERROR] expected image not found at $IMG_PATH" >&2
        exit 1
    fi
    echo "[INFO] compressing '$system' image"
    xz -T0 -f "$IMG_PATH"
done
