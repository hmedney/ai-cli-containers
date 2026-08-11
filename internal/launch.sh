#!/usr/bin/env bash
# Common container launch script.

SCRIPT_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
COMPOSE_FILE="${SCRIPT_DIR}/internal/compose/compose.yaml"
CURRENT_HOME="${HOME}"
CURRENT_USERNAME=$(id -u -n)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

function with_env() {
  COMPOSE_SERVICE="${COMPOSE_SERVICE}" CURRENT_USERNAME="${CURRENT_USERNAME}" CURRENT_UID="${CURRENT_UID}" CURRENT_GID="${CURRENT_GID}" CURRENT_HOME="${CURRENT_HOME}" "$@"
}

# setup local dir
mkdir -p ${HOME}/cli-tools/${COMPOSE_SERVICE}

case "$1" in
  :build)
    echo "Building ${COMPOSE_SERVICE}..."
    with_env docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE}
    exit 0
    ;;
  :rebuild)
    echo "Rebuilding ${COMPOSE_SERVICE}..."
    with_env docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE} --no-cache
    exit 0
    ;;
  :upgrade)
    echo "Upgrading ${COMPOSE_SERVICE}..."
    with_env docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE} --build-arg UPGRADE_CACHE_BUST=$(date +%s)
    exit 0
    ;;
  :shell)
    echo "Entering shell..."
    with_env docker compose --file "${COMPOSE_FILE}" run --rm --entrypoint /bin/bash ${COMPOSE_SERVICE}
    ;;
  :watch)
    echo "Tailing http proxy requests..."
    docker compose --file "${COMPOSE_FILE}" exec gateway lnav /var/log/squid/access.log
    exit 0
    ;;
  :help)
    echo "Meta commands: :build, :rebuild, :upgrade, :shell :watch"
    exit 0
    ;;
  *)
    # No meta-command, so we proceed as normal with "$@" intact
    ;;
esac

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

with_env docker compose --file "${COMPOSE_FILE}" run --rm -it \
  --user "${CURRENT_UID}:${CURRENT_GID}" \
  "${SSH_MOUNT[@]}" \
  "${GIT_MOUNT[@]}" \
  "${COMPOSE_SERVICE}" \
  "$@"


  # --volume "${PWD}:${PWD}" \
  # --volume "${DATA_DIR}:${DATA_DIR}" \
