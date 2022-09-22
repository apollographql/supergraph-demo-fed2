# Composition in Apollo Studio

[Composition in Apollo Studio](https://www.apollographql.com/docs/federation/quickstart/studio-composition) enables multiple teams to independently publish their subgraph schemas after an updated subgraph has been deployed, and provides a supergraph CI/CD pipeline with and schema check that can assess the impact of a change using graph-native telemetry from your supergraph router. Composition in Apollo Studio supports [Contracts](https://www.apollographql.com/docs/studio/contracts/) which allows you to create slices of a unified graph (public API, partner API, internal API) for different consumers to use.

Doing local development with your own graph variant (like a branch in GitHub) enables you to see composition errors and browse your schema in Apollo Studio before deploying them to a production supergraph and provides a great developer experience.

Most of the examples in this repo use [Composition in Apollo Studio](https://www.apollographql.com/docs/federation/quickstart/studio-composition) which has some nice developer tooling that is [free for all Apollo users](https://www.apollographql.com/docs/studio/#free-for-all-apollo-users).

You can even use many of Studio's dev tools without an Apollo account using [Apollo Sandbox](https://www.apollographql.com/docs/studio/explorer/sandbox/). Apollo Router provides an embedded version of Sandbox using `router --dev` mode that can even show the query plans from the Router!

See the main [README.md](/README.md) to get started!