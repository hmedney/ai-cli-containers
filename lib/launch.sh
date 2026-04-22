#!/bin/bash
# Common container launch logic.
# Caller must set: IMAGE_NAME, DOCKERFILE, DATA_DIR, TOOL_CMD
# Caller may set: EXTRA_ENV (array of --env flags, e.g. --env KEY or --env KEY=value)
EXTRA_ENV=("${EXTRA_ENV[@]}")

SCRIPT_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

case "$1" in
  --build-container)
    echo "Building ${IMAGE_NAME} image..."
    shift
    docker build -f "${SCRIPT_DIR}/${DOCKERFILE}" -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
    exit 0
    ;;
  --rebuild-container)
    echo "Rebuilding ${IMAGE_NAME} image (no cache)..."
    shift
    docker build -f "${SCRIPT_DIR}/${DOCKERFILE}" -t "${IMAGE_NAME}" "${SCRIPT_DIR}" --no-cache --pull
    exit 0
    ;;
  --container-help)
    echo "$(basename "$0") container options: --build-container, --rebuild-container"
    exit 0
    ;;
esac

mkdir -p "${DATA_DIR}"

if [ -z "$(docker images -q "${IMAGE_NAME}" 2>/dev/null)" ]; then
  echo "Building ${IMAGE_NAME} image..."
  docker build -f "${SCRIPT_DIR}/${DOCKERFILE}" -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
fi

SSH_MOUNT=()
if [ -n "${SSH_AUTH_SOCK:-}" ]; then
  echo "Forwarding SSH agent..."
  SSH_MOUNT=(
    --volume "${SSH_AUTH_SOCK}:/tmp/ssh-agent.sock"
    --env "SSH_AUTH_SOCK=/tmp/ssh-agent.sock"
  )
fi

GIT_MOUNT=()
if [ -f "${HOME}/.gitconfig" ]; then
  GIT_MOUNT=(--volume "${HOME}/.gitconfig:/etc/gitconfig:ro")
fi

docker run --rm -it \
  --user "${CURRENT_UID}:${CURRENT_GID}" \
  --volume "${PWD}:${PWD}" \
  --volume "${DATA_DIR}:/home/user" \
  --env HOME="/home/user" \
  "${SSH_MOUNT[@]}" \
  "${GIT_MOUNT[@]}" \
  "${EXTRA_ENV[@]}" \
  --workdir "${PWD}" \
  "${IMAGE_NAME}" \
  ${TOOL_CMD} "$@"
