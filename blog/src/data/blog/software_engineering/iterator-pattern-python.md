---
author: Tom Hepworth
pubDatetime: 2024-10-31T10:00:00Z
modDatetime: 2025-12-23T10:00:00Z
title: "The Iterator Pattern in Python: Beyond Basic Loops"
slug: iterator-pattern-python
postCategory: software_engineering
featured: false
draft: false
tags:
  - deep-dive
  - python
  - design-patterns
  - data-engineering
description: Understanding Python's iterator protocol and how to build custom iterators for efficient data processing.
---

The Iterator pattern provides a way to access elements of a collection sequentially without exposing its underlying structure. Python has this pattern baked into the language itself. Every time you use a `for` loop, you're using iterators. But understanding how to build custom iterators unlocks powerful patterns for memory-efficient data processing.

## Python's Iterator Protocol

At its core, Python's iterator protocol requires two methods:

- `__iter__()`: Returns the iterator object itself
- `__next__()`: Returns the next value, or raises `StopIteration` when exhausted

Any object implementing these methods can be used in a `for` loop, with `list()`, or anywhere an iterable is expected.

## Example 1: A Custom Linked List

Let's implement a linked list with proper iterator support:

```python
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None


class LinkedList:
    def __init__(self):
        self.head = None

    def append(self, data):
        """Add a node to the end of the list."""
        new_node = Node(data)
        if not self.head:
            self.head = new_node
        else:
            current = self.head
            while current.next:
                current = current.next
            current.next = new_node

    def __iter__(self):
        """Return an iterator for the linked list."""
        return LinkedListIterator(self.head)


class LinkedListIterator:
    """Separate iterator class to allow multiple simultaneous iterations."""

    def __init__(self, start_node):
        self.current = start_node

    def __iter__(self):
        return self

    def __next__(self):
        if self.current is None:
            raise StopIteration
        data = self.current.data
        self.current = self.current.next
        return data
```

### Usage

```python
linked_list = LinkedList()
linked_list.append(1)
linked_list.append(2)
linked_list.append(3)

for value in linked_list:
    print(value)  # 1, 2, 3

# Can also use with list(), sum(), etc.
print(list(linked_list))  # [1, 2, 3]
```

The key insight here is that `LinkedListIterator` is a **separate class**. This allows multiple iterations over the same list simultaneously, which is important for nested loops or concurrent access.

## Example 2: A Chunked CSV Reader

Here's a more practical example: reading large CSV files in chunks to avoid loading everything into memory.

```python
import csv
from typing import Optional


class CsvReader:
    """
    A CSV reader that supports chunked iteration for memory-efficient
    processing of large files.
    """

    def __init__(
        self,
        file_path: str,
        chunk_size: Optional[int] = None,
        skip_rows: int = 0
    ):
        self.file_path = file_path
        self.chunk_size = chunk_size
        self.skip_rows = skip_rows

    def __enter__(self):
        self.file = open(self.file_path, "r")
        self.reader = csv.reader(self.file)
        self.headers = next(self.reader, None)  # Store headers

        # Skip requested rows
        for _ in range(self.skip_rows):
            next(self.reader, None)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.file.close()

    def __iter__(self):
        if self.chunk_size is not None:
            return self  # Iterate in chunks
        else:
            return iter(self.read_all())  # Return all at once

    def __next__(self):
        """Return the next chunk of rows."""
        if self.chunk_size is None:
            raise ValueError("Use read_all() when chunk_size is None")

        chunk = []
        try:
            for _ in range(self.chunk_size):
                chunk.append(next(self.reader))
        except StopIteration:
            if chunk:
                return chunk  # Return remaining rows
            raise
        return chunk

    def read_all(self):
        """Read entire CSV as a list (only when not chunking)."""
        if self.chunk_size is not None:
            raise ValueError("Cannot use read_all with chunk_size set")
        return list(self.reader)
```

### Usage

```python
# Process a large file in 5000-row chunks
with CsvReader("large_data.csv", chunk_size=5000) as reader:
    for chunk in reader:
        print(f"Processing {len(chunk)} rows...")
        # Process chunk without loading entire file

# Skip to near the end of a file
with CsvReader("large_data.csv", chunk_size=1000, skip_rows=9500) as reader:
    for chunk in reader:
        print(f"Found {len(chunk)} rows")

# Read entire small file at once
with CsvReader("small_data.csv") as reader:
    all_data = reader.read_all()
    print(f"Total rows: {len(all_data)}")
```

This pattern is essential for data engineering work where files can be gigabytes in size. By iterating in chunks, you maintain constant memory usage regardless of file size.

## Why Use Custom Iterators?

### Memory Efficiency
Instead of loading everything into memory, iterators process one element (or chunk) at a time:

```python
# Bad: Loads entire file into memory
data = open("huge_file.txt").readlines()
for line in data:
    process(line)

# Good: Processes line by line
with open("huge_file.txt") as f:
    for line in f:  # File objects are iterators!
        process(line)
```

### Lazy Evaluation
Iterators only compute values when requested:

```python
# This doesn't compute anything yet
squares = (x**2 for x in range(1_000_000))

# Only computes when we iterate
for square in squares:
    if square > 100:
        break  # Stops early, didn't compute all million squares
```

### Separation of Concerns
The collection doesn't need to know *how* it will be traversed:

```python
class Database:
    def __iter__(self):
        return DatabaseIterator(self.connection)

class DatabaseIterator:
    def __next__(self):
        # Handles pagination, connection management, etc.
        pass
```

## Iterator vs Iterable

A common source of confusion:

- **Iterable**: Has `__iter__()` that returns an iterator (e.g., `list`, `dict`)
- **Iterator**: Has both `__iter__()` and `__next__()` (e.g., file objects, generators)

```python
my_list = [1, 2, 3]           # Iterable
my_iter = iter(my_list)       # Iterator

next(my_iter)  # 1
next(my_iter)  # 2
```

## Generators: The Easy Way

For simple cases, Python's generators provide iterator functionality with minimal code:

```python
def chunked_reader(file_path, chunk_size):
    """Generator function that yields chunks of lines."""
    with open(file_path) as f:
        chunk = []
        for line in f:
            chunk.append(line)
            if len(chunk) >= chunk_size:
                yield chunk
                chunk = []
        if chunk:
            yield chunk


# Usage is identical to a class-based iterator
for chunk in chunked_reader("data.txt", 100):
    process(chunk)
```

Generators are often the right choice for simple iteration patterns. Use class-based iterators when you need:
- Multiple independent iterations
- Complex state management
- Methods beyond just iteration

## Further Reading

- [Software Patterns Lexicon: Iterator in Python](https://softwarepatternslexicon.com/patterns-python/behavioral/iterator)
- [Refactoring Guru: Iterator Pattern](https://refactoring.guru/design-patterns/iterator)
- [Python Patterns Guide: The Iterator Pattern](https://python-patterns.guide/gang-of-four/iterator/)
