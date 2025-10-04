#!/usr/bin/env bash

set -euo pipefail

TIMESTAMP=$(date +"%Y%m%d%H%M%S")

GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

BUILD_TAG=${BUILD_TAG:-"build-$TIMESTAMP-$GIT_COMMIT"}
FLOATING_TAG=${FLOATING_TAG:-"latest-build-${GIT_BRANCH//\//-}"}

echo "BUILD_TAG=${BUILD_TAG}"
echo "FLOATING_TAG=${FLOATING_TAG}"