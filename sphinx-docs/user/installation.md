# Installation

## Requirements

| Tool | Version |
|------|---------|
| ReScript (`rescript`) | `^12.0.0-0` (12.x, prereleases allowed) |
| `@rescript/runtime` | `^12.0.0-0` (same major as ReScript) |
| Vitest | `^4.0.0` |
| Vite | `^6` or `^7` (Vitest 4 peer) |

`rescript`, `@rescript/runtime` and `vitest` are peer dependencies — install
them alongside the bindings.

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

