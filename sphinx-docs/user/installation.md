# Installation

## Requirements

| Tool | Version |
|------|---------|
| ReScript (`rescript`) | `^12.0.0-0` (12.x, prereleases allowed) |
| `@rescript/runtime` | `^12.0.0-0` (same major as ReScript) |
| Vitest | `^4.0.0 \|\| ^5.0.0` |
| Vite | `^6`, `^7` or `^8` (Vitest 5 needs `>=6.4`) |
| Node.js | Whatever your Vitest major needs (Vitest 5: `^22.12.0`, `^24` or `>=26`) |

`rescript`, `@rescript/runtime` and `vitest` are peer dependencies — install
them alongside the bindings.

## Vitest 5 notes

The bindings work unchanged on Vitest 4 and 5. Two things to know when you
upgrade Vitest itself:

- Vitest 5 removed `describe.sequential` / `test.sequential` / `it.sequential`.
  `describeSequential`, `testSequential`, `testSequentialAsync` and
  `itSequential` keep their names and signatures but now compile to the
  `{concurrent: false}` option (e.g. `describe(name, {concurrent: false}, body)`),
  which both majors support.
- Vitest 5 changes some runtime behavior the bindings pass straight through:
  `clearMocks` defaults to `true`; `Vi.mock` / `Vi.unmock` / `Vi.hoisted` must be
  called at the top level of a file (nested calls throw); `Expect.poll` fails
  when it times out; unawaited `resolves` / `rejects` assertions fail the test;
  and `toThrowWithMessage("")` matches any message. See the
  [Vitest 5 migration guide](https://vitest.dev/guide/migration.html).

## Install

```bash
pnpm add -D @nagatatz/rescript-vitest rescript @rescript/runtime vitest vite
```

Add the package to your `rescript.json` dependencies so ReScript compiles the
bindings:

```json
{
  "dependencies": ["@nagatatz/rescript-vitest"]
}
```

## Verify

After installing, build your ReScript sources and run a test to confirm the
bindings resolve:

```bash
pnpm rescript build   # the bindings compile alongside your code
pnpm vitest run       # runs your compiled *_test.res.js files
```

A minimal smoke test:

```rescript
open Vitest

test("vitest bindings resolve", () => {
  expect(1 + 1)->toBe(2)
})
```

If this compiles and passes, the bindings are installed correctly.

## Troubleshooting

| Symptom | Cause / Fix |
|---------|-------------|
| ReScript can't find the `Vitest` module | Add `"@nagatatz/rescript-vitest"` to `dependencies` in `rescript.json`, then rebuild. |
| `Cannot find package 'vitest'` at test time | Install the peer dependencies: `pnpm add -D vitest vite`. |
| Vitest doesn't pick up your tests | Point your `vitest.config.js` `include` at the compiled output (e.g. `**/*_test.res.js`), not the `.res` sources. |

