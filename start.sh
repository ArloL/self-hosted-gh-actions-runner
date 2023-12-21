#!/bin/sh

set -o errexit
set -o nounset

echo + . /home/bob/.env
set -o allexport
. /home/bob/.env
set +o allexport

cd /home/bob/runner

echo + ./config.sh --unattended --url ... --token ...
./config.sh  \
    --unattended \
    --url "${RUNNER_URL}" \
    --token "${RUNNER_TOKEN}"

cleanup() {
    currentExitCode=$?
    echo + ./config.sh remove --token ...
    ./config.sh remove \
        --token "${RUNNER_TOKEN}"
    exit ${currentExitCode}
}

echo + trap cleanup INT TERM
trap cleanup INT TERM

echo + ./run.sh
./run.sh
