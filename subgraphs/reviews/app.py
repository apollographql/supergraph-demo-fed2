from starlette.applications import Starlette
from strawberry.asgi import GraphQL

from schema import schema

graphql_app = GraphQL(schema, graphiql=False)

app = Starlette()

app.add_route("/graphql", graphql_app)
