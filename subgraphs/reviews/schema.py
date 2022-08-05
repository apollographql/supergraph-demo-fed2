import strawberry


@strawberry.type
class Review:
    id: int
    body: str


def get_reviews(root: "Product") -> list[Review]:
    return [
        Review(id=id_, body=f"A review for {root.id}")
        for id_ in range(root.reviews_count)
    ]


@strawberry.federation.type(keys=["id"])
class Product:
    id: strawberry.ID
    reviews_count: int
    reviews_score: float = strawberry.federation.field(
        override="products", shareable=True
    )
    reviews: list[Review] = strawberry.field(resolver=get_reviews)

    @classmethod
    def resolve_reference(cls, id: strawberry.ID):
        return Product(id=id, reviews_count=3, reviews_score=4.6)


@strawberry.type
class Query:
    _hi: str = strawberry.field(resolver=lambda: "Hello World!")


schema = strawberry.federation.Schema(
    query=Query, types=[Product, Review], enable_federation_2=True
)
