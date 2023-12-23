#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

cd "$(dirname "$0")/.." || exit 1

. ./scripts/docker-build-shell-setup.sh

BUILD_COMMAND=docker
hash buildah 2>/dev/null && BUILD_COMMAND=buildah

# shellcheck disable=SC2086
${BUILD_COMMAND} build \
    --tag selfhostedghrunner:latest \
    --target "runner" \
    ${DOCKER_BUILD_ARGUMENTS} \
    --file ${BUILD_COMMAND}.Dockerfile \
    .

git diff --exit-code
