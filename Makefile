SHELL := /bin/bash
export SUBGRAPH_BOOT_TIME=2

.PHONY: default
default: demo

.PHONY: demo
demo: deps run-supergraph 

# dependencies

.PHONY: deps
deps:
	@curl -sSL https://rover.apollo.dev/nix/latest | sh
	@curl -sSL https://router.apollo.dev/download/nix/latest | sh

.PHONY: deps-windows
deps-windows:
	@iwr 'https://rover.apollo.dev/win/latest' | iex
	@curl -sSL https://router.apollo.dev/download/nix/latest | sh

# Standalone router with basic YAML config and Open Telemetry

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

.PHONY: run-supergraph
run-supergraph: up-subgraphs publish-subgraphs
	@source "./.scripts/graph-api-env-export.sh" && set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router.yaml \
	  --log info

.PHONY: smoke
smoke:
	@.scripts/smoke.sh

.PHONY: down
down:
	docker compose down --remove-orphans

# Local router with Rhai script

.PHONY: run-supergraph-rhai
run-supergraph-rhai: up-subgraphs publish-subgraphs 
	@source "./.scripts/graph-api-env-export.sh" && set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router-rhai-script/router.yaml \
	  --log info

# Local router with Rust plugin

.PHONY: run-supergraph-rust-plugin
run-supergraph-rust-plugin: up-subgraphs run-rust-plugin

.PHONY: run-rust-plugin
run-rust-plugin: publish-subgraphs build-rust-plugin
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
run-supergraph-router-main: up-subgraphs run-router-main

.PHONY: run-router-main
run-router-main: publish-subgraphs build-router-main
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
	 -f examples/studio/docker-compose.router-basic.yaml \
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

.PHONY: up-supergraph-defer
up-supergraph-defer: publish-subgraphs-docker-compose
	docker compose \
	 -f docker-compose.yaml \
	 -f opentelemetry/docker-compose.otel.yaml \
	 -f examples/studio/docker-compose.router-basic.yaml \
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
	  rover supergraph compose --config localhost.yaml > localhost.graphql
	@set -x; cd examples/local/supergraph; \
	  rover supergraph compose --config dockerhost.yaml > dockerhost.graphql

# local composition with standalone router

.PHONY: run-supergraph-local
run-supergraph-local: up-subgraphs config compose
	@set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router.yaml \
	  -s ./examples/local/supergraph/localhost.graphql \
	  --log info

.PHONY: run-supergraph-rhai-local
run-supergraph-rhai-local: up-subgraphs config compose
	@set -x; \
	 ./router --version && \
	 ./router --dev \
	  -c ./supergraph/router-rhai-script/router.yaml \
	  -s ./examples/local/supergraph/localohst.graphql \
	  --log info

.PHONY: run-supergraph-rust-plugin-local
run-supergraph-rust-plugin-local: up-subgraphs run-rust-plugin-local

.PHONY: run-rust-plugin-local
run-rust-plugin-local: config compose build-rust-plugin
	@cd supergraph/router-rust-plugin && set -x; \
	 ./acme_router --version && \
	 ./acme_router --dev \
	  -c ./router.yaml \
	  -s ../../examples/local/supergraph/localhost.graphql \
	  --log info

.PHONY: run-supergraph-router-main-local
run-supergraph-router-main-local: up-subgraphs run-router-main-local

.PHONY: run-router-main-local
run-router-main-local: config compose build-router-main
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
	 -f examples/local/docker-compose.router-basic.yaml \
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

# GitHub Actions Local Runners with ACT

.PHONY: deps-act
deps-act:
	curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s v0.2.31

ubuntu-latest=ubuntu-latest=catthehacker/ubuntu:act-latest

# router

.PHONY: ci
ci: ci-local-router-basic ci-local-router-rhai ci-local-gateway

.PHONY: ci-local-router-basic
ci-local-router-basic:
	act -P $(ubuntu-latest) -W .github/workflows/local-router-basic.yaml --detect-event

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

.PHONY: ci-studio-router-basic
ci-studio-router-basic:
	act -P $(ubuntu-latest) -W .github/workflows/studio-router-basic.yaml --secret-file graph-api.env --detect-event -j ci-docker-managed

# gateway

.PHONY: ci-local-gateway
ci-local-gateway:
	act -P $(ubuntu-latest) -W .github/workflows/local-gateway.yaml --detect-event

.PHONY: ci-studio-gateway
ci-studio-gateway:
	act -P $(ubuntu-latest) -W .github/workflows/studio-gateway.yaml --secret-file graph-api.env --detect-event -j ci-docker-managed


# utilities

.PHONY: unpublish-subgraphs
unpublish:
	.scripts/unpublish.sh

.PHONY: docker-prune
docker-prune:
	.scripts/docker-prune.sh

.PHONY: deps-check
deps-check:
	.scripts/deps-check.sh
