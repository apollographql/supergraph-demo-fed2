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

.PHONY: down
down:
	docker compose down --remove-orphans

# Standalone router with no --dev flag

.PHONY: run-supergraph-no-dev
run-supergraph-no-dev: up-subgraphs publish-subgraphs run-router-no-dev

.PHONY: run-router-no-dev
run-router-no-dev:
	@source "./.scripts/graph-api-env-export.sh" && set -x; \
	 ./router --version && \
	 ./router \
	  -c ./supergraph/router.yaml \
	  --log info

# Standalone router with Rhai script

.PHONY: run-supergraph-rhai
run-supergraph-rhai: up-subgraphs publish-subgraphs run-router-rhai

.PHONY: run-router-rhai
run-router-rhai:
	@source "./.scripts/graph-api-env-export.sh" && set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router-rhai-script/router.yaml \
	  --log info

# Standalone router with Rust plugin

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

.PHONY: run-supergraph-router-dev
run-supergraph-router-dev: up-subgraphs publish-subgraphs run-router-dev

.PHONY: run-router-dev
run-router-dev: build-router-dev
	@source "./.scripts/graph-api-env-export.sh" && \
	 cd misc/advanced/router-dev && set -x; \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  --log info

.PHONY: build-router-dev
build-router-dev:
	cd misc/advanced/router-dev && cargo update && cargo build --release
	cd misc/advanced/router-dev && cp ./target/release/acme_router .

.PHONY: clean-router-dev
clean-router-dev:
	rm -rf misc/advanced/router-dev/target || true

# router in docker

.PHONY: up-supergraph
up-supergraph: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f misc/studio/docker-compose.router-no-code.yaml \
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
	 -f misc/local/docker-compose.router-rhai.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rhai

.PHONY: up-supergraph-rust-plugin
up-supergraph-rust-plugin: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f misc/local/docker-compose.router-rust-plugin.yaml \
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
	 -f misc/studio/docker-compose.router-no-code.yaml \
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
	 -f misc/studio/docker-compose.gateway.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-gateway

# local composition

.PHONY: config
config:
	.scripts/config.sh "localhost" > ./supergraph/schema/local.yaml 2>/dev/null
	.scripts/config.sh "docker-compose" > ./supergraph/schema/docker.yaml 2>/dev/null

.PHONY: compose
compose:
	@set -x; cd supergraph/schema; \
	  rover supergraph compose --elv2-license=accept --config local.yaml > local.graphql
	@set -x; cd supergraph/schema; \
	  rover supergraph compose --elv2-license=accept --config docker.yaml > docker.graphql

# standalone router with local composition

.PHONY: run-supergraph-local
run-supergraph-local: up-subgraphs config compose run-router-local

.PHONY: run-router-local
run-router-local:
	@set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router.yaml \
	  -s ./supergraph/schema/local.graphql \
	  --log info

# standalone router with local composition and no --dev flag

.PHONY: run-supergraph-local-no-dev
run-supergraph-local-no-dev: up-subgraphs config compose run-router-local-no-dev

.PHONY: run-router-local-no-dev
run-router-local-no-dev:
	@set -x; \
	 ./router --version && \
	 ./router \
	  -c ./supergraph/router.yaml \
	  -s ./supergraph/schema/local.graphql \
	  --log info

# standalone router with local composition and rhai scripting

.PHONY: run-supergraph-rhai-local
run-supergraph-rhai-local: up-subgraphs config compose run-router-rhai-local

.PHONY: run-router-rhai-local
run-router-rhai-local:
	@set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router-rhai-script/router.yaml \
	  -s ./supergraph/schema/local.graphql \
	  --log info

# standalone router with local composition and rust plugin

.PHONY: run-supergraph-rust-plugin-local
run-supergraph-rust-plugin-local: up-subgraphs config compose run-router-rust-plugin-local

.PHONY: run-router-rust-plugin-local
run-router-rust-plugin-local: build-rust-plugin
	@cd supergraph/router-rust-plugin && set -x; \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  -s ../schema/local.graphql \
	  --log info

# standalone router with local composition and router dev build

.PHONY: run-supergraph-router-dev-local
run-supergraph-router-dev-local: up-subgraphs config compose run-router-dev-local

.PHONY: run-router-dev-local
run-router-dev-local: build-router-dev
	@cd misc/advanced/router-dev && set -x; \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  -s ../schema/local.graphql \
	  --log info

# router in docker and local composition

.PHONY: up-supergraph-local
up-supergraph-local: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f misc/local/docker-compose.router-no-code.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router

.PHONY: up-supergraph-rhai-local
up-supergraph-rhai-local: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f misc/local/docker-compose.router-rhai.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rhai

.PHONY: up-supergraph-rust-plugin-local
up-supergraph-rust-plugin-local: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f misc/local/docker-compose.router-rust-plugin.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router-rust-plugin

.PHONY: up-supergraph-local-gateway
up-supergraph-local-gateway: config compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f misc/local/docker-compose.gateway.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-gateway

# minimal local demo

.PHONY: up-supergraph-no-otel-local
up-supergraph-no-otel-local:
	docker compose \
	 -f docker-compose.yaml \
	 -f misc/local/docker-compose.router-no-otel.yaml \
	 up -d --build
	@set -x; sleep $$SUBGRAPH_BOOT_TIME
	docker compose logs
	docker compose logs apollo-router


# GitHub Actions Local Runners with ACT

.PHONY: deps-act
deps-act:
	curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s v0.2.31

ubuntu-latest=ubuntu-latest=catthehacker/ubuntu:act-latest

.PHONY: ci
ci: ci-local

.PHONY: ci-all
ci-all: ci-local ci-studio

.PHONY: ci-local
ci-local: ci-local-router-no-code ci-local-router-rhai ci-local-gateway

.PHONY: ci-local-rust
ci-local-rust: ci-local-router-rust-plugin ci-local-router-rust-dev

.PHONY: ci-local-all
ci-local-all: ci-local ci-local-rust

.PHONY: ci-studio
ci-studio: ci-studio-router-no-code ci-studio-gateway

# router

.PHONY: ci-local-router-no-code
ci-local-router-no-code:
	act -P $(ubuntu-latest) \
	-W .github/workflows/local-router-no-code.yaml \
	--detect-event

.PHONY: ci-local-router-rhai
ci-local-router-rhai:
	act -P $(ubuntu-latest) \
	-W .github/workflows/local-router-rhai.yaml \
	--detect-event

.PHONY: ci-local-router-rust-plugin
ci-local-router-rust-plugin:
	act -P $(ubuntu-latest) \
	-W .github/workflows/local-router-rust-plugin.yaml \
	--detect-event

.PHONY: ci-local-router-rust-dev
ci-local-router-rust-dev:
	act -P $(ubuntu-latest) \
	-W .github/workflows/local-router-rust-dev.yaml \
	--detect-event

.PHONY: ci-studio-router-dev
ci-studio-router-dev:
	act -P $(ubuntu-latest) \
	-W .github/workflows/studio-router-rust-dev.yaml \
	--secret-file graph-api.env \
	-s APOLLO_GRAPH_REF_ROUTER_DEV=supergraph-router-fed2@ci-router-dev \
	--detect-event

.PHONY: ci-studio-router-no-code
ci-studio-router-no-code:
	act -P $(ubuntu-latest) \
	-W .github/workflows/studio-router-no-code.yaml \
	--secret-file graph-api.env \
	-s APOLLO_GRAPH_REF_ROUTER=supergraph-router-fed2@ci-router \
	--detect-event \
	-j ci-docker-managed

# gateway

.PHONY: ci-local-gateway
ci-local-gateway:
	act -P $(ubuntu-latest) \
	-W .github/workflows/local-gateway.yaml \
	--detect-event

.PHONY: ci-studio-gateway
ci-studio-gateway:
	act -P $(ubuntu-latest) \
	-W .github/workflows/studio-gateway.yaml \
	--secret-file graph-api.env \
	-s APOLLO_GRAPH_REF=supergraph-router-fed2@ci-gateway \
	--detect-event \
	-j ci-docker-managed

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

.PHONY: unpublish-subgraphs
unpublish-subgraphs:
	.scripts/unpublish.sh

.PHONY: docker-prune
docker-prune:
	.scripts/docker-prune.sh

.PHONY: deps-check
deps-check:
	.scripts/deps-check.sh
