#!/usr/bin/env bash

# Path to the internal engine
LAUNCH_SCRIPT="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/internal/launch.sh"
SCRIPT_NAME="$(basename "$0")"

# run common launch script
COMPOSE_SERVICE="${SCRIPT_NAME}" exec "${LAUNCH_SCRIPT}" "$@"
