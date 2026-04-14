#!/bin/bash

set -euo pipefail

cp -rT "${RECIPE_DIR}/overlay" /

systemctl enable nodered-podman
