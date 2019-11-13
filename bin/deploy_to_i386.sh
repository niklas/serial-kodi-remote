#!/usr/bin/env bash

set -eux

ELIXIR_VERSION="1.9.4"
HERE="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )"

echo "Building in ${HERE}"

docker run -it --rm -h elixir.local \
       -v ${HERE}:/src \
       --mount type=tmpfs,destination=/src/_build \
       -w /src \
       i386/elixir:${ELIXIR_VERSION} ./bin/build.sh
