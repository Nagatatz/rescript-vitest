/**
 * Vi — bindings for Vitest's `vi` utility object: mock functions, spies,
 * module mocking and fake timers.
 *
 *   open Vitest
 *
 *   test("calls the callback", () => {
 *     let cb = Vi.fn1()
 *     doWork(Vi.MockFn.asFn(cb))
 *     expect(cb->Vi.MockFn.asAssertion)->toHaveBeenCalledOnce
 *   })
 */

/**
 * A Vitest mock function. The type parameter `'fn` records the function shape
 * it stands in for (e.g. `int => string`), so `asFn` hands back something you
 * can actually call where that signature is expected.
 */
module MockFn = {
  type t<'fn>

  /** Use the mock where a value of its underlying function type is expected. */
  external asFn: t<'fn> => 'fn = "%identity"

  /**
   * View the mock as an assertion target for the mock matchers
   * (`toHaveBeenCalled`, etc.). This is just `expect` specialized to mocks.
   */
  @module("vitest")
  external asAssertion: t<'fn> => Vitest.assertion<t<'fn>> = "expect"

  /** The arguments of every recorded call. */
  @get @scope("mock") external calls: t<'fn> => array<'args> = "calls"

  /** The return values of every recorded call. */
  @get @scope("mock") external results: t<'fn> => array<'ret> = "results"

  /** Reset recorded calls and results (keeps the implementation). */
  @send external mockClear: t<'fn> => t<'fn> = "mockClear"

  /** Reset calls, results and any configured implementation. */
  @send external mockReset: t<'fn> => t<'fn> = "mockReset"

  /** Restore the original (for spies created with `spyOn`). */
  @send external mockRestore: t<'fn> => t<'fn> = "mockRestore"

  /** Replace the implementation for all future calls. */
  @send external mockImplementation: (t<'fn>, 'fn) => t<'fn> = "mockImplementation"

  /** Replace the implementation for the next call only. */
  @send external mockImplementationOnce: (t<'fn>, 'fn) => t<'fn> = "mockImplementationOnce"

  /** Make the mock return a fixed value on every call. */
  @send external mockReturnValue: (t<'fn>, 'ret) => t<'fn> = "mockReturnValue"

  /** Make the mock return a fixed value on the next call only. */
  @send external mockReturnValueOnce: (t<'fn>, 'ret) => t<'fn> = "mockReturnValueOnce"

  /** Make an async mock resolve with a value. */
  @send external mockResolvedValue: (t<'fn>, 'ret) => t<'fn> = "mockResolvedValue"

  /** Make an async mock reject with a reason. */
  @send external mockRejectedValue: (t<'fn>, 'err) => t<'fn> = "mockRejectedValue"
}

// ============================================================================
// Creating mocks
// ============================================================================

/** `vi.fn()` — an untyped, no-op mock function. */
@module("vitest") @scope("vi") external fn: unit => MockFn.t<'fn> = "fn"

/** `vi.fn(impl)` — a mock backed by an initial implementation. */
@module("vitest") @scope("vi") external fnWith: 'fn => MockFn.t<'fn> = "fn"

/** `vi.fn()` typed as a 0-arg function returning `'a`. */
@module("vitest") @scope("vi") external fn0: unit => MockFn.t<unit => 'a> = "fn"

/** `vi.fn()` typed as a 1-arg function. */
@module("vitest") @scope("vi") external fn1: unit => MockFn.t<'a => 'b> = "fn"

/** `vi.fn()` typed as a 2-arg function. */
@module("vitest") @scope("vi") external fn2: unit => MockFn.t<('a, 'b) => 'c> = "fn"

/** `vi.spyOn(object, "method")` — wrap an existing method with a spy. */
@module("vitest") @scope("vi") external spyOn: ('obj, string) => MockFn.t<'fn> = "spyOn"

// ============================================================================
// Module mocking
// ============================================================================

/** `vi.mock("module")` — auto-mock a module by specifier. */
@module("vitest") @scope("vi") external mock: string => unit = "mock"

/** `vi.mock("module", factory)` — replace a module with a factory result. */
@module("vitest") @scope("vi") external mockWithFactory: (string, unit => 'a) => unit = "mock"

/** `vi.unmock("module")` — undo a `mock` for the module. */
@module("vitest") @scope("vi") external unmock: string => unit = "unmock"

/** `vi.doMock("module", factory)` — register a mock without hoisting. */
@module("vitest") @scope("vi") external doMock: (string, unit => 'a) => unit = "doMock"

/** Reset the module registry so subsequent imports re-evaluate. */
@module("vitest") @scope("vi") external resetModules: unit => unit = "resetModules"

// ============================================================================
// Global mock state
// ============================================================================

/** Clear recorded calls/results on every mock. */
@module("vitest") @scope("vi") external clearAllMocks: unit => unit = "clearAllMocks"

/** Reset implementations on every mock. */
@module("vitest") @scope("vi") external resetAllMocks: unit => unit = "resetAllMocks"

/** Restore every spy created with `spyOn`. */
@module("vitest") @scope("vi") external restoreAllMocks: unit => unit = "restoreAllMocks"

// ============================================================================
// Fake timers
// ============================================================================

@module("vitest") @scope("vi") external useFakeTimers: unit => unit = "useFakeTimers"
@module("vitest") @scope("vi") external useRealTimers: unit => unit = "useRealTimers"
@module("vitest") @scope("vi") external runAllTimers: unit => unit = "runAllTimers"
@module("vitest") @scope("vi") external runAllTicks: unit => unit = "runAllTicks"
@module("vitest") @scope("vi") external runOnlyPendingTimers: unit => unit = "runOnlyPendingTimers"
@module("vitest") @scope("vi") external advanceTimersByTime: int => unit = "advanceTimersByTime"
@module("vitest") @scope("vi") external advanceTimersToNextTimer: unit => unit = "advanceTimersToNextTimer"
@module("vitest") @scope("vi") external clearAllTimers: unit => unit = "clearAllTimers"

/** Pin the mocked clock to a specific epoch (milliseconds). */
@module("vitest") @scope("vi") external setSystemTimeMs: float => unit = "setSystemTime"

/** Pin the mocked clock to a specific `Date`. */
@module("vitest") @scope("vi") external setSystemTime: Date.t => unit = "setSystemTime"
