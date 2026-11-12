#!/usr/bin/env bash
#
# Prepare a new release: generate a version, create it in Nexigon Hub, and
# write a .release-env file that pins the version for subsequent build and
# upload steps.
#
# Usage:
#   ./scripts/prepare-release.sh
#
# The generated .release-env is sourced by build-release.sh and upload-release.sh.

set -euo pipefail
cd -- "$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f .env ]]; then
    echo "[ERROR] .env is missing. Copy env.template to .env and configure it first." >&2
    exit 1
fi
# shellcheck source=/dev/null
. ./.env

if [ -z "${NEXIGON_REPOSITORY:-}" ]; then
    echo "[ERROR] NEXIGON_REPOSITORY is not set"
    exit 1
fi

if [ -z "${NEXIGON_PACKAGE:-}" ]; then
    echo "[ERROR] NEXIGON_PACKAGE is not set"
    exit 1
fi

NEXIGON_CLI="${NEXIGON_CLI:-nexigon-cli}"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

BUILD_TAG=${BUILD_TAG:-"build-${TIMESTAMP}-${GIT_COMMIT}"}
FLOATING_TAG=${FLOATING_TAG:-"latest-build-${GIT_BRANCH//\//-}"}

# The release version is the build tag itself — this is what gets baked into
# the device image and can be used directly as a repository tag to resolve
# back to the package version.
VERSION="$BUILD_TAG"

PACKAGE_PATH="$NEXIGON_REPOSITORY/$NEXIGON_PACKAGE"
VERSION_PATH="$PACKAGE_PATH/$BUILD_TAG"

# Create the build version, if it doesn't exist.
BUILD_VERSION_INFO=$("$NEXIGON_CLI" repositories versions resolve "$VERSION_PATH")
if [ "$(echo "$BUILD_VERSION_INFO" | jq -r '.result')" == "Found" ]; then
    echo "[INFO] build version already exists, reusing it"
    VERSION_ID=$(echo "$BUILD_VERSION_INFO" | jq -r '.versionId')
else
    echo "[INFO] creating build version"
    VERSION_METADATA=$(jq -nc --arg version "$VERSION" '{imageVersion: $version}')
    VERSION_ID=$("$NEXIGON_CLI" repositories versions create "$PACKAGE_PATH" \
        --tag "$BUILD_TAG,locked" --tag "$FLOATING_TAG,reassign" \
        --metadata "$VERSION_METADATA" | jq -r '.versionId')
fi

echo "[INFO] BUILD_TAG=$BUILD_TAG"
echo "[INFO] VERSION=$VERSION"
echo "[INFO] VERSION_ID=$VERSION_ID"

release_env="$(mktemp .release-env.XXXXXX)"
trap 'rm -f -- "$release_env"' EXIT
printf 'BUILD_TAG=%q\nFLOATING_TAG=%q\nVERSION=%q\nVERSION_ID=%q\n' \
    "$BUILD_TAG" "$FLOATING_TAG" "$VERSION" "$VERSION_ID" > "$release_env"
mv -- "$release_env" .release-env

echo "[INFO] wrote .release-env"
