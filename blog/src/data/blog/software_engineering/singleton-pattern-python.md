---
author: Tom Hepworth
pubDatetime: 2024-09-26T10:00:00Z
modDatetime: 2025-12-23T10:00:00Z
title: "The Singleton Pattern in Python: Three Implementations"
slug: singleton-pattern-python
postCategory: software_engineering
featured: false
draft: false
tags:
  - software-engineering
  - deep-dive
  - python
  - design-patterns
description: Exploring three different ways to implement the Singleton pattern in Python, using __new__, decorators, and metaclasses.
---

The Singleton pattern ensures a class has only one instance while providing a global point of access to that instance. In Python, there are several elegant ways to implement this pattern, each with its own trade-offs. Let's explore three approaches: overriding `__new__`, using decorators, and leveraging metaclasses.

## When Do You Need a Singleton?

Singletons are commonly used for:

- **Configuration management**: Ensuring all parts of your application use the same config
- **Database connection pools**: Maintaining a single pool of connections
- **Logging services**: Centralising log output
- **Caching**: Sharing a cache across modules

> ⚠️ **A word of caution**: Singletons can introduce global state and make testing harder. Consider whether dependency injection might be a better fit for your use case.

## Approach 1: Overriding `__new__` with Caching

This approach caches instances based on constructor arguments, allowing for multiple "singleton-like" instances when needed:

```python
import json
from pathlib import Path


class JSONConfig:
    """
    A Singleton class that caches configurations based on file path.
    Same file path = same instance.
    """
    _cached_configs = {}

    def __new__(cls, config_file_path: str):
        if config_file_path not in cls._cached_configs:
            instance = super().__new__(cls)
            config = cls._read_config(config_file_path)
            instance._load_config_values(**config)
            cls._cached_configs[config_file_path] = instance
        return cls._cached_configs[config_file_path]

    @staticmethod
    def _read_config(config_file_path: str):
        file_path = Path(config_file_path)
        if not file_path.exists():
            raise FileNotFoundError(f"Config file not found: {file_path}")
        with file_path.open("r") as f:
            return json.load(f)

    def _load_config_values(self, app_name: str, version: str,
                            debug_mode: bool, max_users: int,
                            maintenance_mode: bool):
        self.app_name = app_name
        self.version = version
        self.debug_mode = debug_mode
        self.max_users = max_users
        self.maintenance_mode = maintenance_mode
```

### Usage

```python
config1 = JSONConfig("configs/config1.json")
config2 = JSONConfig("configs/config2.json")  # Different file = different instance
config1_again = JSONConfig("configs/config1.json")  # Same file = same instance

print(config1 is config1_again)  # True
print(config1 is config2)        # False
```

This approach is particularly useful when you want to cache expensive-to-create objects but still allow for multiple instances based on different parameters.

## Approach 2: The Decorator Pattern

Decorators offer a clean, reusable way to add Singleton behaviour to any class:

```python
def singleton(cls):
    """Decorator to make a class a Singleton."""
    instances = {}

    def get_instance(*args, **kwargs):
        if cls not in instances:
            print(f"Creating a new {cls.__name__} instance")
            instances[cls] = cls(*args, **kwargs)
        else:
            print(f"Returning existing {cls.__name__} instance")
        return instances[cls]

    return get_instance


@singleton
class Config:
    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

    def __repr__(self):
        config_attrs = ", ".join(
            f"{key}: {value}" for key, value in self.__dict__.items()
        )
        return f"{self.__class__.__name__}({config_attrs})"
```

### Usage

```python
app_config = Config(app_name="MyApp", version="1.0", debug=True)
# Output: Creating a new Config instance

another_config = Config(app_name="AnotherApp", version="2.0")
# Output: Returning existing Config instance

print(app_config is another_config)  # True
print(another_config)  # Config(app_name: MyApp, version: 1.0, debug: True)
```

Note that when retrieving an existing instance, the new arguments are **ignored**. The original instance is returned unchanged.

**Pros:**
- Clean, readable syntax with `@singleton`
- Easy to add to existing classes
- Logic is separated from the class itself

**Cons:**
- The decorated class is actually a function, which can confuse some tools
- Type hints may not work correctly

## Approach 3: Metaclass Magic

For the most robust implementation, metaclasses give you complete control over class instantiation:

```python
class ConfigMeta(type):
    """Metaclass that ensures only one instance per class."""
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            print(f"Creating a new instance of {cls.__name__}")
            instance = super().__call__(*args, **kwargs)
            cls._instances[cls] = instance
        else:
            print(f"Returning existing instance of {cls.__name__}")
        return cls._instances[cls]


class Config(metaclass=ConfigMeta):
    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

    def __repr__(self):
        config_attrs = ", ".join(
            f"{key}: {value}" for key, value in self.__dict__.items()
        )
        return f"{self.__class__.__name__}({config_attrs})"
```

### Usage

```python
app_config = Config(app_name="MyApp", version="1.0", debug=True)
# Output: Creating a new instance of Config

another_config = Config(app_name="AnotherApp", version="2.0", debug=False)
# Output: Returning existing instance of Config

print(app_config is another_config)  # True
```

**Pros:**
- The class remains a proper class (not a function)
- Works correctly with inheritance
- Type hints and IDE features work as expected

**Cons:**
- More complex to understand
- May be overkill for simple use cases

## Comparing the Approaches

| Approach | Complexity | Type Hints | Inheritance | Use Case |
|----------|------------|------------|-------------|----------|
| `__new__` override | Low | ✅ | ⚠️ | Caching based on parameters |
| Decorator | Medium | ❌ | ❌ | Quick and reusable |
| Metaclass | High | ✅ | ✅ | Robust, production code |

## The Case Against Singletons

Before reaching for a Singleton, consider these alternatives:

1. **Dependency Injection**: Pass the shared instance explicitly
2. **Module-level variables**: Python modules are themselves singletons
3. **Factory pattern**: Create instances through a controlled factory

Singletons can make testing difficult and introduce hidden dependencies. If you find yourself using many Singletons, it might be a sign that your architecture needs rethinking.

## Further Reading

- [Python for the Lab: Singletons](https://pythonforthelab.com/blog/singletons-instantiate-objects-only-once/)
- [Python Morsels: Making Singletons](https://www.pythonmorsels.com/making-singletons/)
- [Singleton: The Root of All Evil](https://dev.to/mcsee/singleton-the-root-of-all-evil-50bh)
- [Refactoring Guru: Singleton](https://refactoring.guru/design-patterns/singleton)
