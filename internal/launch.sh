#!/usr/bin/env bash
# Common container launch logic.

SCRIPT_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
COMPOSE_FILE="${SCRIPT_DIR}/internal/compose/compose.yaml"
CURRENT_HOME="${HOME}"
CURRENT_USERNAME=$(id -u -n)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

case "$1" in
  :build)
    echo "Building ${COMPOSE_SERVICE}..."
    CURRENT_USERNAME="${CURRENT_USERNAME}" CURRENT_UID="${CURRENT_UID}" CURRENT_GID="${CURRENT_GID}" CURRENT_HOME="${CURRENT_HOME}" docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE}
    exit 0
    ;;
  :rebuild)
    echo "Rebuilding ${COMPOSE_SERVICE}..."
    CURRENT_USERNAME="${CURRENT_USERNAME}" CURRENT_UID="${CURRENT_UID}" CURRENT_GID="${CURRENT_GID}" CURRENT_HOME="${CURRENT_HOME}" docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE} --no-cache
    exit 0
    ;;
  :upgrade)
    echo "Upgrading ${COMPOSE_SERVICE}..."
    CURRENT_USERNAME="${CURRENT_USERNAME}" CURRENT_UID="${CURRENT_UID}" CURRENT_GID="${CURRENT_GID}" CURRENT_HOME="${CURRENT_HOME}" docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE} --build-arg UPGRADE_CACHE_BUST=$(date +%s)
    exit 0
    ;;
  :shell)
    echo "Entering shell..."
    TOOL_CMD="/bin/bash"
    set -- # Clear "$@" so no tool args are passed to bash
    ;;
  :watch)
    echo "Tailing http proxy requests..."
    docker compose -f ${COMPOSE_FILE} exec gateway lnav /var/log/squid/access.log
    exit 0
    ;;
  :help)
    echo "Meta commands: :build, :rebuild, :shell"
    exit 0
    ;;
  *)
    # No meta-command, so we proceed as normal with "$@" intact
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

CURRENT_HOME="${CURRENT_HOME}" CURRENT_USERNAME="${CURRENT_USERNAME}" CURRENT_UID="${CURRENT_UID}" CURRENT_GID="${CURRENT_GID}" docker compose --file "${COMPOSE_FILE}" run --rm -it \
  --entrypoint "${COMPOSE_ENTRYPOINT:-${TOOL_CMD}}" \
  --user "${CURRENT_UID}:${CURRENT_GID}" \
  --volume "${PWD}:${PWD}" \
  --volume "${DATA_DIR}:${DATA_DIR}" \
  "${SSH_MOUNT[@]}" \
  "${GIT_MOUNT[@]}" \
  --workdir "${PWD}" \
  "${COMPOSE_SERVICE}" \
  "$@"
