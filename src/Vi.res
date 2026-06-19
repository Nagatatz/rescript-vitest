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

  /** Make an async mock resolve with a value on the next call only. */
  @send external mockResolvedValueOnce: (t<'fn>, 'ret) => t<'fn> = "mockResolvedValueOnce"

  /** Make an async mock reject with a reason on the next call only. */
  @send external mockRejectedValueOnce: (t<'fn>, 'err) => t<'fn> = "mockRejectedValueOnce"

  /** Make the mock return its `this` context (useful for method chaining). */
  @send external mockReturnThis: t<'fn> => t<'fn> = "mockReturnThis"

  /** The mock's current name (set via `mockName`, defaults to `"vi.fn()"`). */
  @send external getMockName: t<'fn> => string = "getMockName"

  /** Give the mock a name shown in assertion error messages. */
  @send external mockName: (t<'fn>, string) => t<'fn> = "mockName"

  /** The current implementation, or `None` if none is configured. */
  @send @return(nullable)
  external getMockImplementation: t<'fn> => option<'fn> = "getMockImplementation"

  /**
   * Temporarily replace the implementation while running `callback`, restoring
   * the previous implementation afterwards. The callback must be synchronous.
   */
  @send external withImplementation: (t<'fn>, 'fn, unit => unit) => t<'fn> = "withImplementation"
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

/**
 * `vi.spyOn(object, key, accessor)` — spy on a `#get` / `#set` accessor. The
 * accessor is a polymorphic variant so only `#get` / `#set` compile; each tag
 * compiles to its own string at runtime (`#get` → `"get"`).
 */
@module("vitest") @scope("vi")
external spyOnAccessor: ('obj, string, [#get | #set]) => MockFn.t<'fn> = "spyOn"

/** Spy on the getter of an accessor property. */
let spyOnGetter = (obj, key) => spyOnAccessor(obj, key, #get)

/** Spy on the setter of an accessor property. */
let spyOnSetter = (obj, key) => spyOnAccessor(obj, key, #set)

// ============================================================================
// Mock inspection / hoisting
// ============================================================================

/**
 * `vi.mocked(fn)` — view an (already-mocked) function as a typed `MockFn.t`.
 * At runtime this is the identity function; it only supplies the mock typing
 * so the `MockFn` helpers can be used on auto-mocked module functions.
 */
@module("vitest") @scope("vi") external mocked: 'fn => MockFn.t<'fn> = "mocked"

/** `vi.isMockFunction(value)` — whether `value` is a Vitest mock function. */
@module("vitest") @scope("vi") external isMockFunction: 'a => bool = "isMockFunction"

/**
 * `vi.hoisted(factory)` — run `factory` before the file's imports are evaluated
 * and return its result. Use for values that mock factories need at hoist time.
 */
@module("vitest") @scope("vi") external hoisted: (unit => 'a) => 'a = "hoisted"

// ============================================================================
// Module mocking
// ============================================================================

/** `vi.mock("module")` — auto-mock a module by specifier. */
@module("vitest") @scope("vi") external mock: string => unit = "mock"

/** `vi.mock("module", factory)` — replace a module with a factory result. */
@module("vitest") @scope("vi") external mockWithFactory: (string, unit => 'a) => unit = "mock"

/** `vi.unmock("module")` — undo a `mock` for the module. */
@module("vitest") @scope("vi") external unmock: string => unit = "unmock"

/**
 * A disposable handle (returned by `doMock`). Calling `dispose` undoes the
 * mock; it also works with a `using` declaration. Opaque for now.
 */
type disposable

/** `vi.doMock("module", factory)` — register a mock without hoisting. Returns a disposable that undoes it. */
@module("vitest") @scope("vi") external doMock: (string, unit => 'a) => disposable = "doMock"

/** `vi.doUnmock("module")` — undo a `doMock` for the module. */
@module("vitest") @scope("vi") external doUnmock: string => unit = "doUnmock"

/** Reset the module registry so subsequent imports re-evaluate. */
@module("vitest") @scope("vi") external resetModules: unit => unit = "resetModules"

/** Import the real (unmocked) module by specifier. Annotate the result type. */
@module("vitest") @scope("vi") external importActual: string => promise<'a> = "importActual"

/** Import a module with all of its exports auto-mocked. Annotate the result type. */
@module("vitest") @scope("vi") external importMock: string => promise<'a> = "importMock"

/** Return a deep copy of `value` with its functions replaced by mocks. */
@module("vitest") @scope("vi") external mockObject: 'a => 'a = "mockObject"

/** Resolve once all pending dynamic imports have settled. */
@module("vitest") @scope("vi") external dynamicImportSettled: unit => promise<unit> = "dynamicImportSettled"

// ============================================================================
// Global / environment stubs
// ============================================================================

/** Replace a global (e.g. `"fetch"`) until `unstubAllGlobals`. */
@module("vitest") @scope("vi") external stubGlobal: (string, 'a) => unit = "stubGlobal"

/** Replace an environment variable until `unstubAllEnvs`. */
@module("vitest") @scope("vi") external stubEnv: (string, string) => unit = "stubEnv"

/** Restore every global replaced with `stubGlobal`. */
@module("vitest") @scope("vi") external unstubAllGlobals: unit => unit = "unstubAllGlobals"

/** Restore every environment variable replaced with `stubEnv`. */
@module("vitest") @scope("vi") external unstubAllEnvs: unit => unit = "unstubAllEnvs"

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

// Async variants — they flush the microtask queue between timers, so timers
// that schedule promises resolve correctly. Each returns a `promise` to await.

/** Async `advanceTimersByTime`. */
@module("vitest") @scope("vi")
external advanceTimersByTimeAsync: int => promise<unit> = "advanceTimersByTimeAsync"
/** Async `runAllTimers`. */
@module("vitest") @scope("vi") external runAllTimersAsync: unit => promise<unit> = "runAllTimersAsync"
/** Async `runOnlyPendingTimers`. */
@module("vitest") @scope("vi")
external runOnlyPendingTimersAsync: unit => promise<unit> = "runOnlyPendingTimersAsync"
/** Async `advanceTimersToNextTimer`. */
@module("vitest") @scope("vi")
external advanceTimersToNextTimerAsync: unit => promise<unit> = "advanceTimersToNextTimerAsync"
/** Advance to the next animation frame (`requestAnimationFrame`). */
@module("vitest") @scope("vi") external advanceTimersToNextFrame: unit => unit = "advanceTimersToNextFrame"

// Timer inspection.

/** Whether fake timers are currently installed. */
@module("vitest") @scope("vi") external isFakeTimers: unit => bool = "isFakeTimers"
/** Number of pending fake timers. */
@module("vitest") @scope("vi") external getTimerCount: unit => int = "getTimerCount"
/** The currently mocked clock as a `Date`, or `None` if no time is pinned. */
@module("vitest") @scope("vi") @return(nullable)
external getMockedSystemTime: unit => option<Date.t> = "getMockedSystemTime"
/** The real wall-clock time in epoch milliseconds, ignoring fake timers. */
@module("vitest") @scope("vi") external getRealSystemTime: unit => float = "getRealSystemTime"

/** Set how fake timers advance: `"manual"`, `"nextTimerAsync"`, or `"interval"`. */
@module("vitest") @scope("vi") external setTimerTickMode: string => unit = "setTimerTickMode"

/** `setTimerTickMode("interval", interval)` — advance on a fixed interval (ms). */
@module("vitest") @scope("vi")
external setTimerTickModeWithInterval: (string, int) => unit = "setTimerTickMode"

// ============================================================================
// Waiting
// ============================================================================

/** Retry `callback` until it returns without throwing, then resolve its result. */
@module("vitest") @scope("vi") external waitFor: (unit => 'a) => promise<'a> = "waitFor"

/** Retry `callback` until it returns a truthy value, then resolve that value. */
@module("vitest") @scope("vi") external waitUntil: (unit => 'a) => promise<'a> = "waitUntil"
