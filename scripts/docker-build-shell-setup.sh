#!/bin/sh

set -o errexit
set -o nounset

# shellcheck source=${HOME}/.jenkins_shell_env
if [ -f "${HOME}/.jenkins_shell_env" ]; then
    . "${HOME}/.jenkins_shell_env"
fi

whoami
groups
set

export DOCKER_BUILD_ARGUMENTS=""
if [ "${DOCKER_CACHE_ENABLED:-true}" = "false" ]; then
    export DOCKER_BUILD_ARGUMENTS="--no-cache"
fi
