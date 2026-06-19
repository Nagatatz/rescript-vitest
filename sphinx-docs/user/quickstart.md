# Quick Start

This guide walks you through writing and running your first test.

## Prerequisites

- Completed [Installation](installation.md)

## Write a test

ReScript compiles `*.res` in source to `*.res.js`, and Vitest runs the
compiled output. Create `__tests__/Example_test.res`:

```rescript
open Vitest

describe("math", () => {
  test("adds numbers", () => {
    expect(1 + 1)->toBe(2)
  })

  testAsync("resolves a promise", async () => {
    await expect(Promise.resolve(42))->resolves->Async.toBe(42)
  })
})
```

`open Vitest` brings `describe` / `test` / `expect` and the matchers into scope.
Matchers are *faithful*: they throw on failure, exactly like Vitest itself.

## Use mocks and spies

Mocks, spies and fake timers live in the `Vi` module:

```rescript
open Vitest

test("calls the callback once", () => {
  let cb = Vi.fn1()
  doWork(cb->Vi.MockFn.asFn) // pass the mock where a function is expected
  cb->Vi.MockFn.asAssertion->toHaveBeenCalledOnce
  cb->Vi.MockFn.asAssertion->toHaveBeenCalledWith("expected arg")
})
```

## Run

```bash
pnpm build   # rescript build — compiles .res to .res.js
pnpm test    # vitest run — runs the compiled tests
```

Use `pnpm watch` and `pnpm test:watch` in parallel for a fast feedback loop, or
`pnpm test:coverage` for a coverage report.

## What's Next?

- [Configuration](configuration.md) — Customize settings
- [Changelog](changelog.md) — See what's new
