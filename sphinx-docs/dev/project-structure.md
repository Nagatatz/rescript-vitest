# Project Structure

## Top-Level Layout

```
rescript-vitest/
├── src/                  # Source code
├── docs/                 # Internal design documents
├── sphinx-docs/          # Public documentation (Sphinx)
├── .steering/            # Steering workflow documents
├── .github/workflows/    # CI/CD workflows
└── CLAUDE.md             # Development conventions
```

## Source Code Organization

```
src/
├── Vitest.res        # describe / test / expect matchers, modifiers, lifecycle hooks
├── Vi.res            # Vi — mocks, spies, module mocking, fake timers
└── VitestConfig.res  # vitest/config — defineConfig / mergeConfig / test config (minimal)

__tests__/
├── Expect_test.res        # dogfood tests for the expect matchers
├── Vi_test.res            # dogfood tests for Vi mocks / timers
└── VitestConfig_test.res  # dogfood tests for the vitest/config bindings
```

ReScript compiles in-source, so each `src/Foo.res` produces a sibling
`src/Foo.res.js` (ESM); `*.res.js` and `lib/` are `.gitignore`-d build products.
Each binding module in `src/` has a matching dogfood test in `__tests__/`.

