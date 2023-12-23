.PHONY: buildah docker

buildah:
	@./scripts/setup-docker-dev-environment.sh
	@docker compose up --build --detach --remove-orphans buildah
	@docker compose exec buildah /bin/bash
	@docker compose down

docker:
	@./scripts/setup-docker-dev-environment.sh
	@docker compose up --build --detach --remove-orphans docker
	@docker compose exec docker /bin/bash
	@docker compose down
