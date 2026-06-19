# Changelog

## Unreleased

<!-- Add changes for the next release here -->

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

### Changed

-

### Fixed

-

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
