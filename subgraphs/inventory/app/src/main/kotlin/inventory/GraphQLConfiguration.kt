package inventory

import com.apollographql.federation.graphqljava.Federation
import com.apollographql.federation.graphqljava.tracing.FederatedTracingInstrumentation
import graphql.TypeResolutionEnvironment
import graphql.schema.DataFetchingEnvironment
import graphql.schema.idl.RuntimeWiring
import graphql.schema.idl.TypeDefinitionRegistry
import inventory.model.Delivery
import inventory.model.Product
import org.springframework.boot.autoconfigure.graphql.GraphQlSourceBuilderCustomizer
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.graphql.execution.GraphQlSource.SchemaResourceBuilder
import org.springframework.graphql.execution.RuntimeWiringConfigurer

@Configuration
class GraphQLConfiguration {

    private val allProducts = listOf(
        Product("converse-1", Delivery("6/25/2023", "6/24/2023")),
        Product("vans-1", Delivery("6/25/2023", "6/24/2023")),
    )

    @Bean
    fun federatedTracingInstrumentation(): FederatedTracingInstrumentation {
        return FederatedTracingInstrumentation()
    }

    @Bean
    fun runtimeWiringConfigurer(): RuntimeWiringConfigurer = RuntimeWiringConfigurer { wiringBuilder ->
        wiringBuilder.type("ProductItf") { builder ->
            builder.typeResolver { environment ->
                environment.schema.getObjectType("Product")
            }
        }
    }

    @Bean
    fun federationTransform(): GraphQlSourceBuilderCustomizer {
        return GraphQlSourceBuilderCustomizer { builder: SchemaResourceBuilder ->
            builder.schemaFactory { registry: TypeDefinitionRegistry?, wiring: RuntimeWiring? ->
                Federation.transform(registry, wiring)
                    .fetchEntities { env: DataFetchingEnvironment ->
                        env.getArgument<List<Map<String, Any>>>("representations").map { representation ->
                            when(representation["__typename"]) {
                                "Product" -> {
                                   val prod = allProducts.firstOrNull { it.id == representation["id"] } ?: error("Product not found: $representation")
				   Thread.sleep(1000)
				   prod
				}
                                else -> error("Unknown type: $representation")
                            }
                        }
                    }
                    .resolveEntityType { env: TypeResolutionEnvironment ->
                        when(env.getObject<Any>()) {
                            is Product ->  env.schema.getObjectType("Product")
                            else -> null
                        }
                    }
                    .build()
            }
        }
    }
}
