plugins {
  id("org.springframework.boot") version "3.5.3"
  id("org.jetbrains.kotlin.jvm") version "1.9.25"
  id("org.jetbrains.kotlin.plugin.spring") version "1.9.25"
}


repositories {
  mavenCentral()
}

java.sourceCompatibility = JavaVersion.VERSION_17

dependencies {
  implementation(platform("org.springframework.boot:spring-boot-dependencies:3.5.3"))
  implementation("com.apollographql.federation:federation-graphql-java-support:4.5.0")
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