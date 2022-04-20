plugins {
  id("org.springframework.boot") version "2.6.6"
  id("io.spring.dependency-management") version "1.0.11.RELEASE"
  id("org.jetbrains.kotlin.jvm") version "1.6.21"
  id("org.jetbrains.kotlin.plugin.spring") version "1.6.21"
}


repositories {
  mavenCentral()
}

dependencies {
  implementation("com.graphql-java:graphql-java:17.3")
  implementation("com.graphql-java:graphql-java-spring-boot-starter-webmvc:2.0")
  implementation("org.springframework.boot:spring-boot-starter-web")
  implementation("com.apollographql.federation:federation-graphql-java-support:2.0.0-alpha.5")
  implementation("org.jetbrains.kotlin:kotlin-reflect")
  implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
  testImplementation("org.springframework.boot:spring-boot-starter-test")
}
