#!/bin/bash

COMPOSE_SERVICE=goose
DATA_DIR="${HOME}/ai-tools/goose"
TOOL_CMD=goose

# shellcheck source=lib/launch.sh
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/lib/launch.sh"
