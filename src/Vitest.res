/**
 * Vitest — type-safe ReScript bindings for the Vitest test runner.
 *
 * This module binds Vitest's test structure, lifecycle hooks and the `expect`
 * assertion API faithfully: matchers are side-effecting (they throw on failure),
 * exactly like Vitest itself. Mocks, spies and fake timers live in the `Vi`
 * module (`Vi.res`).
 *
 * Typical usage:
 *
 *   open Vitest
 *
 *   describe("Math", () => {
 *     test("adds", () => {
 *       expect(1 + 1)->toBe(2)
 *     })
 *   })
 *
 * Notes for ReScript newcomers:
 * - `@module("vitest")` imports the named binding from the "vitest" package.
 * - `@scope("describe")` accesses a property (e.g. `describe.only`).
 * - `@send` binds a method called on the first argument (`expect(x).toBe(y)`).
 * - `@get` reads a property (`expect(x).not`).
 */

// ============================================================================
// Test structure: describe / test / it
// ============================================================================

/**
 * Group related tests. The callback registers nested `describe`/`test` blocks.
 *
 * `~timeout` (optional, ms): overrides the per-suite timeout. The trailing `=?`
 * means the argument may be omitted, in which case Vitest's default is used.
 */
@module("vitest")
external describe: (string, unit => unit, ~timeout: int=?) => unit = "describe"

/** Same as `describe`, but the callback may be async (returns a `promise`). */
@module("vitest")
external describeAsync: (string, unit => promise<unit>, ~timeout: int=?) => unit = "describe"

/** Run only this suite (and other `.only` suites) in the file. */
@module("vitest") @scope("describe")
external describeOnly: (string, unit => unit, ~timeout: int=?) => unit = "only"

/** Skip this suite. */
@module("vitest") @scope("describe")
external describeSkip: (string, unit => unit, ~timeout: int=?) => unit = "skip"

/** Register a parameterized suite: `describeEach(cases)("name %i", case => ...)`. */
@module("vitest") @scope("describe")
external describeEach: array<'a> => (string, 'a => unit) => unit = "each"

/**
 * Define a single test case.
 *
 * `~timeout` (optional, ms): overrides the per-test timeout.
 */
@module("vitest")
external test: (string, unit => unit, ~timeout: int=?) => unit = "test"

/** Same as `test`, but the body may be async (returns a `promise`). */
@module("vitest")
external testAsync: (string, unit => promise<unit>, ~timeout: int=?) => unit = "test"

/** Run only this test (and other `.only` tests) in the file. */
@module("vitest") @scope("test")
external testOnly: (string, unit => unit, ~timeout: int=?) => unit = "only"

/** Async variant of `testOnly`. */
@module("vitest") @scope("test")
external testOnlyAsync: (string, unit => promise<unit>, ~timeout: int=?) => unit = "only"

/** Skip this test. */
@module("vitest") @scope("test")
external testSkip: (string, unit => unit, ~timeout: int=?) => unit = "skip"

/** Mark a test as not-yet-implemented (shown as todo in the report). */
@module("vitest") @scope("test")
external testTodo: string => unit = "todo"

/** Run this test concurrently with sibling concurrent tests. */
@module("vitest") @scope("test")
external testConcurrent: (string, unit => promise<unit>, ~timeout: int=?) => unit = "concurrent"

/** Register a parameterized test: `testEach(cases)("name %i", case => ...)`. */
@module("vitest") @scope("test")
external testEach: array<'a> => (string, 'a => unit) => unit = "each"

/** Alias of `test`, reading more naturally inside a `describe` ("it does X"). */
@module("vitest")
external it: (string, unit => unit, ~timeout: int=?) => unit = "it"

/** Async variant of `it`. */
@module("vitest")
external itAsync: (string, unit => promise<unit>, ~timeout: int=?) => unit = "it"

/** Skip this `it` case. */
@module("vitest") @scope("it")
external itSkip: (string, unit => unit, ~timeout: int=?) => unit = "skip"

/** Run only this `it` case. */
@module("vitest") @scope("it")
external itOnly: (string, unit => unit, ~timeout: int=?) => unit = "only"

// ============================================================================
// Lifecycle hooks
// ============================================================================

@module("vitest") external beforeAll: (unit => unit) => unit = "beforeAll"
@module("vitest") external beforeAllAsync: (unit => promise<unit>) => unit = "beforeAll"
@module("vitest") external afterAll: (unit => unit) => unit = "afterAll"
@module("vitest") external afterAllAsync: (unit => promise<unit>) => unit = "afterAll"
@module("vitest") external beforeEach: (unit => unit) => unit = "beforeEach"
@module("vitest") external beforeEachAsync: (unit => promise<unit>) => unit = "beforeEach"
@module("vitest") external afterEach: (unit => unit) => unit = "afterEach"
@module("vitest") external afterEachAsync: (unit => promise<unit>) => unit = "afterEach"

// ============================================================================
// expect — assertion wrappers
// ============================================================================

/**
 * A synchronous assertion produced by `expect(value)`. The type parameter `'a`
 * is the type of the value under test, which keeps matchers like `toBe` honest.
 */
type assertion<'a>

/**
 * An asynchronous assertion produced by `expect(promise)->resolves` /
 * `->rejects`. Its matchers (see the `Async` module) return `promise<unit>`,
 * so they must be `await`ed inside an async test.
 */
type asyncAssertion<'a>

/** Wrap a value in an assertion: `expect(value)->toBe(...)`. */
@module("vitest") external expect: 'a => assertion<'a> = "expect"

/** Negate the next matcher: `expect(x)->not_->toBe(y)`. */
@get external not_: assertion<'a> => assertion<'a> = "not"

/** Unwrap a fulfilled promise: `await expect(p)->resolves->Async.toBe(v)`. */
@get external resolves: assertion<promise<'a>> => asyncAssertion<'a> = "resolves"

/** Assert a promise rejects: `await expect(p)->rejects->Async.toThrow`. */
@get external rejects: assertion<promise<'a>> => asyncAssertion<'b> = "rejects"

// ----------------------------------------------------------------------------
// Equality / identity
// ----------------------------------------------------------------------------

/** `Object.is` identity (primitives, references). */
@send external toBe: (assertion<'a>, 'a) => unit = "toBe"

/** Recursive structural equality (ignores `undefined` properties). */
@send external toEqual: (assertion<'a>, 'a) => unit = "toEqual"

/** Like `toEqual`, but also checks types and `undefined` properties. */
@send external toStrictEqual: (assertion<'a>, 'a) => unit = "toStrictEqual"

// ----------------------------------------------------------------------------
// Truthiness / nullishness
// ----------------------------------------------------------------------------

@send external toBeTruthy: assertion<'a> => unit = "toBeTruthy"
@send external toBeFalsy: assertion<'a> => unit = "toBeFalsy"
@send external toBeNull: assertion<'a> => unit = "toBeNull"
@send external toBeUndefined: assertion<'a> => unit = "toBeUndefined"
@send external toBeDefined: assertion<'a> => unit = "toBeDefined"
@send external toBeNaN: assertion<'a> => unit = "toBeNaN"

// ----------------------------------------------------------------------------
// Numbers
// ----------------------------------------------------------------------------

@send external toBeGreaterThan: (assertion<'a>, 'a) => unit = "toBeGreaterThan"
@send external toBeGreaterThanOrEqual: (assertion<'a>, 'a) => unit = "toBeGreaterThanOrEqual"
@send external toBeLessThan: (assertion<'a>, 'a) => unit = "toBeLessThan"
@send external toBeLessThanOrEqual: (assertion<'a>, 'a) => unit = "toBeLessThanOrEqual"

/** Float comparison up to Vitest's default precision (2 digits). */
@send external toBeCloseTo: (assertion<float>, float) => unit = "toBeCloseTo"

/** Float comparison with an explicit number of digits. */
@send external toBeCloseToWithDigits: (assertion<float>, float, int) => unit = "toBeCloseTo"

// ----------------------------------------------------------------------------
// Strings
// ----------------------------------------------------------------------------

@send external toMatch: (assertion<string>, string) => unit = "toMatch"
@send external toMatchRegExp: (assertion<string>, RegExp.t) => unit = "toMatch"

/** Substring containment on a string under test. */
@send external toContainString: (assertion<string>, string) => unit = "toContain"

// ----------------------------------------------------------------------------
// Collections
// ----------------------------------------------------------------------------

/** Membership by identity (`Object.is`). */
@send external toContain: (assertion<array<'a>>, 'a) => unit = "toContain"

/** Membership by structural equality. */
@send external toContainEqual: (assertion<array<'a>>, 'a) => unit = "toContainEqual"

/** Length of an array or string under test. */
@send external toHaveLength: (assertion<'a>, int) => unit = "toHaveLength"

// ----------------------------------------------------------------------------
// Objects
// ----------------------------------------------------------------------------

/** Partial structural match: the actual object contains the expected subset. */
@send external toMatchObject: (assertion<'a>, 'b) => unit = "toMatchObject"

/** Property existence by key path (e.g. `"a.b.c"`). */
@send external toHaveProperty: (assertion<'a>, string) => unit = "toHaveProperty"

/** Property existence with an expected value. */
@send external toHavePropertyValue: (assertion<'a>, string, 'b) => unit = "toHaveProperty"

// ----------------------------------------------------------------------------
// Exceptions — the value under test must be a thunk `unit => _`
// ----------------------------------------------------------------------------

@send external toThrow: assertion<unit => 'a> => unit = "toThrow"
@send external toThrowWithMessage: (assertion<unit => 'a>, string) => unit = "toThrow"
@send external toThrowRegExp: (assertion<unit => 'a>, RegExp.t) => unit = "toThrow"

// ----------------------------------------------------------------------------
// Snapshots
// ----------------------------------------------------------------------------

@send external toMatchSnapshot: assertion<'a> => unit = "toMatchSnapshot"
@send external toMatchSnapshotWithName: (assertion<'a>, string) => unit = "toMatchSnapshot"
@send external toMatchInlineSnapshot: (assertion<'a>, string) => unit = "toMatchInlineSnapshot"
@send external toThrowErrorMatchingSnapshot: assertion<unit => 'a> => unit = "toThrowErrorMatchingSnapshot"
@send
external toThrowErrorMatchingInlineSnapshot: (assertion<unit => 'a>, string) => unit =
  "toThrowErrorMatchingInlineSnapshot"

// ----------------------------------------------------------------------------
// Mock / spy matchers — the value under test is a `Vi.MockFn.t`
// ----------------------------------------------------------------------------

@send external toHaveBeenCalled: assertion<'a> => unit = "toHaveBeenCalled"
@send external toHaveBeenCalledOnce: assertion<'a> => unit = "toHaveBeenCalledOnce"
@send external toHaveBeenCalledTimes: (assertion<'a>, int) => unit = "toHaveBeenCalledTimes"
@send external toHaveReturned: assertion<'a> => unit = "toHaveReturned"

// Call-argument matchers. Vitest takes the arguments variadically; ReScript
// `@send` is fixed-arity, so each matcher comes in a 1-arg form and a 2-arg
// `*With2` variant (mirroring `Vi.fn1` / `Vi.fn2`). The expected argument type
// is generic because the value under test is typed `assertion<'a>` (the mock's
// signature lives in `Vi.MockFn.t`, which `Vitest` cannot reference).

/** The mock was called at least once with these arguments. */
@send external toHaveBeenCalledWith: (assertion<'a>, 'b) => unit = "toHaveBeenCalledWith"
/** Two-argument variant of `toHaveBeenCalledWith`. */
@send external toHaveBeenCalledWith2: (assertion<'a>, 'b, 'c) => unit = "toHaveBeenCalledWith"

/** The most recent call was made with these arguments. */
@send external toHaveBeenLastCalledWith: (assertion<'a>, 'b) => unit = "toHaveBeenLastCalledWith"
/** Two-argument variant of `toHaveBeenLastCalledWith`. */
@send external toHaveBeenLastCalledWith2: (assertion<'a>, 'b, 'c) => unit = "toHaveBeenLastCalledWith"

/** The nth call (1-based) was made with these arguments. */
@send external toHaveBeenNthCalledWith: (assertion<'a>, int, 'b) => unit = "toHaveBeenNthCalledWith"
/** Two-argument variant of `toHaveBeenNthCalledWith`. */
@send external toHaveBeenNthCalledWith2: (assertion<'a>, int, 'b, 'c) => unit = "toHaveBeenNthCalledWith"

/** The mock was called exactly once, and that call used these arguments. */
@send
external toHaveBeenCalledExactlyOnceWith: (assertion<'a>, 'b) => unit = "toHaveBeenCalledExactlyOnceWith"
/** Two-argument variant of `toHaveBeenCalledExactlyOnceWith`. */
@send
external toHaveBeenCalledExactlyOnceWith2: (assertion<'a>, 'b, 'c) => unit =
  "toHaveBeenCalledExactlyOnceWith"

// Return-value matchers. These take a single expected return value, so no
// arity variants are needed.

/** The mock returned successfully (did not throw) exactly `n` times. */
@send external toHaveReturnedTimes: (assertion<'a>, int) => unit = "toHaveReturnedTimes"
/** The mock returned this value on at least one call. */
@send external toHaveReturnedWith: (assertion<'a>, 'b) => unit = "toHaveReturnedWith"
/** The most recent successful return was this value. */
@send external toHaveLastReturnedWith: (assertion<'a>, 'b) => unit = "toHaveLastReturnedWith"
/** The nth call (1-based) returned this value. */
@send external toHaveNthReturnedWith: (assertion<'a>, int, 'b) => unit = "toHaveNthReturnedWith"

/**
 * Matchers for asynchronous assertions produced by `->resolves` / `->rejects`.
 * Each returns `promise<unit>` and must be `await`ed.
 *
 *   await expect(fetchUser())->resolves->Async.toEqual(expectedUser)
 */
module Async = {
  @send external toBe: (asyncAssertion<'a>, 'a) => promise<unit> = "toBe"
  @send external toEqual: (asyncAssertion<'a>, 'a) => promise<unit> = "toEqual"
  @send external toStrictEqual: (asyncAssertion<'a>, 'a) => promise<unit> = "toStrictEqual"
  @send external toThrow: asyncAssertion<'a> => promise<unit> = "toThrow"
  @send external toThrowWithMessage: (asyncAssertion<'a>, string) => promise<unit> = "toThrow"
}
