# Using Apollo Router

## Stock router binaries and docker images

[Stock Router binaries are available to download](https://www.apollographql.com/docs/router/quickstart) for Linux, Mac, and Windows. We also ship [pre-built docker images](https://www.apollographql.com/docs/router/containerization/overview) and a [Helm chart](https://www.apollographql.com/docs/router/containerization/kubernetes) for [Kubernetes deployments](https://www.apollographql.com/docs/router/containerization/kubernetes). Kubernetes configuration examples are also provided for use of `kustomize` and other Kubernetes tooling.

## Configuration & Customization

As the Router has been rolled out into more environments we’ve learned about the right integration points and customizations to make the Router work well:

### YAML configuration - no code required

Apollo ships a [standalone Router binary](https://www.apollographql.com/docs/router/quickstart) that can be configured using a [YAML config file](https://www.apollographql.com/docs/router/configuration/overview#yaml-config-file) with a new stable v1 configuration schema for things like header forwarding and CORS configuration. Many new features are available like [traffic shaping](https://www.apollographql.com/docs/router/configuration/traffic-shaping/) with support for rate limiting, query deduplication, configurable timeouts and compression options. Router deployments can often be done with the stock Router binary and a minimal YAML config file.

Run:
```
make run-supergraph
```

See [router.yaml](./router.yaml)

### Lightweight Rhai scripting

New official support for [Rhai scripting](https://www.apollographql.com/docs/router/customizations/rhai) with a [stable v1 API](https://www.apollographql.com/docs/router/customizations/rhai-api/) offers a safe and sandboxed way to customize the Router’s request flow. Rhai is ideal for common scripting tasks like manipulating strings, processing headers, and mutating request context. Checkout the growing cookbook of [example scripts](https://github.com/apollographql/router/tree/main/examples) that can be used with the stock Router binary as a simple way of programmatically customizing the Router for your environment.

See [Rhai scripting example](./rhai-scripting/)

### Native extensions

Many Router features are built as native extensions that can be used via standard YAML config and Rhai scripting. Native extensions are a good choice for advanced use cases when Rhai scripting is not enough. With v1.0 we have stabilized all key extension points in the [native extension API](https://www.apollographql.com/docs/router/customizations/native) and enabled more powerful schema-driven extensions to be built using Apollo’s new [Rust tooling for GraphQL](https://www.apollographql.com/blog/announcement/tooling/apollo-rs-graphql-tools-in-rust/).

See [Native extension example](./rust-plugin/) and build locally with Rust and `cargo` for the best experience.

### Adding more built-in Router functionality

Our goal over time is to identify common customizations and elevate them into standard Router features, so let us know if you have a Router customization or idea that others in the community could benefit from!

## Learn more

- [Docker and the router](https://www.apollographql.com/docs/router/containerization/docker)
- [Rhai scripts](https://www.apollographql.com/docs/router/customizations/rhai)
- [Native Rust plugins](https://www.apollographql.com/docs/router/customizations/native)