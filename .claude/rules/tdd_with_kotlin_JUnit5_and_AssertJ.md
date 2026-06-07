# Test-Driven Development (TDD) with Kotlin, JUnit5, and AssertJ

## Overview

This guide covers implementing Test-Driven Development (TDD) using **Kotlin** as the programming language, **JUnit5** (Jupiter) as the testing framework, and **AssertJ** for fluent assertions.

## Tech Stack

### Core Dependencies

| Tool | Version | Purpose |
|------|---------|---------|
| **Kotlin** | 1.9.23 | Modern JVM language with concise syntax |
| **JUnit5 (Jupiter)** | 5.10.0 | Modern testing framework for the JVM |
| **AssertJ** | 3.24.1 | Fluent assertions library for Java/Kotlin |
| **Maven** | 3.x+ | Build automation and dependency management |
| **Java** | 21+ | JDK version for compilation |

### Maven Dependencies

```xml
<properties>
    <kotlin.version>1.9.23</kotlin.version>
    <maven.compiler.source>21</maven.compiler.source>
    <maven.compiler.target>21</maven.compiler.target>
</properties>

<dependencies>
    <!-- Kotlin Standard Library -->
    <dependency>
        <groupId>org.jetbrains.kotlin</groupId>
        <artifactId>kotlin-stdlib-jdk8</artifactId>
        <version>${kotlin.version}</version>
    </dependency>

    <!-- JUnit5 API -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter-api</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>

    <!-- JUnit5 Engine -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter-engine</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>

    <!-- AssertJ -->
    <dependency>
        <groupId>org.assertj</groupId>
        <artifactId>assertj-core</artifactId>
        <version>3.24.1</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Project Structure

```
src/
├── main/
│   └── kotlin/
│       └── com/example/
│           ├── Main.kt
│           ├── Counter.kt
│           └── [Your business logic classes]
└── test/
    └── kotlin/
        └── com/example/
            ├── CounterTest.kt
            └── [Your test classes]
```

## TDD Workflow

### 1. Red Phase (Write Failing Test)
```kotlin
@Test
@DisplayName("should increment counter by one")
fun testIncrementCounter() {
    val counter = Counter()
    counter.increment()
    
    assertThat(counter.getCount())
        .isEqualTo(1)
}
```

### 2. Green Phase (Write Minimal Code)
```kotlin
class Counter {
    private var count = 0

    fun increment() {
        count++
    }

    fun getCount(): Int = count
}
```

### 3. Refactor Phase
- Improve code quality
- Optimize performance
- Maintain test coverage

## JUnit5 Annotations

### Test Lifecycle

| Annotation | Purpose |
|-----------|---------|
| `@Test` | Marks a method as a test case |
| `@DisplayName` | Provides readable test descriptions |
| `@BeforeEach` | Runs before each test (setup) |
| `@AfterEach` | Runs after each test (teardown) |
| `@BeforeAll` | Runs once before all tests |
| `@AfterAll` | Runs once after all tests |

### Example Test Setup

```kotlin
@DisplayName("Counter Tests")
class CounterTest {

    private lateinit var counter: Counter

    @BeforeEach
    fun setUp() {
        counter = Counter()
    }

    @Test
    @DisplayName("should initialize counter with zero")
    fun testInitializeCounterWithZero() {
        assertThat(counter.getCount()).isEqualTo(0)
    }
}
```

## AssertJ Assertions

### Common Assertions

#### Equality
```kotlin
assertThat(actualValue).isEqualTo(expectedValue)
assertThat(actualValue).isNotEqualTo(invalidValue)
```

#### Null Checks
```kotlin
assertThat(value).isNull()
assertThat(value).isNotNull()
```

#### Comparisons
```kotlin
assertThat(actualValue).isGreaterThan(5)
assertThat(actualValue).isLessThan(10)
assertThat(actualValue).isBetween(5, 10)
```

#### Collections
```kotlin
assertThat(list).isNotEmpty()
assertThat(list).hasSize(3)
assertThat(list).contains("element1", "element2")
assertThat(list).doesNotContain("element3")
```

#### Strings
```kotlin
assertThat(text).isNotBlank()
assertThat(text).startsWith("Hello")
assertThat(text).endsWith("World")
assertThat(text).contains("substring")
```

#### Custom Conditions
```kotlin
assertThat(value)
    .isPositive()
    .isOdd()
    .isLessThan(100)
```

## Example Test Class

```kotlin
package com.example

import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.assertj.core.api.Assertions.assertThat

@DisplayName("Counter Tests")
class CounterTest {

    private lateinit var counter: Counter

    @BeforeEach
    fun setUp() {
        counter = Counter()
    }

    @Test
    @DisplayName("should initialize counter with zero")
    fun testInitializeCounterWithZero() {
        assertThat(counter.getCount())
            .isEqualTo(0)
    }

    @Test
    @DisplayName("should increment counter by one")
    fun testIncrementCounter() {
        counter.increment()
        
        assertThat(counter.getCount())
            .isEqualTo(1)
    }

    @Test
    @DisplayName("should increment counter multiple times")
    fun testIncrementCounterMultipleTimes() {
        counter.increment()
        counter.increment()
        counter.increment()

        assertThat(counter.getCount())
            .isEqualTo(3)
    }

    @Test
    @DisplayName("should reset counter to zero")
    fun testResetCounter() {
        counter.increment()
        counter.increment()
        counter.reset()

        assertThat(counter.getCount())
            .isEqualTo(0)
    }
}
```

## Maven Build Configuration

### Compile Kotlin Sources

```xml
<build>
    <plugins>
        <!-- Kotlin Maven Plugin -->
        <plugin>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-maven-plugin</artifactId>
            <version>${kotlin.version}</version>
            <executions>
                <execution>
                    <id>compile</id>
                    <phase>compile</phase>
                    <goals>
                        <goal>compile</goal>
                    </goals>
                </execution>
                <execution>
                    <id>test-compile</id>
                    <phase>test-compile</phase>
                    <goals>
                        <goal>test-compile</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>

        <!-- Maven Surefire Plugin for JUnit5 -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>3.1.2</version>
        </plugin>
    </plugins>

    <sourceDirectory>${project.basedir}/src/main/kotlin</sourceDirectory>
    <testSourceDirectory>${project.basedir}/src/test/kotlin</testSourceDirectory>
</build>
```

## Running Tests

### Via Maven
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=CounterTest

# Run specific test method
mvn test -Dtest=CounterTest#testIncrementCounter

# Skip tests during build
mvn clean package -DskipTests
```

### In IDE
- **IntelliJ IDEA**: Right-click test file → "Run" or "Run with Coverage"
- **Visual Studio Code**: Use Test Explorer or Kotlin extension

## Best Practices

### 1. Test Naming
- Use descriptive names following pattern: `test<Feature>`
- Use `@DisplayName` for human-readable descriptions
```kotlin
@DisplayName("should increment counter when increment() is called")
fun testIncrementCounter() { }
```

### 2. Arrange-Act-Assert Pattern
```kotlin
@Test
fun testExample() {
    // Arrange - setup test data
    val input = "Hello"
    
    // Act - execute the code under test
    val result = transform(input)
    
    // Assert - verify the result
    assertThat(result).isEqualTo("HELLO")
}
```

### 3. One Assertion Focus
- Each test should focus on one behavior
- Use multiple assertions in Kotlin DSL when testing related properties

```kotlin
@Test
fun testUserCreation() {
    val user = User("John", 30)
    
    assertThat(user)
        .hasFieldOrPropertyWithValue("name", "John")
        .hasFieldOrPropertyWithValue("age", 30)
}
```

### 4. DRY Principle
- Use `@BeforeEach` for common setup
- Create test fixtures and builders

```kotlin
@BeforeEach
fun setUp() {
    counter = Counter()
}
```

### 5. Test Organization
- Group related tests in nested classes (JUnit5)
```kotlin
@DisplayName("Counter")
class CounterTest {
    
    @Nested
    @DisplayName("Increment functionality")
    inner class IncrementTests {
        @Test
        fun shouldIncrementByOne() { }
    }
    
    @Nested
    @DisplayName("Reset functionality")
    inner class ResetTests {
        @Test
        fun shouldResetToZero() { }
    }
}
```

## AssertJ Custom Matchers

### Creating Custom Assertions
```kotlin
fun assertThatCounter(counter: Counter) = CounterAssert(counter)

class CounterAssert(private val counter: Counter) : AbstractAssert<CounterAssert, Counter>(counter, CounterAssert::class.java) {
    
    fun isAtZero(): CounterAssert {
        assertThat(actual.getCount()).isEqualTo(0)
        return this
    }
    
    fun isGreaterThan(expected: Int): CounterAssert {
        assertThat(actual.getCount()).isGreaterThan(expected)
        return this
    }
}
```

## Debugging Tests

### Enable Debug Logging
```kotlin
// Add dependency on slf4j and logback for logging
import org.slf4j.LoggerFactory

private val logger = LoggerFactory.getLogger(this::class.java)

@Test
fun testWithLogging() {
    logger.info("Test started")
    assertThat(value).isEqualTo(expected)
    logger.info("Test passed")
}
```

### IDE Debugging
- Set breakpoints in test code
- Right-click test → "Debug 'TestName'"
- Step through execution

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Tests not found | Ensure class ends with `Test` and methods are annotated with `@Test` |
| Import errors | Add JUnit5 and AssertJ dependencies |
| Kotlin compilation errors | Check `sourceDirectory` and `testSourceDirectory` in pom.xml |
| AssertJ methods not autocompleting | Ensure proper import: `import org.assertj.core.api.Assertions.assertThat` |

## Additional Resources

- [JUnit5 Official Documentation](https://junit.org/junit5/)
- [AssertJ User Guide](https://assertj.org/)
- [Kotlin Official Documentation](https://kotlinlang.org/docs/)
- [Test Driven Development Best Practices](https://refactoring.guru/refactoring/techniques/introducing-test-driven-development)

## Summary

TDD with Kotlin, JUnit5, and AssertJ provides:

✅ **Modern Language**: Kotlin's concise syntax for cleaner code
✅ **Robust Testing**: JUnit5's powerful features and extensibility
✅ **Expressive Assertions**: AssertJ's fluent API for readable test code
✅ **Maven Integration**: Easy dependency management and CI/CD integration
✅ **Type Safety**: Null safety and strong typing prevent common errors

This tech stack is ideal for building maintainable, well-tested applications on the JVM.

