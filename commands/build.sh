#!/bin/sh
WORK_DIR=$(cd "$(dirname $0)/../"; pwd)
docker build -t sample-image -f docker/kit/Dockerfile ${WORK_DIR}