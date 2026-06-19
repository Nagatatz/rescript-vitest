# Changelog

## Unreleased

### Added

- `Vi.setTimerTickModeWithInterval` — the `"interval"` tick mode now accepts its `interval` (ms) argument.

### Changed

- **Breaking:** `onTestFailed` / `onTestFinished` (and their `…Async` variants) callbacks now receive the per-test `testContext` value (`testContext => unit`) instead of taking no argument. Update callbacks from `() => …` to `_ctx => …`.
- **Breaking:** `Vi.doMock` now returns a `Vi.disposable` handle (matching Vitest 4) instead of `unit`.

### Fixed

-

## 0.1.0 (2026-06-19)

Initial release: type-safe ReScript bindings covering the Vitest 4 surface.

### Added

- Mock call-argument matchers: `toHaveBeenCalledWith`, `toHaveBeenLastCalledWith`, `toHaveBeenNthCalledWith`, `toHaveBeenCalledExactlyOnceWith` (each with a two-argument `…With2` variant).
- Mock return-value matchers: `toHaveReturnedTimes`, `toHaveReturnedWith`, `toHaveLastReturnedWith`, `toHaveNthReturnedWith`.
- `Vi.MockFn` lifecycle helpers: `mockResolvedValueOnce`, `mockRejectedValueOnce`, `mockReturnThis`, `getMockName`, `mockName`, `getMockImplementation`, `withImplementation`.
- `Vi` mock inspection and hoisting helpers: `mocked`, `isMockFunction`, `hoisted`.
- Per-test lifecycle hooks: `onTestFailed`, `onTestFinished` (each with an `…Async` variant).
- Type and predicate matchers: `toBeTypeOf`, `toBeInstanceOf`, `toBeOneOf`, `toSatisfy`.
- Async-mock resolve matchers: `toHaveResolved`, `toHaveResolvedTimes`, `toHaveResolvedWith`, `toHaveLastResolvedWith`, `toHaveNthResolvedWith`.
- Async fake timers: `advanceTimersByTimeAsync`, `runAllTimersAsync`, `runOnlyPendingTimersAsync`, `advanceTimersToNextTimerAsync`, `advanceTimersToNextFrame`.
- Timer inspection: `isFakeTimers`, `getTimerCount`, `getMockedSystemTime`, `getRealSystemTime`.
- Waiting utilities: `waitFor`, `waitUntil`.
- Accessor spies: `spyOnGetter`, `spyOnSetter`.
- Global and environment stubs: `stubGlobal`, `stubEnv`, `unstubAllGlobals`, `unstubAllEnvs`.
- Module mocking completion: `importActual`, `importMock`, `doUnmock`, `mockObject`, `dynamicImportSettled`.
- Test modifiers: `testSkipIf`, `testRunIf`, `testFails`, `testFailsAsync`, `testSequential`, `testSequentialAsync`.
- Describe modifiers: `describeTodo`, `describeConcurrent`, `describeSequential`, `describeShuffle`, `describeSkipIf`, `describeRunIf`, `describeFor`.
- Asymmetric matchers (`Expect` module): `anything`, `any`, `arrayContaining`, `objectContaining`, `stringContaining`, `stringMatching`, `stringMatchingRegExp`, `closeTo`, `closeToWithPrecision`.
- Parameterized test `testFor` (`test.for`).
- Assertion guards and special assertions (`Expect` module): `assertions`, `hasAssertions`, `soft`, `poll`, `unreachable`, `unreachableWithMessage`.
- File snapshot matcher: `toMatchFileSnapshot`.
- Negated asymmetric matchers (`Expect.Not` module): `arrayContaining`, `objectContaining`, `stringContaining`, `stringMatching`, `stringMatchingRegExp`, `closeTo`, `closeToWithPrecision`.
- `it` modifiers: `itTodo`, `itConcurrent`, `itEach`, `itFails`, `itSequential`, `itSkipIf`, `itRunIf`.
- Async-body conditional tests: `testSkipIfAsync`, `testRunIfAsync`.
- Fake-timer tick mode: `setTimerTickMode`.

<!-- Template for new releases:

## x.y.z (YYYY-MM-DD)

### Added
- New feature description

### Changed
- Changed behavior description

### Fixed
- Bug fix description

### Removed
- Removed feature description
-->
