#!/bin/bash
# Common container launch logic.

SCRIPT_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
COMPOSE_FILE="${SCRIPT_DIR}/internal/compose/compose.yaml"
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

# Build --env flags from built-in (BUILTIN_ENV scalar) and user (${DATA_DIR}/.env) vars
COMPUTED_ENV=()
_load_env() {
  local line
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    COMPUTED_ENV+=(--env "$line")
  done <<< "$1"
}
[[ -n "${BUILTIN_ENV:-}" ]] && _load_env "$BUILTIN_ENV"

case "$1" in
  :build)
    echo "Building ${COMPOSE_SERVICE}..."
    docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE}
    exit 0
    ;;
  :rebuild)
    echo "Rebuilding ${COMPOSE_SERVICE}..."
    docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE} --no-cache
    exit 0
    ;;
  :upgrade)
    echo "Upgrading ${COMPOSE_SERVICE}..."
    docker compose --file "${COMPOSE_FILE}" build ${COMPOSE_SERVICE} --build-arg UPGRADE_CACHE_BUST=$(date +%s)
    exit 0
    ;;
  :shell)
    echo "Entering shell..."
    TOOL_CMD=(/bin/bash)
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

[[ -f "${DATA_DIR}/.env" ]] && _load_env "$(< "${DATA_DIR}/.env")"

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
  "${COMPUTED_ENV[@]}" \
  --workdir "${PWD}" \
  "${COMPOSE_SERVICE}" \
  "${TOOL_CMD[@]}" "$@"
