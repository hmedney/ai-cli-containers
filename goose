#!/usr/bin/env bash

export COMPOSE_SERVICE="goose"
export DATA_DIR="${HOME}/ai-tools/goose"
export TOOL_CMD="/home/user/.local/bin/goose"

# Path to the internal engine
LAUNCH_SCRIPT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/internal/launch.sh"

# shellcheck source=internal/launch.sh
exec "$LAUNCH_SCRIPT" "$@"
