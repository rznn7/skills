---
name: td-red
description: Writes the next failing test based on provided design doc and existing todo tests, then confirms it fails for the right reason (red) via the project's configured test runner before disabling it again.
---

# Context

- designDocPath: $ARGUMENTS[0]
- testFilePath: $ARGUMENTS[1]

# Task

Based on the design doc at ${designDocPath} (if present), implement the body of the next todo test in ${testFilePath}, confirm it is RED for the right reason, then leave it disabled (i.e. keep "it.todo").

- Remove the step-by-step comment instructions from the test body and replace them with actual code.
- Remember that you love TDD and you want to write tests first.
- Implement the test only, do not implement the feature.
- Write no comments in the test body — the test code should read clearly on its own. Do not re-add the step descriptions as comments alongside the code.

# Test runner selection (do this FIRST, before writing the test)

Decide how you will run the red-check in THIS project, and remember the choice:

1. Read `.claude/td-test-runner.json` from the project root.
2. **If it exists and a runner matches `${testFilePath}`**, use that runner as-is. Do not re-ask.
3. **If it is missing, invalid, or no runner matches the spec**, ask the user with `AskUserQuestion` how they want THIS spec's tests run, then write their answer into `.claude/td-test-runner.json` — **add a runner, don't clobber existing ones** — so future runs skip the question. Offer at least:
   - **Wallaby (MCP)** — per-test programmatic verification via the Wallaby MCP server.
   - **Shell command** — a command you run with `Bash` and whose output you read. Ask the user for the exact command; prefer a single-run (non-watch), headless invocation that exits on completion and reports per-test pass/fail. Let them scope it to one spec file.

Config schema — an array of runners, each selected by matching its `match` against the spec path. A monorepo with several test stacks (e.g. backend e2e + frontend `ng test`) keeps one entry per stack:

```json
{
  "runners": [
    {
      "match": "<substring or glob tested against the spec path; first match wins; omit or \"*\" = catch-all>",
      "mechanism": "wallaby | command",
      "command": "<shell command, only for mechanism=command; may contain {spec}>"
    }
  ]
}
```

Select the runner whose `match` matches `${testFilePath}` (first match wins; a runner with no `match` or `"*"` is the catch-all — order it last). **Backward compatibility**: a legacy flat object with a top-level `mechanism`/`command` and no `runners` array is treated as a single catch-all runner.

For `mechanism: "command"`, substitute `{spec}` with a unique substring of the spec filename (without extension) so it maps to the runner's file filter (e.g. an `--include` glob). Run the command from the directory the config implies.

# Verify it's RED (then disable again)

After writing the test body:

1. **Temporarily enable** the test so the runner executes it (`it.todo(...)` → `it(...)`, or `xit(...)` → `it(...)`).
2. **Run it** through the configured runner (above) and read the result. If the runner is a shell command, beware stale state: confirm the run you read reflects your latest edit.
3. **Confirm it's a GOOD red** — the test must fail because the feature is missing (an assertion failure, or the implementation's deliberate `🚧 work in progress` throw / not-yet-implemented path). It must NOT fail for the wrong reason:
   - A compile/type error, `ReferenceError`, bad import, or typo **in the test itself** is a BAD red — fix the test until it fails on the behavior, not on its own mistakes.
   - A test that unexpectedly PASSES means it doesn't actually pin the new behavior (or the feature already exists) — strengthen the assertions until it fails.
4. **Revert to disabled** — once you've confirmed the good red, flip it back to its disabled form (`it(...)` → `it.todo(...)` / `xit(...)`) so td-green can activate it later, one at a time.

Do not implement the feature to make it pass. Your job ends at a confirmed, disabled red test.

## Example

### Before

```ts
it.todo("compute sum", () => {
  // Inject calculator
  // Call calculator.sum(1, 2)
  // Assert that the result is 3
});
```

### After

```ts
it.todo("compute sum", () => {
  const calculator = t.inject(Calculator);
  const result = calculator.sum(1, 2);
  expect(result).toBe(3);
});
```
