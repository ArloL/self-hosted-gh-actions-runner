#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

cd "$(dirname "$0")/.." || exit 1

if [ ! -f .env ]; then

    tee .env <<EOF
X_DOCKER_USER_ID=$(id -u)
X_DOCKER_USER_GROUP_ID=\${X_DOCKER_USER_ID}
EOF

fi
