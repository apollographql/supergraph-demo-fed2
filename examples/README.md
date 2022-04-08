# Federation 2 Composition Examples

## Contents

- `./examples` - various examples of subgraphs with supergraph.yaml config that can be used with the `rover supergraph` subcommand. See the main [README.md](../README.md#prerequisites) for rover install instructions.

## Using the `rover` CLI with the examples

Run an example:
```
cd ./basic

rover supergraph compose --config ./supergraph.yaml
```

Verify it composes successfully:

```
rover supergraph compose --config ./supergraph.yaml
WARN: [InconsistentFieldType]: Field "A.v1" has mismatched, but compatible, types across subgraphs: will use type "Int" (from subgraph "a") in supergraph but "A.v1" has subtype "Int!" in subgraph "b"

CoreSchema:

schema
  @core(feature: "https://specs.apollo.dev/core/v0.2")
  @core(feature: "https://specs.apollo.dev/join/v0.2", for: EXECUTION)
{
  query: Query
}

directive @core(feature: String!, as: String, for: core__Purpose) repeatable on SCHEMA

directive @join__field(graph: join__Graph!, requires: join__FieldSet, provides: join__FieldSet) repeatable on FIELD_DEFINITION | INPUT_FIELD_DEFINITION

directive @join__graph(name: String!, url: String!) on ENUM_VALUE

directive @join__implements(graph: join__Graph!, interface: String!) repeatable on OBJECT | INTERFACE

directive @join__type(graph: join__Graph!, key: join__FieldSet, extension: Boolean! = false) repeatable on OBJECT | INTERFACE | UNION | ENUM | INPUT_OBJECT | SCALAR

type A
  @join__type(graph: A, key: "k")
  @join__type(graph: B, key: "k")
{
  k: Int
  v1: Int
  v2: String @join__field(graph: A)
  v3: Int @join__field(graph: B)
}

enum core__Purpose {
  """
  `SECURITY` features provide metadata necessary to securely resolve fields.
  """
  SECURITY

  """
  `EXECUTION` features provide metadata necessary for operation execution.
  """
  EXECUTION
}

scalar join__FieldSet

enum join__Graph {
  A @join__graph(name: "a", url: "http://a:4000/graphql")
  B @join__graph(name: "b", url: "http://b:4000/graphql")
}

type Query
  @join__type(graph: A)
  @join__type(graph: B)
{
  a: A! @join__field(graph: A)
}
```

Done!

## Additional `rover` info

https://www.apollographql.com/docs/rover/