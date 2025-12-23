---
author: Tom Hepworth
pubDatetime: 2024-10-17T10:00:00Z
modDatetime: 2025-12-23T10:00:00Z
title: "The Strategy Pattern in Python: Swappable Algorithms Made Simple"
slug: strategy-pattern-python
postCategory: software_engineering
featured: false
draft: false
tags:
  - software-engineering
  - deep-dive
  - python
  - design-patterns
description: How to use the Strategy pattern to make algorithms interchangeable, with practical Python examples for data transformation and file exports.
---

The Strategy pattern is a behavioural design pattern that lets you define a family of algorithms, encapsulate each one, and make them interchangeable. It's one of my favourite patterns because Python's first-class functions make it incredibly elegant to implement.

## Why Strategy?

The Strategy pattern is useful when you need to:

- **Switch algorithms at runtime** without changing the code that uses them
- **Eliminate conditional statements** that select between behaviours
- **Make code more testable** by injecting different strategies
- **Follow the Open/Closed Principle**: add new strategies without modifying existing code

## A Functional Approach: Column Naming Strategies

In Python, we don't always need classes to implement the Strategy pattern. Functions work beautifully:

```python
from typing import Callable, List
import re

# Define a type alias for clarity
TransformStrategy = Callable[[str], str]


def to_snake_case(header: str) -> str:
    """Converts a string to snake_case."""
    header = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", header)
    header = re.sub("([a-z0-9])([A-Z])", r"\1_\2", header)
    return header.lower()


def to_camel_case(header: str) -> str:
    """Converts a string to camelCase."""
    parts = re.split(r"(?<!^)(?=[A-Z])|[ _-]+", header)
    return parts[0].lower() + "".join(word.capitalize() for word in parts[1:] if word)


def to_kebab_case(header: str) -> str:
    """Converts a string to kebab-case."""
    header = re.sub("(.)([A-Z][a-z]+)", r"\1-\2", header)
    header = re.sub("([a-z0-9])([A-Z])", r"\1-\2", header)
    return header.lower().replace(" ", "-")


def rename_headers(headers: List[str], strategy: TransformStrategy) -> List[str]:
    """
    Renames headers using the provided transformation strategy.
    The strategy is injected, making this function flexible and testable.
    """
    return [strategy(header) for header in headers]
```

### Usage

```python
headers = ["FirstName", "LastName", "EmailAddress", "PhoneNumber"]

snake_headers = rename_headers(headers, to_snake_case)
# ['first_name', 'last_name', 'email_address', 'phone_number']

camel_headers = rename_headers(headers, to_camel_case)
# ['firstName', 'lastName', 'emailAddress', 'phoneNumber']

kebab_headers = rename_headers(headers, to_kebab_case)
# ['first-name', 'last-name', 'email-address', 'phone-number']
```

The `rename_headers` function doesn't know *how* the transformation happens. It just knows it receives a function that transforms strings. This is the essence of the Strategy pattern.

## File Export Strategies

Here's another practical example: exporting data in different formats.

```python
from typing import Callable
import pandas as pd

# Strategy type
ExportStrategy = Callable[[pd.DataFrame, str], None]


def export_to_csv(data: pd.DataFrame, filename: str) -> None:
    """Strategy: Export to CSV format."""
    data.to_csv(f"{filename}.csv", index=False)
    print(f"Data exported to {filename}.csv")


def export_to_json(data: pd.DataFrame, filename: str) -> None:
    """Strategy: Export to JSON format."""
    data.to_json(f"{filename}.json", orient="records")
    print(f"Data exported to {filename}.json")


def export_to_parquet(data: pd.DataFrame, filename: str) -> None:
    """Strategy: Export to Parquet format."""
    data.to_parquet(f"{filename}.parquet", index=False)
    print(f"Data exported to {filename}.parquet")


def process_and_export(
    data: pd.DataFrame,
    filename: str,
    export_strategy: ExportStrategy,
) -> None:
    """
    Process data and export using the provided strategy.
    The export format is determined by the injected strategy.
    """
    # ... do some processing ...
    export_strategy(data, filename)
```

### Usage

```python
data = pd.DataFrame({"a": [1, 2, 3], "b": [4, 5, 6]})

process_and_export(data, "output", export_to_csv)
process_and_export(data, "output", export_to_json)
process_and_export(data, "output", export_to_parquet)
```

## Real-World Example: Splink's Database Strategies

[Splink](https://github.com/moj-analytical-services/splink), a data linkage library, uses both the Strategy and Factory patterns effectively:

### Strategy Pattern Usage
Users select a database backend by importing the appropriate API:

```python
from splink import DuckDBAPI, SparkAPI

# DuckDB strategy
linker = Linker(df, settings, db_api=DuckDBAPI())

# Spark strategy
linker = Linker(df, settings, db_api=SparkAPI())
```

The `Linker` class doesn't care which database it's using. It just needs an object that conforms to the expected interface. This allows:

- Easy extension to new databases without changing core code
- Simpler backend code (no conditionals determining the DB engine)
- More readable and maintainable production jobs

### How Strategy Differs from Factory

Both patterns appear in Splink, but they serve different purposes:

| Pattern | Decision Maker | Purpose |
|---------|---------------|---------|
| **Strategy** | User explicitly chooses | "I want to use DuckDB" |
| **Factory** | System determines | "Based on this config, create the right SQL" |

The Strategy pattern gives the user explicit control, while the Factory pattern encapsulates the object creation decision.

## When to Use Strategy

✅ **Good use cases:**
- Multiple algorithms that can be swapped at runtime
- Eliminating complex conditional logic
- Making behaviour configurable
- Improving testability through dependency injection

❌ **When to avoid:**
- Only one algorithm exists (and won't change)
- The overhead of abstraction isn't worth the flexibility
- Strategies are so tightly coupled they'll always change together

## Key Benefits

1. **Eliminates conditionals**: No more `if format == "csv": ... elif format == "json": ...`
2. **Open/Closed Principle**: Add new strategies without modifying existing code
3. **Testability**: Inject mock strategies for testing
4. **Single Responsibility**: Each strategy handles one algorithm

## Considerations

- **Client knowledge**: Users must know which strategies are available
- **Interface consistency**: All strategies must conform to the same interface
- **Increased number of objects**: More strategies = more code to maintain

## Combining with Factory

The Strategy pattern works beautifully with the Factory pattern. Use a factory to *create* strategies based on configuration, then inject them:

```python
def get_export_strategy(format: str) -> ExportStrategy:
    """Factory that returns the appropriate export strategy."""
    strategies = {
        "csv": export_to_csv,
        "json": export_to_json,
        "parquet": export_to_parquet,
    }
    if format not in strategies:
        raise ValueError(f"Unknown format: {format}")
    return strategies[format]


# Usage: Factory creates strategy, which is then used
strategy = get_export_strategy(config["output_format"])
process_and_export(data, "output", strategy)
```

## Further Reading

- [Refactoring Guru: Strategy Pattern](https://refactoring.guru/design-patterns/strategy)
- [ArjanCodes: Strategy Patterns in Python](https://youtu.be/WQ8bNdxREHU)
- [Data Pipeline Design Patterns](https://www.startdataengineering.com/post/code-patterns/)
- [Python Informer: Strategy Pattern](https://www.pythoninformer.com/programming-techniques/design-patterns/strategy/)
