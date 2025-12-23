---
title: "Install dependencies at runtime with uv"
pubDatetime: 2025-12-23T17:56:00Z
type: snippet
tags:
  - shell
  - tooling
---

When working with `uv`, it's possible to automatically install dependencies at runtime if they are not already present in the environment by injecting a docstring at the top of your script.

For example, if you run the following script with `uv`, you should automatically install `duckdb` and process a simple query:

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