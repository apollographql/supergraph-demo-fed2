# Apollo Router - no code required

*No code required* - many users can migrate to the Router with the stock Router binary and a simple YAML config file

*Easy to deploy/manage* - single Router binary you can run on your laptop or a pre-built docker image you can run in k8s.  

* Stock Router binaries are available for Linux, Mac, and Windows.
* We also ship [pre-built docker images](https://www.apollographql.com/docs/router/containerization/overview) and an [updated Helm chart](https://www.apollographql.com/docs/router/containerization/kubernetes) 
* [Kubernetes examples](https://www.apollographql.com/docs/router/containerization/kubernetes) examples are also provided for use of `kustomize` and other Kubernetes tooling.

*Run with a single command* - just use the stock Router binary

*Extensive [built-in YAML configuration options](https://www.apollographql.com/docs/router/configuration/overview#yaml-config-file)*


## Download Router
    
```
curl -sSL https://router.apollo.dev/download/nix/latest | sh
```

## Router with supergraph schema from Apollo Studio

```
APOLLO_KEY=<YOUR_GRAPH_API_KEY> \
APOLLO_GRAPH_REF=<YOUR_GRAPH_ID>@<VARIANT> \
router --dev --config ./router.yaml
```

see [router.yaml](../router.yaml)

## Router with local supergraph schema

```
router --dev \
  --config ./router.yaml \
  --supergraph ./supergraph.graphql
```

See the [Apollo Router quickstart](https://www.apollographql.com/docs/router/quickstart) for more info!