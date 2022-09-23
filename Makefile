SHELL := /bin/bash
export COMPOSE_PROJECT_NAME=supergraph-demo-fed2
export SUBGRAPH_BOOT_TIME=2

.PHONY: default
default: deps run-supergraph

# dependencies

.PHONY: deps
deps:
	@echo --------------------------------------------
	curl -sSL https://rover.apollo.dev/nix/latest | sh
	@echo --------------------------------------------
	curl -sSL https://router.apollo.dev/download/nix/latest | sh
	@echo --------------------------------------------

.PHONY: deps-windows
deps-windows:
	@echo --------------------------------------------
	iwr 'https://rover.apollo.dev/win/latest' | iex
	@echo --------------------------------------------
	curl -sSL https://router.apollo.dev/download/nix/latest | sh
	@echo --------------------------------------------

# Standalone router with basic YAML config and Open Telemetry

.PHONY: run-supergraph
run-supergraph: up-subgraphs publish-subgraphs run-router

.PHONY: build-subgraphs-no-cache
build-subgraphs-no-cache:
	docker compose \
	 -f docker-compose.yaml \
	 build --no-cache

.PHONY: up-subgraphs
up-subgraphs:
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs

.PHONY: publish-subgraphs
publish-subgraphs:
	.scripts/publish.sh

.PHONY: run-router
run-router:
	@source "./.scripts/graph-api-env-export.sh" && set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router.yaml \
	  --log info

.PHONY: query
query:
	@.scripts/query.sh

.PHONY: smoke
smoke:
	@.scripts/smoke.sh

# Local router with Rhai script

.PHONY: run-supergraph-rhai
run-supergraph-rhai: up-subgraphs publish-subgraphs run-router-rhai

.PHONY: run-router-rhai
run-router-rhai:
	@source "./.scripts/graph-api-env-export.sh" && set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router-rhai-script/router.yaml \
	  --log info

# Local router with Rust plugin

.PHONY: run-supergraph-rust-plugin
run-supergraph-rust-plugin: up-subgraphs publish-subgraphs run-router-rust-plugin

.PHONY: run-router-rust-plugin
run-router-rust-plugin: build-rust-plugin
	@source "./.scripts/graph-api-env-export.sh" && set -x; \
	 cd supergraph/router-rust-plugin && \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  --log info

.PHONY: build-rust-plugin
build-rust-plugin:
	cd supergraph/router-rust-plugin && cargo update && cargo build --release
	cd supergraph/router-rust-plugin && cp ./target/release/acme_router .

.PHONY: clean-rust-plugin
clean-rust-plugin:
	rm -rf supergraph/router-rust-plugin/target || true

.PHONY: clean-cargo-cache
clean-cargo-cache:
	rm -rf ~/.cargo/git
	rm -rf ~/.cargo/registry

.PHONY: run-supergraph-router-main
run-supergraph-router-main: up-subgraphs publish-subgraphs run-router-main

.PHONY: run-router-main
run-router-main: build-router-main
	@source "./.scripts/graph-api-env-export.sh" && \
	 cd examples/advanced/router-main && set -x; \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  --log info

.PHONY: build-router-main
build-router-main:
	cd examples/advanced/router-main && cargo update && cargo build --release
	cd examples/advanced/router-main && cp ./target/release/acme_router .

.PHONY: clean-router-main
clean-router-main:
	rm -rf examples/advanced/router-main/target || true


# Apollo Router in a docker container

.PHONY: up-supergraph
up-supergraph: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/studio/docker-compose.router-no-code.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router

.PHONY: publish-subgraphs-docker-compose
publish-subgraphs-docker-compose:
	.scripts/publish.sh "docker-compose"

.PHONY: up-supergraph-rhai
up-supergraph-rhai: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/local/docker-compose.router-rhai.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rhai

.PHONY: up-supergraph-rust-plugin
up-supergraph-rust-plugin: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/local/docker-compose.router-rust-plugin.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rust-plugin

.PHONY: build-defer-apollo-client-no-cache
build-defer-apollo-client-no-cache:
	docker compose \
	 -f client/defer/apollo-client/docker-compose.yaml \
	 build --no-cache

.PHONY: up-supergraph-defer
up-supergraph-defer: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/studio/docker-compose.router-no-code.yaml \
	 -f client/defer/apollo-client/docker-compose.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router

# gateway

.PHONY: up-supergraph-gateway
up-supergraph-gateway: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/studio/docker-compose.gateway.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-gateway

# local composition

.PHONY: config
config:
	.scripts/config.sh "localhost" > ./examples/local/supergraph/localhost.yaml 2>/dev/null
	.scripts/config.sh "docker-compose" > ./examples/local/supergraph/dockerhost.yaml 2>/dev/null

.PHONY: compose
compose:
	@set -x; cd examples/local/supergraph; \
	  rover supergraph compose --elv2-license=accept --config localhost.yaml > localhost.graphql
	@set -x; cd examples/local/supergraph; \
	  rover supergraph compose --elv2-license=accept --config dockerhost.yaml > dockerhost.graphql

# local composition with standalone router

.PHONY: run-supergraph-local
run-supergraph-local: up-subgraphs config compose run-router-local

.PHONY: run-router-local
run-router-local:
	@set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router.yaml \
	  -s ./examples/local/supergraph/localhost.graphql \
	  --log info

.PHONY: run-supergraph-rhai-local
run-supergraph-rhai-local: up-subgraphs config compose run-router-rhai-local

.PHONY: run-router-rhai-local
run-router-rhai-local:
	@set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router-rhai-script/router.yaml \
	  -s ./examples/local/supergraph/localohst.graphql \
	  --log info

.PHONY: run-supergraph-rust-plugin-local
run-supergraph-rust-plugin-local: up-subgraphs config compose run-router-rust-plugin-local

.PHONY: run-router-rust-plugin-local
run-router-rust-plugin-local: build-rust-plugin
	@cd supergraph/router-rust-plugin && set -x; \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  -s ../../examples/local/supergraph/localhost.graphql \
	  --log info

.PHONY: run-supergraph-router-main-local
run-supergraph-router-main-local: up-subgraphs config compose run-router-main-local

.PHONY: run-router-main-local
run-router-main-local: build-router-main
	@cd examples/advanced/router-main && set -x; \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  -s ../../local/supergraph/localhost.graphql \
	  --log info

# local composition with docker-compose

.PHONY: up-supergraph-local
up-supergraph-local: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/local/docker-compose.router-no-code.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router

.PHONY: up-supergraph-rhai-local
up-supergraph-rhai-local: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/local/docker-compose.router-rhai.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rhai

.PHONY: up-supergraph-rust-plugin-local
up-supergraph-rust-plugin-local: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/local/docker-compose.router-rust-plugin.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rust-plugin

.PHONY: up-supergraph-local-gateway
up-supergraph-local-gateway: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/local/docker-compose.gateway.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-gateway

# minimal local demo

.PHONY: up-supergraph-no-otel-local
up-supergraph-no-otel-local:
	docker compose \
	 -f docker-compose.yaml \
	 -f examples/local/docker-compose.router-no-otel.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router


# GitHub Actions Local Runners with ACT

.PHONY: deps-act
deps-act:
	curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s v0.2.31

ubuntu-latest=ubuntu-latest=catthehacker/ubuntu:act-latest

# router

.PHONY: ci
ci: ci-local-router-no-code ci-local-router-rhai ci-local-gateway

.PHONY: ci-local-router-no-code
ci-local-router-no-code:
	act -P $(ubuntu-latest) -W .github/workflows/local-router-no-code.yaml --detect-event

.PHONY: ci-local-router-rhai
ci-local-router-rhai:
	act -P $(ubuntu-latest) -W .github/workflows/local-router-rhai.yaml --detect-event

.PHONY: ci-local-router-rust-plugin
ci-local-router-rust-plugin:
	act -P $(ubuntu-latest) -W .github/workflows/local-router-rust-plugin.yaml --detect-event

.PHONY: ci-local-router-rust-main
ci-local-router-rust-main:
	act -P $(ubuntu-latest) -W .github/workflows/local-router-rust-main.yaml --detect-event

.PHONY: ci-studio-router-main
ci-studio-router-main:
	act -P $(ubuntu-latest) -W .github/workflows/studio-router-main.yaml --secret-file graph-api.env -s APOLLO_GRAPH_REF_ROUTER_MAIN=supergraph-router-fed2@ci-router-main --detect-event

.PHONY: ci-studio-router-no-code
ci-studio-router-no-code:
	act -P $(ubuntu-latest) -W .github/workflows/studio-router-no-code.yaml --secret-file graph-api.env --detect-event -j ci-docker-managed

# gateway

.PHONY: ci-local-gateway
ci-local-gateway:
	act -P $(ubuntu-latest) -W .github/workflows/local-gateway.yaml --detect-event

.PHONY: ci-studio-gateway
ci-studio-gateway:
	act -P $(ubuntu-latest) -W .github/workflows/studio-gateway.yaml --secret-file graph-api.env --detect-event -j ci-docker-managed


# utilities
#
.PHONY: load
load: load-250

.PHONY: load-10
load-10:
	@.scripts/smoke.sh 4000 10

.PHONY: load-100
load-100:
	@.scripts/smoke.sh 4000 100

.PHONY: load-250
load-250:
	@.scripts/smoke.sh 4000 250

.PHONY: down
down:
	docker compose down --remove-orphans


.PHONY: unpublish-subgraphs
unpublish-subgraphs:
	.scripts/unpublish.sh

.PHONY: docker-prune
docker-prune:
	.scripts/docker-prune.sh

.PHONY: deps-check
deps-check:
	.scripts/deps-check.sh
