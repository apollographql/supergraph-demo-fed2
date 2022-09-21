export COMPOSE_PROJECT_NAME=supergraph-demo-fed2
export SUBGRAPH_BOOT_TIME=4
SHELL := /bin/bash

.PHONY: default
default: demo

.PHONY: demo
demo: deps run-supergraph

# local router with subgraphs listening on localhost networking with otel
.PHONY: run-supergraph
run-supergraph: up-subgraphs publish-subgraphs run-router

.PHONY: run-supergraph-rhai
run-supergraph-rhai: up-subgraphs publish-subgraphs run-router-rhai

.PHONY: run-supergraph-rust-plugin
run-supergraph-rust-plugin: up-subgraphs publish-subgraphs run-router-rust-plugin

.PHONY: up-subgraphs
up-subgraphs:
	docker compose up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs

.PHONY: publish-subgraphs
publish-subgraphs:
	.scripts/publish.sh

.PHONY: unpublish-subgraphs
unpublish:
	.scripts/unpublish.sh

.PHONY: run-router
run-router:
	@./router --version
	@source "./.scripts/graph-api-env-export.sh" && \
		set -x; \
		./router --dev -c ./supergraph/router/router.yaml --log info

.PHONY: smoke
smoke:
	@.scripts/smoke.sh

.PHONY: down
down:
	docker compose down --remove-orphans

.PHONY: run-router-rhai
run-router-rhai:
	@./router --version
	@source "./.scripts/graph-api-env-export.sh" && \
		set -x; \
		./router --dev -c ./supergraph/router/customizations/rhai/router.yaml --log info

.PHONY: run-router-rust-plugin
run-router-rust-plugin: build-router-rust-plugin
	@./supergraph/router/customizations/rust-plugin/acme_router --version
	@source "./.scripts/graph-api-env-export.sh" && \
    cd supergraph/router/customizations/rust-plugin && \
	set -x; \
	./acme_router --dev -c ./router.yaml --log info

.PHONY: build-router-rust-plugin
build-router-rust-plugin:
	cd supergraph/router/customizations/rust-plugin && cargo update && cargo build --release
	cd supergraph/router/customizations/rust-plugin && cp ./target/release/acme_router .

.PHONY: clean-router-rust-plugin
clean-router-plugin:
	rm -rf supergraph/router/customizations/rust-plugin/target || true

.PHONY: clean-cargo-cache
clean-cargo-cache:
	rm -rf ~/.cargo/git
	rm -rf ~/.cargo/registry

# docker-compose router and gateway with up-* make commands

.PHONY: up-supergraph-router
up-supergraph-router: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.yaml \
	 -f supergraph/router/docker-compose.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router

.PHONY: publish-subgraphs-docker-compose
publish-subgraphs-docker-compose:
	.scripts/publish.sh "docker-compose"

.PHONY: up-supergraph-router-rhai
up-supergraph-router-rhai: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.yaml \
	 -f supergraph/router/customizations/rhai/docker-compose.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rhai

.PHONY: up-supergraph-router-rust-plugin
up-supergraph-router-rust-plugin: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.yaml \
	 -f supergraph/router/customizations/rust-plugin/docker-compose.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rust-plugin

.PHONY: up-supergraph-router-defer
up-supergraph-router-defer: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.yaml \
	 -f supergraph/router/docker-compose.yaml \
	 -f client/defer/apollo-client/docker-compose.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router

.PHONY: up-supergraph-gateway
up-supergraph-gateway: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.yaml \
	 -f supergraph/gateway/docker-compose.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-gateway

.PHONY: up-supergraph-gateway-local-composition
up-supergraph-gateway-local-composition: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.yaml \
	 -f examples/composition/local/gateway-docker/docker-compose.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-gateway

.PHONY: config
config:
	.scripts/config.sh "localhost" > ./examples/composition/local/supergraph.localhost.yaml 2>/dev/null
	.scripts/config.sh "docker-compose" > ./examples/composition/local/supergraph.dockerhost.yaml 2>/dev/null 

.PHONY: compose
compose:
	.scripts/compose.sh

.PHONY: docker-prune
docker-prune:
	.scripts/docker-prune.sh

.PHONY: take-five
take-five:
	@echo waiting for robots to finish work ...
	@sleep 5

.PHONY: deps
deps:
	@curl -sSL https://rover.apollo.dev/nix/latest | sh
	@curl -sSL https://router.apollo.dev/download/nix/latest | sh

.PHONY: deps-windows
deps-windows:
	@iwr 'https://rover.apollo.dev/win/latest' | iex
	@curl -sSL https://router.apollo.dev/download/nix/latest | sh
