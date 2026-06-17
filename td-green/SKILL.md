---
name: td-green
description: Progressively activates todo tests one at a time, updates implementation code until each passes (verified via the project's configured test runner), then moves to the next—following the design doc as the single source of truth.
---

# Context

- designDocPath: $ARGUMENTS[0]
- testFilePath: $ARGUMENTS[1]

# Goal

Using the design doc at `${designDocPath}` as the single source of truth, progressively activate the tests in `${testFilePath}`.

# Test runner selection (do this FIRST, before touching any test)

Decide how you will verify tests in THIS project, and remember the choice:

1. Read `.claude/td-test-runner.json` from the project root.
2. **If it exists and is valid**, use it as-is. Do not re-ask.
3. **If it is missing or invalid**, ask the user with `AskUserQuestion` how they want tests run, then write their answer to `.claude/td-test-runner.json` so future runs skip the question. Offer at least:
   - **Wallaby (MCP)** — per-test programmatic verification via the Wallaby MCP server.
   - **Shell command** — a command you run with `Bash` and whose output you read. Ask the user for the exact command; prefer a single-run (non-watch), headless invocation that exits on completion and reports per-test pass/fail. Let them scope it to one spec file.

Config schema:

```json
{
  "mechanism": "wallaby | command",
  "command": "<shell command, only for mechanism=command; may contain {spec}>"
}
```

For `mechanism: "command"`, substitute `{spec}` with a unique substring of the spec filename (without extension) so it maps to the runner's file filter (e.g. an `--include` glob). Run the command from the directory the config implies.

# Steps

Categorize each test in `${testFilePath}` as:

- Implemented tests: tests that contain actual test code (not just empty or comments)
- Empty tests: tests that are empty or only contain comments - TOTALLY IGNORE THESE

For each implemented test, convert `it.todo(...)` into `it(...)`, but do it strictly one test at a time, then update the implementation just enough for that specific test to turn green — NOTHING MORE.

DO NOT IMPLEMENT ANYTHING THAT IS NOT DIRECTLY RELATED TO THE CURRENT TEST.

Type-safety is not a license to over-implement. When the compiler forces you to handle a case the current test does not exercise (a possibly-`undefined` value, a non-exhaustive switch, an else branch), do NOT write real handling for it — that silently implements a future test. Stand it in with a loud `throw new Error('🚧 work in progress')` instead. The real handling of that case must be driven by its own test later, which will replace the throw.

STOP when these tests are green.

# Rules

DO NOT IMPLEMENT EMPTY TESTS.

NEVER implement tests.

ONLY EDIT TESTS as a last resort after you have tried everything else.

Write no comments in implementation code. The code should be self-explanatory through clear naming. Add a JSDoc block only when it genuinely adds value the signature cannot convey (e.g. a non-obvious contract or caveat), and keep it to one or two lines. Do not narrate steps, restate what the code does, or leave TODO/explanatory comments.

Use the test runner configured in `.claude/td-test-runner.json` (see "Test runner selection") to verify results after each change. Only once the current test passes should you advance to the next one. If that runner is a shell command, beware stale state: confirm the run you read reflects your latest edit.
