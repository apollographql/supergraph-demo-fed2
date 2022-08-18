.PHONY: default
default: demo

.PHONY: ci
ci: supergraph docker-build-force docker-up-local smoke docker-down

.PHONY: ci-router
ci-router: supergraph docker-build-force docker-up-local-router smoke docker-down

.PHONY: demo
demo: publish take-five docker-up-managed smoke docker-down

.PHONY: demo-router
demo-router: publish take-five docker-up-managed-router smoke docker-down

.PHONY: demo-local
demo-local: supergraph docker-up-local smoke docker-down

.PHONY: demo-local-router
demo-local-router: supergraph docker-up-local-router smoke docker-down-router

.PHONY: demo-rebuild
demo-rebuild: supergraph docker-build-force docker-up-local smoke docker-down

.PHONY: docker-up
docker-up: docker-up-local

.PHONY: docker-up-local
docker-up-local:
	docker-compose -f docker-compose.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	@docker logs apollo-gateway

.PHONY: docker-up-managed
docker-up-managed:
	docker-compose -f docker-compose.managed.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	@docker logs apollo-gateway

.PHONY: docker-up-local-router
docker-up-local-router:
	docker-compose -f docker-compose.router.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	@docker logs apollo-router

.PHONY: docker-up-managed-router
docker-up-managed-router:
	docker-compose -f docker-compose.router-managed.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	@docker logs apollo-router

.PHONY: docker-up-local-router-custom-image
docker-up-local-router-custom-image:
	docker-compose -f docker-compose.router-custom-image.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	@docker logs apollo-router-custom-image

.PHONY: docker-logs-local-router-custom-image
docker-logs-local-router-custom-image:
	@docker logs apollo-router-custom-image

.PHONY: docker-up-local-router-custom-plugin
docker-up-local-router-custom-plugin:
	docker-compose -f docker-compose.router-custom-plugin.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	@docker logs apollo-router-custom-plugin

.PHONY: docker-build
docker-build:
	docker-compose build

.PHONY: docker-build-force
docker-build-force:
	docker-compose build --no-cache --pull --parallel --progress plain

.PHONY: docker-build-router
docker-build-router: docker-build-router-image docker-build-router-plugin   

.PHONY: docker-build-router-image
docker-build-router-image:
	@docker build -t supergraph-demo-fed2_apollo-router-custom-image router/custom-image/. --no-cache

.PHONY: docker-build-router-plugin
docker-build-router-plugin:
	@docker build -t supergraph-demo-fed2_apollo-router-custom-plugin router/custom-plugin/.

.PHONY: docker-products-hot-reload
docker-products-hot-reload:
	docker-compose -f docker-compose.router-otel.yml up --detach --build products

.PHONY: docker-products-logs
docker-products-logs:
	docker-compose -f docker-compose.router-otel.yml logs products

.PHONY: query
query:
	@.scripts/query.sh

.PHONY: smoke
smoke:
	@.scripts/smoke.sh

# use with make docker-up-managed and Apollo Studio
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

.PHONY: docker-down
docker-down:
	docker-compose down --remove-orphans

.PHONY: docker-down-router
docker-down-router:
	docker-compose -f docker-compose.router.yml down --remove-orphans

.PHONY: supergraph
supergraph: config compose

.PHONY: config
config:
	.scripts/config.sh > ./supergraph.yaml

.PHONY: compose
compose:
	.scripts/compose.sh

.PHONY: publish
publish:
	.scripts/publish.sh

.PHONY: unpublish
unpublish:
	.scripts/unpublish.sh

.PHONY: graph-api-env
graph-api-env:
	@.scripts/graph-api-env.sh

.PHONY: check-products
check-products:
	.scripts/check-products.sh

.PHONY: check-all
check-all:
	.scripts/check-all.sh

.PHONY: docker-up-zipkin
docker-up-zipkin:
	docker-compose -f docker-compose.otel-zipkin.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	docker-compose -f docker-compose.otel-zipkin.yml logs

.PHONY: docker-down-zipkin
docker-down-zipkin:
	docker-compose -f docker-compose.otel-zipkin.yml down

.PHONY: docker-up-otel-collector
docker-up-otel-collector:
	docker-compose -f docker-compose.otel-collector.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	docker-compose -f docker-compose.otel-collector.yml logs

.PHONY: docker-down-otel-collector
docker-down-otel-collector:
	docker-compose -f docker-compose.otel-collector.yml down

.PHONY: docker-up-router-otel
docker-up-router-otel:
	docker-compose -f docker-compose.router-otel.yml up -d
	@echo "waiting for Kotlin inventory subgraph to initialize"
	@sleep 4
	docker-compose -f docker-compose.router-otel.yml logs

.PHONY: docker-down-router-otel
docker-down-router-otel:
	docker-compose -f docker-compose.router-otel.yml down

.PHONY: dep-act
dep-act:
	curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s v0.2.23

ubuntu-latest=ubuntu-latest=catthehacker/ubuntu:act-latest

.PHONY: act
act: act-ci-local

.PHONY: act-ci-local
act-ci-local:
	act -P $(ubuntu-latest) -W .github/workflows/main.yml --detect-event

.PHONY: act-ci-local-router
act-ci-local-router:
	act -P $(ubuntu-latest) -W .github/workflows/main-router.yml --detect-event

.PHONY: act-ci-local-router-custom-image
act-ci-local-router-custom-image:
	act -P $(ubuntu-latest) -W .github/workflows/main-router-custom-image.yml --detect-event

.PHONY: act-ci-local-router-custom-plugin
act-ci-local-router-custom-plugin:
	act -P $(ubuntu-latest) -W .github/workflows/main-router-custom-plugin.yml --detect-event

.PHONY: act-ci-managed
act-ci-managed:
	act -P $(ubuntu-latest) -W .github/workflows/managed.yml --secret-file graph-api.env --detect-event -j ci-docker-managed

.PHONY: act-ci-managed-router
act-ci-managed-router:
	act -P $(ubuntu-latest) -W .github/workflows/managed-router.yml --secret-file graph-api.env --detect-event -j ci-docker-managed

.PHONY: act-rebase
act-rebase:
	act -P $(ubuntu-latest) -W .github/workflows/rebase.yml -s GITHUB_TOKEN --secret-file docker.secrets --detect-event

.PHONY: act-release
act-release:
	act -P $(ubuntu-latest) -W .github/workflows/release.yml --secret-file docker.secrets

.PHONY: act-subgraph-check
act-subgraph-check:
	act -P $(ubuntu-latest) -W .github/workflows/subgraph-check.yml --secret-file graph-api.env --detect-event

.PHONY: act-subgraph-deploy-publish
act-subgraph-deploy-publish:
	act -P $(ubuntu-latest) -W .github/workflows/subgraph-deploy-publish.yml --secret-file graph-api.env --detect-event

.PHONY: docker-prune
docker-prune:
	.scripts/docker-prune.sh

.PHONY: take-five
take-five:
	@echo waiting for robots to finish work ...
	@sleep 5
