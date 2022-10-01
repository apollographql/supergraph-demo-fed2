## Pre-built Docker Images & Docker Compose

> The `make` commands prefixed with `up-` will use `docker-compose up` with the main subgraphs [docker-compose.yaml](/docker-compose.yaml) plus one of the graph router docker-compose files in [local](./local/) or [studio](./studio/).

See the [docker-compose examples](/README.md#apollo-router-pre-built-docker-images) in the main [README.md](/README.md) to get started.

[Kubernetes examples](https://www.apollographql.com/docs/router/containerization/kubernetes) for use of `kustomize` and other Kubernetes tooling, plus a [Helm chart](https://www.apollographql.com/docs/router/containerization/kubernetes) are also provided.

## Run the Router directly for better local dev UX

The Apollo Router [can also be downloaded](/README.md#prerequisites) and run as a single standalone binary on your laptop using `make run-supergraph` where you can see the enhanced log output formatting for a better local developer experience. See the [build your first supergraph](/README.md#build-your-first-supergraph) to get started.

## Supergraph Composition

The [Apollo Federation Docs](https://www.apollographql.com/docs/federation/) do a great job explaining the basics of composition in Apollo Studio and local composition.

## Composition in Apollo Studio

[Composition in Apollo Studio](https://www.apollographql.com/docs/federation/quickstart/studio-composition) enables multiple teams to independently publish their subgraph schemas after an updated subgraph has been deployed, and provides a supergraph CI/CD pipeline with and schema check that can assess the impact of a change using graph-native telemetry from your supergraph router. Composition in Apollo Studio supports [Contracts](https://www.apollographql.com/docs/studio/contracts/) which allows you to create slices of a unified graph (public API, partner API, internal API) for different consumers to use.

Doing local development with your own graph variant (like a branch in GitHub) enables you to see composition errors and browse your schema in Apollo Studio before deploying them to a production supergraph and provides a great developer experience.

Most of the examples in this repo use [Composition in Apollo Studio](https://www.apollographql.com/docs/federation/quickstart/studio-composition) which has some nice developer tooling that is [free for all Apollo users](https://www.apollographql.com/docs/studio/#free-for-all-apollo-users).

You can even use many of Studio's dev tools without an Apollo account using [Apollo Sandbox](https://www.apollographql.com/docs/studio/explorer/sandbox/). Apollo Router provides an embedded version of Sandbox using `router --dev` mode that can even show the query plans from the Router!

Get started by [downloading the rover CLI and router binary](/README.md#prerequisites) and following the steps on how to [build your first supergraph](/README.md#build-your-first-supergraph).

## Local Composition

[Local composition](/README.md#local-composition) using `rover supergraph compose` can be used for simple local development use cases and air-gapped environments.

However, in most cases [Composition in Apollo Studio](https://www.apollographql.com/docs/federation/quickstart/studio-composition) is preferred even for local development as newly published subgraphs are composed and automatically deployed to your local supergraph router which is listening for changes, so the supergraph automatically updates whenever you `rover subgraph publish` a new schema to the schema registry, typically after the subgraph has been updated with schema updates that need to be composed into your supergraph.
