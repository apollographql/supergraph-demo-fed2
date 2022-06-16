package inventory

import com.apollographql.federation.graphqljava.Federation
import com.apollographql.federation.graphqljava.tracing.FederatedTracingInstrumentation
import graphql.GraphQL
import graphql.schema.idl.RuntimeWiring
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.stereotype.Component
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.EnableWebMvc
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@SpringBootApplication
class Application

fun main(args: Array<String>) {
  runApplication<Application>(*args)
}

@Component
class GraphQLProvider {

  @Bean
  fun graphQL(): GraphQL {
    val runtimeWiring = RuntimeWiring.newRuntimeWiring()
      .type("ProductItf") { builder ->
        builder.typeResolver { environment ->
          environment.schema.getObjectType("Product")
        }
      }
      .build()
    val schema = Federation.transform(
      javaClass.getResource("/inventory.graphql")!!.readText(),
      runtimeWiring
    )
      .fetchEntities { environment ->
        environment.getArgument<List<Map<String, Any>>>("representations").map { representation ->
          when(representation["__typename"]) {
            "Product" -> allProducts.firstOrNull { it.id == representation["id"] } ?: error("Product not found: $representation")
            else -> error("Unknown type: $representation")
          }
        }
      }.resolveEntityType { environment ->
        when(environment.getObject<Any>()) {
          is Product ->  environment.schema.getObjectType("Product");
          else -> null
        }
      }
      .build()
    return GraphQL.newGraphQL(schema)
      .instrumentation(FederatedTracingInstrumentation())
      .build()
  }
}

class Product(val id: String, val delivery: Delivery)
class Delivery(val estimatedDelivery: String, val fastestDelivery: String)

private val allProducts = listOf(
  Product("apollo-federation", Delivery("6/25/2021", "6/24/2021")),
  Product("apollo-studio", Delivery("6/25/2021", "6/24/2021")),
)

/**
 * Enable CORS for all origins for Sandbox
 */
@Configuration
@EnableWebMvc
class WebConfig : WebMvcConfigurer {
  override fun addCorsMappings(registry: CorsRegistry) {
    registry.addMapping("/**")
  }
}
