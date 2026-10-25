# Building

## Build Commands

| Command | Description |
|---------|-------------|
| `pnpm build` | Compile `.res` sources to in-source `.res.js` (ESM) via `rescript build` |
| `pnpm clean && pnpm build` | Clean rebuild (removes the previous `lib/` and `.res.js` output) |
| `pnpm test` | Run the dogfood tests with `vitest run` against the compiled `__tests__/**/*_test.res.js` |

## Output

The ReScript compiler emits in-source output: each `src/Foo.res` produces a
sibling `src/Foo.res.js` (ESM). The compiler's intermediate artifacts live under
`lib/`. Both `*.res.js` and `lib/` are build products and are `.gitignore`-d.

## Build Flow

1. `pnpm build` → `rescript build` compiles `src/**/*.res` and `__tests__/**/*.res`
   to in-source `.res.js`.
2. `pnpm test` → `vitest run` executes the compiled `__tests__/**/*_test.res.js`.

Tests run against compiled JavaScript, so a build must precede the test run
(`pnpm test` assumes the latest `pnpm build`).

## CI Pipeline

Continuous integration builds the bindings and runs the dogfood test suite on
every push and pull request, ensuring the bindings stay faithful to the Vitest 4
API. See the workflows under `.github/workflows/`.

## Documentation Checks

The Sphinx site under `sphinx-docs/` has its own quality gates, all run by the
`Docs` workflow on every change to `sphinx-docs/**`:

| Command | Description |
|---------|-------------|
| `make check` | `ruff` lint + format check, `sphinx-lint`, `mypy` and `pytest` |
| `make test` | The `pytest` part alone: every Japanese `.po` entry is well-formed, every prose `msgid` has a Japanese `msgstr`, each source page has a catalogue, and `conf.py` reports the `package.json` version |
| `make check-po` | `pofilter` syntax and placeholder checks on the Japanese `.po` files |
| `make a11y` | Builds the site and runs `pa11y-ci` (WCAG 2 AA) against the pages listed in `.pa11yci.json` |

`make test` fails when an English source changes without its Japanese
translation, so update the catalogues in the same change: `make update-po`,
fill in the new `msgstr` entries under `locale/ja/LC_MESSAGES/`, then
`make build-ja`.
