# Changelog

## Unreleased

<!-- Add changes for the next release here -->

### Added

- Mock call-argument matchers: `toHaveBeenCalledWith`, `toHaveBeenLastCalledWith`, `toHaveBeenNthCalledWith`, `toHaveBeenCalledExactlyOnceWith` (each with a two-argument `…With2` variant).
- Mock return-value matchers: `toHaveReturnedTimes`, `toHaveReturnedWith`, `toHaveLastReturnedWith`, `toHaveNthReturnedWith`.
- `Vi.MockFn` lifecycle helpers: `mockResolvedValueOnce`, `mockRejectedValueOnce`, `mockReturnThis`, `getMockName`, `mockName`, `getMockImplementation`, `withImplementation`.
- `Vi` mock inspection and hoisting helpers: `mocked`, `isMockFunction`, `hoisted`.
- Per-test lifecycle hooks: `onTestFailed`, `onTestFinished` (each with an `…Async` variant).

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
