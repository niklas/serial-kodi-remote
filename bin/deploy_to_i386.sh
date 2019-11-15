#!/usr/bin/env bash

set -eux

TARGET_HOST=${1:-localhost}
TARGET_DIR=${2:-~/skr}
ELIXIR_VERSION="1.9.4"
HERE="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )"

echo "Building in ${HERE}"

docker run -it --rm -h elixir.local \
       -v ${HERE}:/src \
       --mount type=tmpfs,destination=/src/_build \
       -w /src \
       i386/elixir:${ELIXIR_VERSION} ./bin/build.sh

LATEST=$(ls -1tr rel/docker/*.tar.gz | tail -n 1)

echo "Deploying ${LATEST} to ${TARGET_HOST}:${TARGET_DIR}"

ssh ${TARGET_HOST} "mkdir -p ${TARGET_DIR}"
scp ${LATEST} ${TARGET_HOST}:/tmp/
ssh ${TARGET_HOST} "cd ${TARGET_DIR} && tar xfz /tmp/$(basename $LATEST)"
ssh ${TARGET_HOST} "systemctl --user stop skr; systemctl --user start skr"
echo "waiting for the service to start"
sleep 10
ssh ${TARGET_HOST} "systemctl --user status skr"
