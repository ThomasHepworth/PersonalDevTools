---
author: Tom Hepworth
pubDatetime: 2024-09-05T10:00:00Z
modDatetime: 2025-12-23T10:00:00Z
title: "The Factory Pattern in Python: A Practical Guide"
slug: factory-pattern-python
postCategory: software_engineering
featured: false
draft: false
tags:
  - software-engineering
  - deep-dive
  - python
  - design-patterns
description: Understanding the Factory and Abstract Factory patterns in Python, with practical examples from data engineering.
---

The Factory Pattern is one of the most useful creational design patterns, providing an interface for creating objects without specifying their concrete classes. It's particularly powerful in Python, where we can leverage first-class functions and decorators to create elegant, flexible implementations.

## What is the Factory Pattern?

The Factory Pattern provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created. It's commonly used when:

- A class doesn't know exactly which class of objects it must create
- You want to centralise complex object creation logic
- You need to decouple object creation from usage

### Factory vs Abstract Factory

The **Factory Pattern** creates objects of a single type, while the **Abstract Factory Pattern** creates families of related objects without specifying their concrete classes. Think of it this way:

- **Factory**: "Give me a database connection" → Returns PostgreSQL, MySQL, or SQLite connection
- **Abstract Factory**: "Give me everything I need for PostgreSQL" → Returns PostgreSQL connection, query builder, and schema manager

## Example 1: A Decorator-Based Config Factory

One elegant approach, inspired by [Dagster's patterns](https://dagster.io/blog/python-factory-patterns), uses decorators to register configuration functions:

```python
from typing import Callable, Dict, Any, TypeVar

ConfigFunction = TypeVar("ConfigFunction", bound=Callable[[], Dict[str, Any]])
CONFIGS: Dict[str, ConfigFunction] = {}


def register_config(file_type: str) -> Callable[[ConfigFunction], ConfigFunction]:
    """Decorator to register a configuration function."""
    def decorator(fn: ConfigFunction) -> ConfigFunction:
        CONFIGS[file_type] = fn
        return fn
    return decorator


@register_config("adder")
def _create_adder_config() -> Dict[str, Any]:
    return {"startup": lambda x: x + 1, "teardown": [lambda x: x + 2, lambda x: x + 3]}


@register_config("multiplier")
def _create_multiplier_config() -> Dict[str, Any]:
    return {"startup": lambda x: x * 2, "teardown": [lambda x: x * 3, lambda x: x * 4]}


def get_config(config_name: str) -> Dict[str, Any]:
    """Factory function to retrieve a configuration by name."""
    config_fn = CONFIGS.get(config_name)
    if config_fn is None:
        raise ValueError(f"Config '{config_name}' not found.")
    return config_fn()
```

This approach is particularly useful when you have many configuration types scattered across different modules. The decorator pattern allows each config to "self-register" without needing a central registry that knows about all implementations.

## Example 2: SQL Dialect Factory

A more traditional factory approach, simplified from [Splink's dialect system](https://github.com/moj-analytical-services/splink), demonstrates how to create database-specific SQL generators:

```python
from abc import ABC
from dataclasses import dataclass
from typing import TypeVar

Self = TypeVar("Self", bound="Dialect")


class Dialect(ABC):
    _dialect_name_for_factory: str

    @property
    def name(self) -> str:
        return self._dialect_name_for_factory

    @classmethod
    def from_string(cls: type[Self], dialect_name: str) -> Self:
        """Factory method to create a dialect from a string identifier."""
        classes_from_dialect_name = [
            c for c in cls.__subclasses__()
            if getattr(c, "_dialect_name_for_factory", None) == dialect_name
        ]

        if classes_from_dialect_name:
            return classes_from_dialect_name[0]()

        raise ValueError(f"Could not find dialect '{dialect_name}'.")

    @property
    def jaro_winkler_function_name(self):
        raise NotImplementedError(f"Backend '{self.name}' needs jaro_winkler_function_name")

    @property
    def infinity_expression(self):
        raise NotImplementedError(f"Backend '{self.name}' needs infinity_expression")


class DuckDBDialect(Dialect):
    _dialect_name_for_factory = "duckdb"

    @property
    def jaro_winkler_function_name(self):
        return "jaro_winkler_similarity"

    @property
    def infinity_expression(self):
        return "cast('infinity' as float8)"


class SparkDialect(Dialect):
    _dialect_name_for_factory = "spark"

    @property
    def jaro_winkler_function_name(self):
        return "jaro_winkler"

    @property
    def infinity_expression(self):
        return "cast('infinity' as float8)"
```

### Using the Dialect Factory

The beauty of this pattern is how it enables dependency injection and lazy loading:

```python
@dataclass
class JaroWinklerLevel:
    column_name: str
    distance_threshold: float = 0.9

    def create_sql(self, dialect: Dialect) -> str:
        jw_fn = dialect.jaro_winkler_function_name
        return f"{jw_fn}({self.column_name}_l, {self.column_name}_r) >= {self.distance_threshold}"


# Usage
duckdb = Dialect.from_string("duckdb")
spark = Dialect.from_string("spark")

jaro_winkler = JaroWinklerLevel("first_name", 0.8)
print(jaro_winkler.create_sql(duckdb))
# jaro_winkler_similarity(first_name_l, first_name_r) >= 0.8
print(jaro_winkler.create_sql(spark))
# jaro_winkler(first_name_l, first_name_r) >= 0.8
```

The `JaroWinklerLevel` class has no knowledge of specific dialects. It just knows it needs *a* dialect. This separation of concerns makes the code more testable and extensible.

## When to Use the Factory Pattern

✅ **Good use cases:**
- Creating database connections where the type is determined at runtime
- Building objects from configuration files or environment variables
- Implementing plugin systems where new types can be added without modifying existing code
- Generating SQL or other code for different backends

❌ **When to avoid:**
- Simple object creation with no variation
- When you always know the exact type at compile time
- When the added complexity doesn't provide clear benefits

## Further Reading

- [Dagster's Article on Pythonic Factory Patterns](https://dagster.io/blog/python-factory-patterns)
- [Refactoring Guru: Factory Method](https://refactoring.guru/design-patterns/factory-method)
- [Refactoring Guru: Abstract Factory](https://refactoring.guru/design-patterns/abstract-factory)
- [ArjanCodes: Factory Pattern in Python](https://www.youtube.com/watch?v=s_4ZrtQs8Do)
