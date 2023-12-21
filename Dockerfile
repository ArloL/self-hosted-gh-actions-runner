ARG DOCKER_REGISTRY=registry.hub.docker.com
FROM $DOCKER_REGISTRY/library/ubuntu:24.04 AS base

RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update \
    && apt-get --yes install \
        curl \
        coreutils \
        git \
        make \
        buildah \
        uidmap \
        libcap2-bin \
    && rm -rf /var/lib/apt/lists/*

# When using containers for development (e.g. Dev Container or `make docker`)
# the working directory is shared via a mount. In some Docker implementations
# (e.g. colima+sshfs) mounts are owned by the host user's id. To ensure the
# container user owns all the files it operates on, it is given the same id.
# To do that these values are overridden by docker compose which loads the .env
# file created by `./scripts/setup-docker-dev-environment.sh` which is called
# by `make docker` and by `initializeCommand` for Dev Containers.
ARG X_DOCKER_USER_ID=190
ARG X_DOCKER_USER_GROUP_ID=190

# Add a custom user, since some tools don't like being run as root (e.g. npm).
RUN addgroup \
        --system \
        --gid "${X_DOCKER_USER_GROUP_ID}" \
        bob \
    && adduser \
        --system \
        --ingroup bob \
        --uid "${X_DOCKER_USER_ID}" \
        --home /home/bob \
        --shell /bin/bash \
        bob \
    && mkdir -p /home/bob/app \
    && chown -R bob:bob /home/bob \
    && usermod --add-subuids 100000-165535 --add-subgids 100000-165535 bob

USER bob

RUN mkdir -p /home/bob/.local/share/containers

VOLUME /home/bob/.local/share/containers

WORKDIR /home/bob/app

RUN mkdir -p /home/bob/runner

WORKDIR /home/bob/runner

RUN curl -o actions-runner-linux-arm64-2.311.0.tar.gz \
    -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-arm64-2.311.0.tar.gz \
    && echo "5d13b77e0aa5306b6c03e234ad1da4d9c6aa7831d26fd7e37a3656e77153611e  actions-runner-linux-arm64-2.311.0.tar.gz" | sha256sum -c \
    && tar xzf ./actions-runner-linux-arm64-2.311.0.tar.gz

USER root

RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    ./bin/installdependencies.sh \
    && rm -rf /var/lib/apt/lists/*

USER bob

WORKDIR /home/bob/app

COPY --chown=bob:bob start.sh .

FROM base as devcontainer

FROM base as runner
ENTRYPOINT ["./start.sh"]
