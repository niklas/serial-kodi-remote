#!/usr/bin/env bash

set -eux

HERE="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )"
MACHINE="$(uname -p)"
TARGET_DIR="rel/docker/"

uname -a
echo "Building the app."

[ -f config/dev.exs ] || touch config/dev.exs
mix local.hex --force
mix deps.get
MIX_ENV=prod mix release
mkdir -p $TARGET_DIR
cp -vu _build/prod/*.tar.gz $TARGET_DIR/
chmod -R a+rwX $TARGET_DIR

echo "Done. Have a look in ${TARGET_DIR}"
