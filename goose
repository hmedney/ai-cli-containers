#!/bin/bash

COMPOSE_SERVICE=goose
DATA_DIR="${HOME}/ai-tools/goose"
TOOL_CMD=/home/user/.local/bin/goose
# TOOL_CMD=bash

# shellcheck source=lib/launch.sh
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/lib/launch.sh"
