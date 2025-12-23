---
title: "Install dependencies at runtime with uv"
pubDatetime: 2025-12-23T17:56:00Z
type: snippet
tags:
  - shell
  - tooling
---

When working with `uv`, you can have dependencies installed automatically at runtime (if they’re not already available) by adding a small `script` metadata block at the top of your Python file.

For example, if you run the script below with `uv`, it will install `duckdb` and then execute a simple query:

```python
# /// script
# dependencies = [
#   "duckdb"
# ]
# ///

import duckdb

con = duckdb.connect()

con.sql("SELECT 'Hello, uv with duckdb!' AS greeting").show()
```

Simply save the above snippet as a script locally and then run it with `uv run your_script.py`