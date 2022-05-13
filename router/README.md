# Custom Router Images

The default behavior of the router image is suitable for a quickstart or development scenario.

You'll likely want to customize this default behavior either with:

- [Custom Docker image with Rhai script example](./custom-image/Dockerfile)
- [Custom Router build with native Rust plugin](./custom-plugin/Dockerfile)

Note: The exact image version to use is your choice depending on which release you wish to use. In the following examples, replace <image version> with your chosen version. e.g.: v0.9.0

Learn more:

- [Docker and the router](https://www.apollographql.com/docs/router/containerization/docker)
- [Rhai scripts](https://www.apollographql.com/docs/router/customizations/rhai)
- [Native Rust plugins](https://www.apollographql.com/docs/router/customizations/native)