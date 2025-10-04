#!/usr/bin/env bash

set -euo pipefail

. .env

if [ -z "${NEXIGON_REPOSITORY:-}" ]; then
    echo "[ERROR] NEXIGON_REPOSITORY is not set"
    exit 1
fi

if [ -z "${NEXIGON_PACKAGE:-}" ]; then
    echo "[ERROR] NEXIGON_PACKAGE is not set"
    exit 1
fi

. ./scripts/build-vars.sh

NEXIGON_CLI="${NEXIGON_CLI:-nexigon-cli}"

PACKAGE_PATH="$NEXIGON_REPOSITORY/$NEXIGON_PACKAGE"
VERSION_PATH="$PACKAGE_PATH/$BUILD_TAG"

# Create the build version, if it doesn't exist.
BUILD_VERSION_INFO=$($NEXIGON_CLI repositories versions resolve "$VERSION_PATH")
if [ "$(echo "$BUILD_VERSION_INFO" | jq -r '.result')" == "Found" ]; then
    echo "[INFO] build version already exists, amending it"
    VERSION_ID=$(echo "$BUILD_VERSION_INFO" | jq -r '.versionId')
else
    echo "[INFO] build version does not exist, creating it"
    VERSION_ID=$($NEXIGON_CLI repositories versions create "$PACKAGE_PATH" --tag "$BUILD_TAG,locked" --tag "$FLOATING_TAG,reassign" | jq -r '.versionId')
fi

echo "VERSION_ID=${VERSION_ID}"

for build_dir in build/*; do
    SYSTEM_NAME=$(basename "$build_dir")
    IMG_PATH="$build_dir/system.img"
    BUNDLE_PATH="$build_dir/system.rugixb"
    SBOM_PATH="$build_dir/sbom.spdx.json"
    INFO_PATH="$build_dir/system-build-info.json"
    if [ ! -e "$IMG_PATH" ]; then
        echo "[WARN] skipping '$SYSTEM_NAME', no bundle found"
        continue
    fi
    if [ -e "$IMG_PATH" ]; then
        echo "[INFO] uploading '$SYSTEM_NAME' image"
        xz "$IMG_PATH"
        asset_info=$($NEXIGON_CLI repositories assets upload "$NEXIGON_REPOSITORY" "$IMG_PATH.xz")
        asset_id=$(echo "$asset_info" | jq -r '.assetId')        
        $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.img.xz"
    fi
    if [ -e "$BUNDLE_PATH" ]; then
        echo "[INFO] uploading '$SYSTEM_NAME' bundle"
        asset_info=$($NEXIGON_CLI repositories assets upload "$NEXIGON_REPOSITORY" "$BUNDLE_PATH")
        asset_id=$(echo "$asset_info" | jq -r '.assetId')
        $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.rugixb"
    fi
    if [ -e "$SBOM_PATH" ]; then
        echo "[INFO] uploading '$SYSTEM_NAME' SBOM"
        asset_info=$($NEXIGON_CLI repositories assets upload "$NEXIGON_REPOSITORY" "$SBOM_PATH")
        asset_id=$(echo "$asset_info" | jq -r '.assetId')
        $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.spdx.json"
    fi
    if [ -e "$INFO_PATH" ]; then
        echo "[INFO] uploading '$SYSTEM_NAME' build info"
        asset_info=$($NEXIGON_CLI repositories assets upload "$NEXIGON_REPOSITORY" "$INFO_PATH")
        asset_id=$(echo "$asset_info" | jq -r '.assetId')
        $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.build-info.json"
    fi
done
