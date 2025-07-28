#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE=claude.Dockerfile
IMAGE_NAME=local-claude-code
PROJECT_DIR=/home/hmedney/dev
DATA_DIR=/home/hmedney/ai-cli/claude
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
CURRENT_USER=$(whoami)

docker build -f ${SCRIPT_DIR}/${DOCKERFILE} -t ${IMAGE_NAME} ${SCRIPT_DIR}
docker run --rm -it \
  --user "${CURRENT_UID}:${CURRENT_GID}" \
  --volume "${PROJECT_DIR}:${PROJECT_DIR}"  \
  --volume "${DATA_DIR}:/home/user" \
  --workdir "${PWD}" \
  --env "HOME=/home/user" \
  ${IMAGE_NAME}


  # --workdir "${PROJECT_DIR}" \
# docker stop $CONTAINER_NAME
# docker rm $CONTAINER_NAME
# docker pull $IMAGE_NAME
# docker container create --name $CONTAINER_NAME --net host -v /etc/homeassistant:/config $IMAGE_NAME
# docker start $CONTAINER_NAME
# docker update --restart always $CONTAINER_NAME
# echo $FS_USER
