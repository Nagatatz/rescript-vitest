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

## Fake timers

Fake-timer behaviour (used by `Vi.useFakeTimers`) is Vitest's own configuration;
see the [Vitest fake timers guide](https://vitest.dev/guide/mocking.html#timers).
