#!/usr/bin/env bash
LAUNCH_SCRIPT="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/internal/launch.sh"
COMPOSE_SERVICE="$(basename "$0")" exec "${LAUNCH_SCRIPT}" "$@"
