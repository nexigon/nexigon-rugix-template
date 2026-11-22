#!/usr/bin/env bash

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

if [ ! -f .release-env ]; then
    echo "[ERROR] .release-env not found — run ./scripts/prepare-release.sh first"
    exit 1
fi

# shellcheck source=/dev/null
. ./.release-env

NEXIGON_CLI="${NEXIGON_CLI:-nexigon-cli}"

# A user token needs `--organization`; an organization API token selects its own.
nexigon_cli() {
    "$NEXIGON_CLI" ${NEXIGON_ORGANIZATION:+--organization "$NEXIGON_ORGANIZATION"} "$@"
}

STABLE_TAG=${STABLE_TAG:-"stable"}

PACKAGE_PATH="$NEXIGON_REPOSITORY/$NEXIGON_PACKAGE"

nexigon_cli repositories versions tag "$PACKAGE_PATH/$FLOATING_TAG" --tag "${STABLE_TAG},reassign"
