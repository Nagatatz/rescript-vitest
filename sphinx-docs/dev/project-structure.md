# Project Structure

## Top-Level Layout

```
rescript-vitest/
├── src/                  # Source code
├── docs/                 # Internal design documents
├── sphinx-docs/          # Public documentation (Sphinx)
├── .steering/            # Steering workflow documents
├── .github/workflows/    # CI/CD workflows
├── scripts/              # Maintenance scripts (skill quality evaluation)
├── quality-datasets/     # Datasets for the skill quality evaluation
└── CLAUDE.md             # Development conventions
```

## Source Code Organization

```
src/
├── Vitest.res        # describe / test / expect matchers, modifiers, lifecycle hooks
├── Vi.res            # Vi — mocks, spies, module mocking, fake timers
└── VitestConfig.res  # vitest/config — defineConfig / mergeConfig / test config (minimal)

__tests__/
├── Expect_test.res        # dogfood tests for the expect matchers, test/describe modifiers
├── Lifecycle_test.res     # dogfood tests for the lifecycle and per-test hooks
├── Only_test.res          # dogfood tests for the .only modifiers (own file: .only is file-scoped)
├── ModuleMock_test.res    # dogfood tests for vi.mock with a factory / vi.unmock
├── Vi_test.res            # dogfood tests for Vi mocks / timers
└── VitestConfig_test.res  # dogfood tests for the vitest/config bindings
```

ReScript compiles in-source, so each `src/Foo.res` produces a sibling
`src/Foo.res.js` (ESM); `*.res.js` and `lib/` are `.gitignore`-d build products.
Every exported binding in `src/` is exercised by a dogfood test in
`__tests__/`; the test files are split by topic rather than one-to-one by module.

