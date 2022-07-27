plugins {
  id("org.springframework.boot") version "2.7.2"
  id("io.spring.dependency-management") version "1.0.12.RELEASE"
  id("org.jetbrains.kotlin.jvm") version "1.7.10"
  id("org.jetbrains.kotlin.plugin.spring") version "1.7.10"
}


repositories {
  mavenCentral()
}

dependencies {
  implementation("com.graphql-java:graphql-java:230521-nf-execution")
  implementation("com.graphql-java:graphql-java-spring-boot-starter-webmvc:2.0")
  implementation("org.springframework.boot:spring-boot-starter-web")
  implementation("com.apollographql.federation:federation-graphql-java-support:2.0.3")
  implementation("org.jetbrains.kotlin:kotlin-reflect")
  implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
  testImplementation("org.springframework.boot:spring-boot-starter-test")
}
