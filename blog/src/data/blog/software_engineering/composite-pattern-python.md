---
author: Tom Hepworth
pubDatetime: 2025-02-05T10:00:00Z
modDatetime: 2025-12-23T10:00:00Z
title: "The Composite Pattern in Python: Trees Made Simple"
slug: composite-pattern-python
postCategory: software_engineering
featured: false
draft: false
tags:
  - deep-dive
  - python
  - design-patterns
description: Building hierarchical structures where individual objects and compositions are treated uniformly, with a file system example.
---

The Composite pattern is a structural design pattern that lets you compose objects into tree structures and treat individual objects and compositions uniformly. It's particularly useful for representing hierarchies like file systems, organisation charts, or UI component trees.

## The Core Idea

The Composite pattern has three key participants:

1. **Component**: The common interface for all objects (both simple and composite)
2. **Leaf**: A simple object with no children (e.g., a file)
3. **Composite**: An object that can contain other components (e.g., a directory)

The magic is that both leaves and composites implement the same interface, so client code doesn't need to know whether it's working with a single object or a group of objects.

## A Simple File System

Let's start with a minimal implementation:

```python
from abc import ABC, abstractmethod


class FileSystemItem(ABC):
    """Component: Base interface for files and directories."""

    @property
    @abstractmethod
    def size(self) -> int:
        """Returns the size of the item in bytes."""
        pass

    @abstractmethod
    def display(self, indent: int = 0) -> None:
        """Displays the item structure."""
        pass


class File(FileSystemItem):
    """Leaf: Represents a single file."""

    def __init__(self, name: str, size: int):
        self.name = name
        self._size = size

    @property
    def size(self) -> int:
        return self._size

    def display(self, indent: int = 0) -> None:
        print(" " * indent + f"File: {self.name} ({self.size} bytes)")


class Directory(FileSystemItem):
    """Composite: Contains files and other directories."""

    def __init__(self, name: str):
        self.name = name
        self.contents: list[FileSystemItem] = []

    def add(self, item: FileSystemItem) -> None:
        self.contents.append(item)

    def remove(self, item: FileSystemItem) -> None:
        self.contents.remove(item)

    @property
    def size(self) -> int:
        # Recursively sum the size of all contents
        return sum(item.size for item in self.contents)

    def display(self, indent: int = 0) -> None:
        print(" " * indent + f"Directory: {self.name}")
        for item in self.contents:
            item.display(indent + 2)
```

### Usage

```python
# Create files
file1 = File("document.txt", 500)
file2 = File("image.png", 1200)
file3 = File("notes.md", 300)

# Create directory structure
root = Directory("root")
documents = Directory("documents")

documents.add(file1)
documents.add(file3)
root.add(documents)
root.add(file2)

# Display and calculate size uniformly
root.display()
print(f"\nTotal size: {root.size} bytes")
```

**Output:**
```
Directory: root
  Directory: documents
    File: document.txt (500 bytes)
    File: notes.md (300 bytes)
  File: image.png (1200 bytes)

Total size: 2000 bytes
```

Notice how `root.size` automatically calculates the total by recursively summing all nested files. The client code doesn't need to know anything about the internal structure.

## A Feature-Rich Implementation

For a more realistic example, let's add parent tracking, depth calculation, and a pretty tree display:

```python
from __future__ import annotations
from abc import ABC, abstractmethod
from typing import List, Optional

# Tree-drawing characters
BRANCH = "│   "
SPACE = "    "
TEE = "├── "
LAST = "└── "


class DirectoryTreeItem(ABC):
    """Enhanced component with parent tracking and visual display."""

    @property
    @abstractmethod
    def name(self) -> str:
        pass

    @property
    @abstractmethod
    def parent(self) -> Optional[DirectoryTreeItem]:
        pass

    @parent.setter
    @abstractmethod
    def parent(self, p: DirectoryTreeItem):
        pass

    @property
    @abstractmethod
    def emoji(self) -> str:
        pass

    @property
    @abstractmethod
    def size(self) -> int:
        pass

    @abstractmethod
    def display(self, prefix: str = "", is_last: bool = True) -> None:
        pass

    @property
    def depth(self) -> int:
        """Calculate depth by traversing up to root."""
        if self._parent:
            return self._parent.depth + 1
        return 0


class File(DirectoryTreeItem):
    """Leaf with emoji support and parent tracking."""

    def __init__(self, name: str, size: int):
        self._name = name
        self._size = size
        self._parent: Optional[DirectoryTreeItem] = None

    @property
    def name(self) -> str:
        return self._name

    @property
    def parent(self) -> Optional[DirectoryTreeItem]:
        return self._parent

    @parent.setter
    def parent(self, p: DirectoryTreeItem):
        self._parent = p

    @property
    def emoji(self) -> str:
        return "📄"

    @property
    def size(self) -> int:
        return self._size

    def display(self, prefix: str = "", is_last: bool = True) -> None:
        connector = LAST if is_last else TEE
        print(f"{prefix}{connector}{self.emoji} {self.name} ({self.size} bytes)")


class Directory(DirectoryTreeItem):
    """Composite with child management and tree display."""

    def __init__(self, name: str):
        self._name = name
        self._parent: Optional[DirectoryTreeItem] = None
        self._contents: List[DirectoryTreeItem] = []

    @property
    def name(self) -> str:
        return self._name

    @property
    def parent(self) -> Optional[DirectoryTreeItem]:
        return self._parent

    @parent.setter
    def parent(self, p: DirectoryTreeItem):
        self._parent = p

    @property
    def emoji(self) -> str:
        return "📁"

    def add(self, item: DirectoryTreeItem) -> None:
        item.parent = self  # Set parent reference
        self._contents.append(item)

    def remove(self, item: DirectoryTreeItem) -> None:
        self._contents.remove(item)

    @property
    def size(self) -> int:
        return sum(item.size for item in self._contents)

    def display(self, prefix: str = "", is_last: bool = True) -> None:
        connector = LAST if is_last else TEE
        print(f"{prefix}{connector}{self.emoji} {self.name}/")

        # Build prefix for children
        child_prefix = prefix + (SPACE if is_last else BRANCH)

        for i, item in enumerate(self._contents):
            is_item_last = i == len(self._contents) - 1
            item.display(child_prefix, is_item_last)
```

### Pretty Tree Output

```python
root = Directory("project")
root.add(File("README.md", 200))
root.add(File("setup.py", 150))

src = Directory("src")
src.add(File("main.py", 500))
src.add(File("utils.py", 300))

tests = Directory("tests")
tests.add(File("test_main.py", 400))

root.add(src)
root.add(tests)

root.display()
```

**Output:**
```
└── 📁 project/
    ├── 📄 README.md (200 bytes)
    ├── 📄 setup.py (150 bytes)
    ├── 📁 src/
    │   ├── 📄 main.py (500 bytes)
    │   └── 📄 utils.py (300 bytes)
    └── 📁 tests/
        └── 📄 test_main.py (400 bytes)
```

## When to Use Composite

✅ **Good use cases:**
- File systems and directory structures
- GUI component hierarchies (windows containing panels containing buttons)
- Organisation charts
- XML/HTML document structures
- Menu systems with submenus

❌ **When to avoid:**
- Flat collections without hierarchy
- When leaf and composite behaviours differ significantly
- When you need to enforce specific tree structures (e.g., "directories can only contain files")

## Key Benefits

1. **Uniform treatment**: Client code works with both simple and complex elements through the same interface
2. **Easy to add new component types**: Just implement the component interface
3. **Natural recursion**: Operations like `size` naturally cascade through the tree
4. **Simplified client code**: No need for type checking or special cases

## Considerations

- **Type safety**: The common interface means you might call methods that don't make sense (e.g., `add()` on a file)
- **Traversal order**: Consider whether children should be ordered and how
- **Parent references**: Useful for navigation but add complexity

## Common Enhancements

### Iterator Support
Make directories iterable:

```python
class Directory(DirectoryTreeItem):
    def __iter__(self):
        return iter(self._contents)

    def walk(self):
        """Recursively yield all items."""
        for item in self._contents:
            yield item
            if isinstance(item, Directory):
                yield from item.walk()
```

### Visitor Pattern Integration
For operations that vary by type:

```python
class DirectoryTreeItem(ABC):
    @abstractmethod
    def accept(self, visitor: Visitor) -> None:
        pass

class File(DirectoryTreeItem):
    def accept(self, visitor: Visitor) -> None:
        visitor.visit_file(self)

class Directory(DirectoryTreeItem):
    def accept(self, visitor: Visitor) -> None:
        visitor.visit_directory(self)
        for item in self._contents:
            item.accept(visitor)
```

## Further Reading

- [Composite Design Pattern in Python](https://pythonwife.com/composite-design-pattern-with-python/)
- [Refactoring Guru: Composite](https://refactoring.guru/design-patterns/composite/python/example)
- [SB Code: Python Composite](https://sbcode.net/python/composite/)
