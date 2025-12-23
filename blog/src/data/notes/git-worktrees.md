---
title: "TIL: Git worktrees are amazing"
pubDatetime: 2025-12-10T16:00:00Z
type: til
tags:
  - git
  - tooling
---

Finally tried `git worktree` properly today. Instead of stashing or committing half-done work to switch branches, you can just:

```bash
git worktree add ../feature-branch feature-branch
```

Now you have both branches checked out simultaneously in different directories. Perfect for reviewing PRs while in the middle of something else.
