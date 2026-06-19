# @nagatatz/rescript-vitest

Type-safe [ReScript](https://rescript-lang.org/) bindings for [Vitest](https://vitest.dev/).

The bindings are *faithful*: matchers are side-effecting and throw on failure,
exactly like Vitest itself. The `expect(value)` wrapper carries the type of the
value under test, so matchers such as `toBe` stay honest at compile time.

- ✅ `describe` / `test` / `it` (+ `.only` / `.skip` / `.todo` / `.each` / `.concurrent`)
- ✅ Lifecycle hooks (`beforeEach` / `afterEach` / `beforeAll` / `afterAll`, sync & async)
- ✅ The full `expect` matcher set (equality, numbers, strings, collections, objects, exceptions, snapshots, mock matchers)
- ✅ Negation (`not_`) and async assertions (`resolves` / `rejects`)
- ✅ `Vi` — mock functions, spies, module mocking and fake timers

## Why another binding?

[`rescript-vitest`](https://github.com/cometkim/rescript-vitest) (cometkim) and
[`@greenfinity/rescript-vitest`](https://www.npmjs.com/package/@greenfinity/rescript-vitest)
both target Vitest 2/3 and pin the dependency tree to Vite 5. Vitest **4.1+**
requires `vite/module-runner` (Vite 6+), so those bindings block the upgrade.
This package targets Vitest 4 and newer, tracking the latest Vite/Vitest releases
rather than pinning to a fixed major.

## Requirements

| Tool | Version |
|------|---------|
| ReScript | `^12.0.0` |
| Vitest | `>=4.0.0` (latest recommended) |
| Vite | `>=6` (Vitest 4+ peer; latest recommended) |

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
`test`, `testAsync`, `testOnly`, `testSkip`, `testTodo`, `testConcurrent`,
`testEach`, `it`, `itAsync`, `itOnly`, `itSkip`.

### Lifecycle
`beforeAll`, `afterAll`, `beforeEach`, `afterEach` (each with an `…Async` variant).

### `expect` matchers
- **Equality:** `toBe`, `toEqual`, `toStrictEqual`
- **Truthiness:** `toBeTruthy`, `toBeFalsy`, `toBeNull`, `toBeUndefined`, `toBeDefined`, `toBeNaN`
- **Numbers:** `toBeGreaterThan`, `toBeGreaterThanOrEqual`, `toBeLessThan`, `toBeLessThanOrEqual`, `toBeCloseTo`, `toBeCloseToWithDigits`
- **Strings:** `toMatch`, `toMatchRegExp`, `toContainString`
- **Collections:** `toContain`, `toContainEqual`, `toHaveLength`
- **Objects:** `toMatchObject`, `toHaveProperty`, `toHavePropertyValue`
- **Exceptions:** `toThrow`, `toThrowWithMessage`, `toThrowRegExp`
- **Snapshots:** `toMatchSnapshot`, `toMatchSnapshotWithName`, `toMatchInlineSnapshot`, `toThrowErrorMatchingSnapshot`, `toThrowErrorMatchingInlineSnapshot`
- **Mocks:** `toHaveBeenCalled`, `toHaveBeenCalledOnce`, `toHaveBeenCalledTimes`, `toHaveReturned`
- **Modifiers:** `not_`, `resolves` / `rejects` (+ the `Async` matcher module)

### `Vi`
- **Create:** `fn`, `fnWith`, `fn0`, `fn1`, `fn2`, `spyOn`
- **`MockFn`:** `asFn`, `asAssertion`, `calls`, `results`, `mockClear`, `mockReset`, `mockRestore`, `mockImplementation`, `mockImplementationOnce`, `mockReturnValue`, `mockReturnValueOnce`, `mockResolvedValue`, `mockRejectedValue`
- **Modules:** `mock`, `mockWithFactory`, `unmock`, `doMock`, `resetModules`
- **Global state:** `clearAllMocks`, `resetAllMocks`, `restoreAllMocks`
- **Timers:** `useFakeTimers`, `useRealTimers`, `runAllTimers`, `runOnlyPendingTimers`, `advanceTimersByTime`, `advanceTimersToNextTimer`, `setSystemTime`, `clearAllTimers`

## Development

```bash
pnpm install
pnpm build        # compile ReScript bindings + tests
pnpm test         # run the dogfood test suite under Vitest
```

## License

[MIT](./LICENSE)
