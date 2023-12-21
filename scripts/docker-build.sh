#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

cd "$(dirname "$0")/.." || exit 1

. ./scripts/docker-build-shell-setup.sh

# shellcheck disable=SC2086
docker build \
        --target "runner" \
        ${DOCKER_BUILD_ARGUMENTS} \
        .

git diff --exit-code
