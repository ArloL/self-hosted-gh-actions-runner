.PHONY: docker

docker:
	@./scripts/setup-docker-dev-environment.sh
	@docker compose up --build --detach --remove-orphans runner
	@docker compose exec runner /bin/bash
	@docker compose down
