#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

cd "$(dirname "$0")/.." || exit 1

. ./scripts/docker-build-shell-setup.sh

./scripts/setup-docker-dev-environment.sh

IMAGE_ID_FILE=$(mktemp -u)

cleanup() {
    currentExitCode=$?
    rm -f "${IMAGE_ID_FILE}"
    exit ${currentExitCode}
}

trap cleanup INT TERM EXIT

# shellcheck disable=SC2086
docker build \
    ${DOCKER_BUILD_ARGUMENTS} \
    --build-arg X_DOCKER_USER_ID="$(id -u)" \
    --build-arg X_DOCKER_USER_GROUP_ID="$(id -u)" \
    --target "devcontainer" \
    --iidfile "${IMAGE_ID_FILE}" \
    .

IMAGE_ID=$(cat "${IMAGE_ID_FILE}")

docker run \
    --rm \
    --interactive \
    --tty \
    --entrypoint "/bin/bash" \
    --volume "${PWD}:/home/bob/app" \
    --volume "$(PWD)/.env:/home/bob/.env:ro" \
    --workdir "/home/bob/app" \
    --cap-add CAP_SETGID \
    --cap-add=sys_admin \
    --cap-add mknod \
    --security-opt apparmor=unconfined \
    --security-opt seccomp=unconfined \
    --security-opt label=disable \
    "${IMAGE_ID}"

git diff --exit-code
