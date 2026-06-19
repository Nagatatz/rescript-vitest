# @nagatatz/rescript-vitest

[![CI](https://github.com/Nagatatz/rescript-vitest/actions/workflows/ci.yml/badge.svg)](https://github.com/Nagatatz/rescript-vitest/actions/workflows/ci.yml)
[![Sponsor](https://img.shields.io/github/sponsors/Nagatatz?logo=githubsponsors&label=Sponsor)](https://github.com/sponsors/Nagatatz)

Type-safe [ReScript](https://rescript-lang.org/) bindings for [Vitest](https://vitest.dev/).

The bindings are *faithful*: matchers are side-effecting and throw on failure,
exactly like Vitest itself. The `expect(value)` wrapper carries the type of the
value under test, so matchers such as `toBe` stay honest at compile time.

- ✅ `describe` / `test` / `it` (+ `.only` / `.skip` / `.todo` / `.each` / `.concurrent` / `.sequential` / `.shuffle` / `.skipIf` / `.runIf` / `.fails` / `.for`)
- ✅ Lifecycle hooks (`beforeEach` / `afterEach` / `beforeAll` / `afterAll` / `onTestFailed` / `onTestFinished`, sync & async)
- ✅ The full `expect` matcher set (equality, numbers, strings, collections, objects, type/predicate, exceptions, snapshots — inline and file, mock call/return/resolve matchers)
- ✅ Asymmetric matchers and negations (`Expect.anything` / `arrayContaining` / `objectContaining` / … and `Expect.Not.*`), plus assertion guards (`assertions` / `hasAssertions` / `soft` / `poll`)
- ✅ Negation (`not_`) and async assertions (`resolves` / `rejects`)
- ✅ `Vi` — mock functions, spies (incl. getter/setter), module mocking, global/env stubs, and fake timers (sync & async) with `waitFor` / `waitUntil`
- ✅ `VitestConfig` — minimal `vitest/config` bindings (`defineConfig` / `mergeConfig` / `defineProject` + the common `test` fields)

## Why another binding?

[`rescript-vitest`](https://github.com/cometkim/rescript-vitest) (cometkim) and
[`@greenfinity/rescript-vitest`](https://www.npmjs.com/package/@greenfinity/rescript-vitest)
both target Vitest 2/3 and pin the dependency tree to Vite 5. Vitest **4.1+**
requires `vite/module-runner` (Vite 6+), so those bindings block the upgrade.
This package targets Vitest 4 (Vite 6/7) directly.

## Requirements

| Tool | Version |
|------|---------|
| ReScript | `^12.0.0` |
| Vitest | `^4.0.0` |
| Vite | `^6` or `^7` (Vitest 4 peer) |

## Install

```bash
pnpm add -D @nagatatz/rescript-vitest vitest vite
```

Add the package to your `rescript.json` dependencies so ReScript compiles the
bindings:

```json
{
  "dependencies": ["@nagatatz/rescript-vitest"]
}
```

Point Vitest at the compiled test files (`*.res.js`):

```js
// vitest.config.js
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['__tests__/**/*_test.res.js'],
  },
})
```

## Usage

```rescript
open Vitest

describe("Math", () => {
  test("adds", () => {
    expect(1 + 1)->toBe(2)
  })

  test("negation", () => {
    expect([1, 2])->not_->toContain(3)
  })

  testAsync("works with promises", async () => {
    await expect(Promise.resolve(42))->resolves->Async.toBe(42)
  })
})
```

### Mocks, spies and timers

```rescript
open Vitest

test("counts calls", () => {
  let mock = Vi.fn1()
  let fn = mock->Vi.MockFn.asFn   // use the mock where a function is expected
  fn("a")->ignore
  mock->Vi.MockFn.asAssertion->toHaveBeenCalledOnce
})

test("fake timers", () => {
  Vi.useFakeTimers()
  // ... schedule a timer ...
  Vi.advanceTimersByTime(1000)
  Vi.useRealTimers()
})
```

## API cheat sheet

### Test structure (`Vitest`)
`describe`, `describeAsync`, `describeOnly`, `describeSkip`, `describeEach`,
`describeTodo`, `describeConcurrent`, `describeSequential`, `describeShuffle`,
`describeSkipIf`, `describeRunIf`, `describeFor`,
`test`, `testAsync`, `testOnly`, `testSkip`, `testTodo`, `testConcurrent`,
`testEach`, `testFor`, `testSkipIf`, `testSkipIfAsync`, `testRunIf`, `testRunIfAsync`,
`testFails`, `testFailsAsync`, `testSequential`, `testSequentialAsync`,
`it`, `itAsync`, `itOnly`, `itSkip`, `itTodo`, `itConcurrent`, `itEach`, `itFails`,
`itSequential`, `itSkipIf`, `itRunIf`.

### Lifecycle
`beforeAll`, `afterAll`, `beforeEach`, `afterEach`, plus the per-test hooks `onTestFailed`, `onTestFinished` (each with an `…Async` variant).

### `expect` matchers
- **Equality:** `toBe`, `toEqual`, `toStrictEqual`
- **Truthiness:** `toBeTruthy`, `toBeFalsy`, `toBeNull`, `toBeUndefined`, `toBeDefined`, `toBeNaN`
- **Numbers:** `toBeGreaterThan`, `toBeGreaterThanOrEqual`, `toBeLessThan`, `toBeLessThanOrEqual`, `toBeCloseTo`, `toBeCloseToWithDigits`
- **Strings:** `toMatch`, `toMatchRegExp`, `toContainString`
- **Collections:** `toContain`, `toContainEqual`, `toHaveLength`
- **Objects:** `toMatchObject`, `toHaveProperty`, `toHavePropertyValue`
- **Type & predicate:** `toBeTypeOf`, `toBeInstanceOf`, `toBeOneOf`, `toSatisfy`
- **Exceptions:** `toThrow`, `toThrowWithMessage`, `toThrowRegExp`
- **Snapshots:** `toMatchSnapshot`, `toMatchSnapshotWithName`, `toMatchInlineSnapshot`, `toMatchFileSnapshot`, `toThrowErrorMatchingSnapshot`, `toThrowErrorMatchingInlineSnapshot`
- **Mocks (calls):** `toHaveBeenCalled`, `toHaveBeenCalledOnce`, `toHaveBeenCalledTimes`, `toHaveBeenCalledWith` (+ `…With2`), `toHaveBeenLastCalledWith` (+ `…With2`), `toHaveBeenNthCalledWith` (+ `…With2`), `toHaveBeenCalledExactlyOnceWith` (+ `…With2`)
- **Mocks (returns):** `toHaveReturned`, `toHaveReturnedTimes`, `toHaveReturnedWith`, `toHaveLastReturnedWith`, `toHaveNthReturnedWith`
- **Mocks (resolves):** `toHaveResolved`, `toHaveResolvedTimes`, `toHaveResolvedWith`, `toHaveLastResolvedWith`, `toHaveNthResolvedWith`
- **Asymmetric (`Expect` module):** `anything`, `any`, `arrayContaining`, `objectContaining`, `stringContaining`, `stringMatching` (+ `…RegExp`), `closeTo` (+ `…WithPrecision`) — embed in the expected position of `toEqual` / `toMatchObject` / `toHaveBeenCalledWith`; negated forms live in `Expect.Not`
- **Guards & special (`Expect` module):** `assertions`, `hasAssertions`, `soft`, `poll`, `unreachable` (+ `…WithMessage`)
- **Modifiers:** `not_`, `resolves` / `rejects` (+ the `Async` matcher module)

### Not yet bound

`test.extend` (fixtures) and `expect.extend` (custom matchers) are intentionally
left unbound: their JavaScript shapes — a fixtures object injected via `use`
callbacks, and matchers added dynamically onto every assertion — cannot be
expressed faithfully or type-safely in ReScript without per-matcher manual
bindings. Use ReScript helper functions instead of fixtures, and a dedicated
`@send` external if you must call a project-specific custom matcher.

### `Vi`
- **Create:** `fn`, `fnWith`, `fn0`, `fn1`, `fn2`, `spyOn`, `spyOnGetter`, `spyOnSetter`
- **`MockFn`:** `asFn`, `asAssertion`, `calls`, `results`, `mockClear`, `mockReset`, `mockRestore`, `mockImplementation`, `mockImplementationOnce`, `mockReturnValue`, `mockReturnValueOnce`, `mockResolvedValue`, `mockResolvedValueOnce`, `mockRejectedValue`, `mockRejectedValueOnce`, `mockReturnThis`, `getMockName`, `mockName`, `getMockImplementation`, `withImplementation`
- **Inspection / hoisting:** `mocked`, `isMockFunction`, `hoisted`
- **Modules:** `mock`, `mockWithFactory`, `unmock`, `doMock`, `doUnmock`, `resetModules`, `importActual`, `importMock`, `mockObject`, `dynamicImportSettled`
- **Global / env stubs:** `stubGlobal`, `stubEnv`, `unstubAllGlobals`, `unstubAllEnvs`
- **Global state:** `clearAllMocks`, `resetAllMocks`, `restoreAllMocks`
- **Timers:** `useFakeTimers`, `useRealTimers`, `runAllTimers`, `runOnlyPendingTimers`, `advanceTimersByTime`, `advanceTimersToNextTimer`, `setSystemTime`, `clearAllTimers`
- **Async timers:** `advanceTimersByTimeAsync`, `runAllTimersAsync`, `runOnlyPendingTimersAsync`, `advanceTimersToNextTimerAsync`, `advanceTimersToNextFrame`
- **Timer inspection:** `isFakeTimers`, `getTimerCount`, `getMockedSystemTime`, `getRealSystemTime`, `setTimerTickMode`
- **Waiting:** `waitFor`, `waitUntil`

### `VitestConfig` (`vitest/config`)

Minimal config-side bindings: `defineConfig`, `defineConfigFn` (function form
receiving `{mode, command}`), `mergeConfig`, `defineProject`. Configs are typed
with optional-record types covering the common `test` fields — `globals`,
`environment`, `include_`, `exclude`, `setupFiles`, `coverage`, `pool`,
`testTimeout`, `hookTimeout`, `reporters`, `watch`, `projects` — and `coverage`
(`provider`, `enabled`, `reporter`, `include_`, `exclude`). (`include` is a
ReScript keyword, so the field is named `include_` and maps to JS `"include"`.)

**Scope (intentional):** Vite-level config (`plugins`, `resolve`, `server`,
`build`) and the long tail of `test` options are **not** bound — write those in a
plain JS config file. Config objects are write-once data with a large, churning
surface, so full coverage is not worth the maintenance cost.

ReScript does not emit `export default`, so wire the typed config into the real
`vitest.config` through a thin JS shim:

```rescript
// MyConfig.res
let config = VitestConfig.defineConfig({
  test: {globals: true, environment: "node", include_: ["__tests__/**/*_test.res.js"]},
})
```

```js
// vitest.config.js
import { config } from "./MyConfig.res.js"
export default config
```

## Development

```bash
pnpm install
pnpm build        # compile ReScript bindings + tests
pnpm test         # run the dogfood test suite under Vitest 4
```

## License

[MIT](./LICENSE)
