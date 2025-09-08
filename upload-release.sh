#!/usr/bin/env bash

set -euo pipefail

# Repository to upload the release to.
REPOSITORY="nexigon-rugix-example"
# Package to upload the release to.
PACKAGE="example-rugix-os"

NEXIGON_CLI="${NEXIGON_CLI:-nexigon-cli}"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")

GIT_COMMIT=$(git rev-parse --short HEAD)

BUILD_VERSION=${BUILD_VERSION:-"build-$TIMESTAMP-$GIT_COMMIT"}

echo "BUILD_VERSION=${BUILD_VERSION}"

PACKAGE_PATH="$REPOSITORY/$PACKAGE"
VERSION_PATH="$PACKAGE_PATH/$BUILD_VERSION"

# Create the build version, if it doesn't exist.
BUILD_VERSION_INFO=$($NEXIGON_CLI repositories versions resolve "$VERSION_PATH")
if [ "$(echo "$BUILD_VERSION_INFO" | jq -r '.result')" == "Found" ]; then
    echo "Build version already exists, updating it."
    VERSION_ID=$(echo "$BUILD_VERSION_INFO" | jq -r '.versionId')
else
    echo "Build version does not exist, creating it."
    VERSION_ID=$($NEXIGON_CLI repositories versions create "$PACKAGE_PATH" --tag "$BUILD_VERSION,locked" | jq -r '.versionId')
fi

echo "VERSION_ID=${VERSION_ID}"

for build_dir in build/*; do
    SYSTEM_NAME=$(basename "$build_dir")
    IMG_PATH="$build_dir/system.img"
    BUNDLE_PATH="$build_dir/system.rugixb"
    SBOM_PATH="$build_dir/sbom.spdx.json"
    INFO_PATH="$build_dir/system-build-info.json"
    if [ ! -e "$IMG_PATH" ]; then
        echo "Skipping '$SYSTEM_NAME', no bundle found"
        continue
    fi
    # if [ -e "$IMG_PATH" ]; then
    #     asset_info=$($NEXIGON_CLI repositories assets upload "$REPOSITORY" "$IMG_PATH")
    #     asset_id=$(echo "$asset_info" | jq -r '.assetId')
    #     $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.img"
    # fi
    if [ -e "$BUNDLE_PATH" ]; then
        asset_info=$($NEXIGON_CLI repositories assets upload "$REPOSITORY" "$BUNDLE_PATH")
        asset_id=$(echo "$asset_info" | jq -r '.assetId')
        $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.rugixb"
    fi
    if [ -e "$SBOM_PATH" ]; then
        asset_info=$($NEXIGON_CLI repositories assets upload "$REPOSITORY" "$SBOM_PATH")
        asset_id=$(echo "$asset_info" | jq -r '.assetId')
        $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.spdx.json"
    fi
    if [ -e "$INFO_PATH" ]; then
        asset_info=$($NEXIGON_CLI repositories assets upload "$REPOSITORY" "$INFO_PATH")
        asset_id=$(echo "$asset_info" | jq -r '.assetId')
        $NEXIGON_CLI repositories versions assets add "$VERSION_ID" "$asset_id" "$SYSTEM_NAME.build-info.json"
    fi
done
