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

NEXIGON_CLI="${NEXIGON_CLI:-nexigon-cli}"

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

STABLE_TAG=${STABLE_TAG:-"stable"}
FLOATING_TAG=${FLOATING_TAG:-"latest-build-${GIT_BRANCH//\//-}"}

PACKAGE_PATH="$NEXIGON_REPOSITORY/$NEXIGON_PACKAGE"

$NEXIGON_CLI repositories versions tag "$PACKAGE_PATH/$FLOATING_TAG" --tag "${STABLE_TAG},reassign"
