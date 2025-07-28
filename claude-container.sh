#!/bin/bash

DOCKERFILE=claude.Dockerfile
IMAGE_NAME=local-claude-code
PROJECT_DIR=/home/hmedney/dev
DATA_DIR=/home/hmedney/ai-cli/claude
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
CURRENT_USER=$(whoami)

docker build -f ${DOCKERFILE} -t ${IMAGE_NAME} .
docker run --rm -it \
  --user "${CURRENT_UID}:${CURRENT_GID}" \
  --volume "${PROJECT_DIR}:${PROJECT_DIR}"  \
  --volume "${DATA_DIR}:/home/user" \
  --workdir "/home/user" \
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
