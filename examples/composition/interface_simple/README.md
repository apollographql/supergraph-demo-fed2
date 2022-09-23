A example that demonstrates an interface. It has an interface `Product` with 2 implementation `Furniture` and `Book`.
Both `Product` and `Furniture` are on subgraph A but most of the fields of `Book` are on subgraph B. It shows we
do properly generate queries for `Furniture` and `Book` separately when we need to, but also demonstrate that if
a field can be server from subgraph A for both implementations, the query plan avoid "type explosion" on that
field.
