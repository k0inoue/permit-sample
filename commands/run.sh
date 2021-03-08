#!/bin/sh
set -e
set -x

DOCKER_IMAGE_NAME=sample-image
DOCKER_CONTAINER_NAME=sample-image

[ -d "${HOME}/catkin_ws/logs" ] || mkdir -p "${HOME}/catkin_ws/logs"

# 同名のコンテナが存在する場合は停止する
#------------------------------------------------
if docker container ls --format '{{.Names}}' | grep -q -e "^${DOCKER_CONTAINER_NAME}$" ; then
  echo "起動中の ${DOCKER_CONTAINER_NAME} コンテナを停止します..."
  docker container stop ${DOCKER_CONTAINER_NAME} >/dev/null
  echo "起動中の ${DOCKER_CONTAINER_NAME} コンテナを停止しました"
fi

# 同名のコンテナが存在する場合は削除する
#------------------------------------------------
if docker container ls -a --format '{{.Names}}' | grep -q -e "^${DOCKER_CONTAINER_NAME}$" ; then
  echo "既存の ${DOCKER_CONTAINER_NAME} コンテナを削除します..."
  docker rm ${DOCKER_CONTAINER_NAME} >/dev/null
  echo "既存の ${DOCKER_CONTAINER_NAME} コンテナを削除しました"
fi

# Launch Docker Container
docker run \
    --name ${DOCKER_CONTAINER_NAME} \
    -d \
    --privileged \
    --net host \
    --mount type=bind,src=${HOME}/catkin_ws/logs,dst=/home/developer/catkin_ws/logs \
    --device /dev/snd \
    -v /dev/shm \
    -e HOST_USER_ID=$(id -u) \
    -e HOST_GROUP_ID=$(id -g) \
    ${DOCKER_IMAGE_NAME} \
    tail -f /dev/null
docker ps -a
docker logs ${DOCKER_CONTAINER_NAME}
