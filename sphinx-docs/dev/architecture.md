# Architecture

## Overview

`@nagatatz/rescript-vitest` is a thin FFI binding layer — it has no application
runtime of its own. Every binding is a ReScript `external` mapping directly onto
a Vitest 4 export, so calling a binding *is* calling Vitest. There is no wrapper
logic, no state, and no abstraction over the underlying API.

The bindings are *faithful*: matchers behave exactly like their Vitest
counterparts, including their side effects (an assertion throws on failure rather
than returning a result). The type signatures encode the JavaScript contract as
closely as ReScript's type system allows.

## Key Components

| Module | Responsibility |
|--------|----------------|
| `src/Vitest.res` | Test structure (`describe` / `test` / `it` and variants), lifecycle hooks, the full `expect` matcher set, and the `not_` / `resolves` / `rejects` modifiers (with the `Async` matcher module). |
| `src/Vi.res` | The `Vi` namespace: mock functions and spies, module mocking, global/environment stubs, and fake timers. |
| `src/VitestConfig.res` | The `vitest/config` side: `defineConfig` / `defineConfigFn` / `mergeConfig` / `defineProject` and an optional-record type for the main `test` config fields (intentionally a minimal subset). |
| `__tests__/` | Dogfood tests that exercise the bindings on Vitest 4 itself. Every binding change ships with a corresponding test (verification-first). |

## Design Principles

1. **Faithful, not abstracted** — bindings map 1:1 onto Vitest exports and
   preserve their side effects. No convenience wrappers are layered on top.
2. **Type-safe where ReScript allows** — signatures capture argument and return
   shapes; where a JavaScript shape cannot be expressed faithfully (e.g.
   `test.extend` fixtures, `expect.extend` custom matchers), the API is left
   unbound rather than typed unsafely.
3. **Minimal config surface** — `VitestConfig` covers the common `test` fields
   only; full Vite-level configuration belongs in a JavaScript config file.
4. **Verification-first** — the binding layer is validated by dogfooding it
   against Vitest 4; no binding ships without a test that runs it.

## Output Shape

ReScript compiles each `src/*.res` to an in-source ESM `*.res.js` that
re-exports the Vitest symbols under the bound names. Consumers import the
generated `.res.js` (directly or through ReScript's module resolution).
