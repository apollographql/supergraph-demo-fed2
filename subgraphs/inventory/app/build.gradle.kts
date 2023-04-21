plugins {
  id("org.springframework.boot") version "3.0.6"
  id("org.jetbrains.kotlin.jvm") version "1.8.20"
  id("org.jetbrains.kotlin.plugin.spring") version "1.8.20"
}


repositories {
  mavenCentral()
}

java.sourceCompatibility = JavaVersion.VERSION_17

dependencies {
  implementation(platform("org.springframework.boot:spring-boot-dependencies:3.0.6"))
  implementation("com.apollographql.federation:federation-graphql-java-support:2.3.1")
  implementation("org.jetbrains.kotlin:kotlin-reflect")
  implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
  implementation("org.springframework.boot:spring-boot-starter-graphql")
  implementation("org.springframework.boot:spring-boot-starter-web")
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
  kotlinOptions {
    freeCompilerArgs = listOf("-Xjsr305=strict")
    jvmTarget = "17"
  }
}