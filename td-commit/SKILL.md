---
name: td-commit
description: Commits the work just produced by any td-* skill. Use after td-green, td-scaffold, td-design, or td-review-design once you've reviewed the changes.
---

Look at the conversation to determine what was just done, then run:

```
git add -A && git commit --no-verify -m "<message>"
```

## Message format by phase

| What just ran | Commit message |
|---|---|
| `td-green` | `WIP: <exact test description that just turned green>` |
| `td-scaffold` | `WIP: scaffold — <feature name from design doc>` |
| `td-design` | `WIP: design — <feature name>` |
| `td-review-design` | `WIP: review design — <feature name>` |
| `td-red` | `WIP: test — <test description just written>` |

Infer the feature/test name from the recent conversation. If ambiguous, use the design doc title or the last test description mentioned.

If the user made manual adjustments after the skill ran (visible in the diff), fold them into the same commit — `git add -A` covers them. If the adjustments are substantial enough to deserve a different message, append ` + fixes` to the subject (e.g., `WIP: <test name> + fixes`).

Do not ask for confirmation — just commit.
