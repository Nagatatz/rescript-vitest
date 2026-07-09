# Configuration

`@nagatatz/rescript-vitest` is a thin binding layer with no settings of its own.
Configuration happens in two places: the ReScript compiler and Vitest.

## ReScript (`rescript.json`)

Compile in source to ESM so Vitest can run the output directly, and list the
package as a dependency so the bindings are compiled:

```json
{
  "sources": [
    { "dir": "src", "subdirs": true },
    { "dir": "__tests__", "type": "dev", "subdirs": true }
  ],
  "package-specs": [
    { "module": "esmodule", "in-source": true }
  ],
  "suffix": ".res.js",
  "dependencies": ["@nagatatz/rescript-vitest"]
}
```

| Key | Recommended | Why |
|-----|-------------|-----|
| `package-specs.module` | `esmodule` | Vitest runs on ESM |
| `package-specs.in-source` | `true` | Emit `.res.js` next to sources for Vitest to pick up |
| `suffix` | `.res.js` | Distinguishes compiled output; add it to `.gitignore` |
| `__tests__` source `type` | `dev` | Tests are not published with the package |

## Vitest (`vitest.config.js`)

Point Vitest at the compiled test files:

```js
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['__tests__/**/*_test.res.js'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.res.js'],
    },
  },
})
```

| Key | Recommended | Why |
|-----|-------------|-----|
| `test.include` | `__tests__/**/*_test.res.js` | Run only compiled ReScript tests |
| `coverage.include` | `src/**/*.res.js` | Measure coverage on compiled sources |

## Authoring the config in ReScript (`VitestConfig`)

The Vitest config above can also be written in ReScript with the `VitestConfig`
bindings (`vitest/config`). The scope is intentionally minimal: `defineConfig`,
`defineConfigFn` (function form), `mergeConfig`, `defineProject` and the common
`test` fields are typed, while Vite-level options (`plugins`, `resolve`, …) and
the long tail of `test` options are left to a plain JS config file. Config
objects are write-once data with a large, churning surface, so full coverage is
not worth the maintenance cost.

```rescript
// MyConfig.res
let config = VitestConfig.defineConfig({
  test: {
    include_: ["__tests__/**/*_test.res.js"],
    coverage: {provider: #v8, include_: ["src/**/*.res.js"]},
  },
})
```

```{note}
`coverage.provider` is a polymorphic variant (`#istanbul` / `#v8` / `#custom`),
so an invalid engine name is a compile error. `pool` and `environment` stay
plain `string` because Vitest treats them as extensible unions — custom pools
and environment packages remain expressible.
```

ReScript does not emit `export default`, so re-export the value through a thin JS
shim that Vitest can load:

```js
// vitest.config.js
import { config } from "./MyConfig.res.js"
export default config
```

```{note}
`include` is a ReScript keyword, so the field is named `include_` and maps to JS
`"include"` at runtime.
```

## Fake timers

Fake-timer behaviour (used by `Vi.useFakeTimers`) is Vitest's own configuration;
see the [Vitest fake timers guide](https://vitest.dev/guide/mocking.html#timers).
To install fake timers with explicit options (`FakeTimerInstallOpts` — `now`,
`toFake`, `shouldAdvanceTime`, …), use `Vi.useFakeTimersWith({now: 0.0, …})`.
