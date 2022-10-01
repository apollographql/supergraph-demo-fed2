# Local Composition

Local composition using `rover supergraph compose` is covered here with several examples. Local composition can be useful for simple local development use cases and air-gapped environments.

However, in most cases [Composition in Apollo Studio](https://www.apollographql.com/docs/federation/quickstart/studio-composition) is preferred even for local development as newly published subgraphs are composed and automatically deployed to your local supergraph router which is listening for changes, so the supergraph automatically updates whenever you `rover subgraph publish` a new schema to the schema registry.
