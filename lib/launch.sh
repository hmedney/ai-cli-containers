#!/bin/bash
# Common container launch logic.
# Caller must set: IMAGE_NAME, DOCKERFILE, DATA_DIR, TOOL_CMD
# Caller may set: EXTRA_ENV (array of --env flags, e.g. --env KEY or --env KEY=value)
EXTRA_ENV=("${EXTRA_ENV[@]}")

SCRIPT_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

case "$1" in
  --build-container)
    echo "Building ${IMAGE_NAME} image..."
    docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE}
    exit 0
    ;;
  --rebuild-container)
    echo "Rebuilding ${IMAGE_NAME} image (no cache)..."
    docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE} --no-cache
    exit 0
    ;;
  --container-help)
    echo "$(basename "$0") container options: --build-container, --rebuild-container"
    exit 0
    ;;
esac

mkdir -p "${DATA_DIR}"

SSH_MOUNT=()
if [ -n "${SSH_AUTH_SOCK:-}" ]; then
  SSH_MOUNT=(
    --volume "${SSH_AUTH_SOCK}:/tmp/ssh-agent.sock"
    --env "SSH_AUTH_SOCK=/tmp/ssh-agent.sock"
  )
fi

GIT_MOUNT=()
if [ -f "${HOME}/.gitconfig" ]; then
  GIT_MOUNT=(--volume "${HOME}/.gitconfig:/etc/gitconfig:ro")
fi

docker compose --file "${COMPOSE_FILE}" run --rm -it \
  --user "${CURRENT_UID}:${CURRENT_GID}" \
  --volume "${PWD}:${PWD}" \
  --volume "${DATA_DIR}:/home/user" \
  --env HOME="/home/user" \
  "${SSH_MOUNT[@]}" \
  "${GIT_MOUNT[@]}" \
  "${EXTRA_ENV[@]}" \
  --workdir "${PWD}" \
  "${COMPOSE_SERVICE}" \
  ${TOOL_CMD} $@
