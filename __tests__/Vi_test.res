/**
 * Dogfood tests for the `Vi` mock / spy / fake-timer bindings.
 */
open Vitest

// Minimal setTimeout binding, used to drive the fake-timer tests.
@val external setTimeout: (unit => unit, int) => unit = "setTimeout"

// A small record whose method we can spy on. ReScript records compile to plain
// JS objects, so `Vi.spyOn` can replace the field in place.
type calculator = {add: (int, int) => int}

describe("Vi — mock functions", () => {
  afterEach(() => Vi.clearAllMocks())

  test("records call count", () => {
    let m = Vi.fn1()
    let f = m->Vi.MockFn.asFn
    f("a")->ignore
    f("b")->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenCalledTimes(2)
  })

  test("mockReturnValue controls the result", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockReturnValue(99)->ignore
    expect((m->Vi.MockFn.asFn)())->toBe(99)
    m->Vi.MockFn.asAssertion->toHaveBeenCalledOnce
  })

  test("mockImplementation runs custom logic", () => {
    let m = Vi.fn1()
    m->Vi.MockFn.mockImplementation(x => x * 2)->ignore
    expect((m->Vi.MockFn.asFn)(21))->toBe(42)
  })
})

describe("Vi — spies", () => {
  test("spyOn wraps an existing method", () => {
    let calc = {add: (a, b) => a + b}
    let spy = Vi.spyOn(calc, "add")
    spy->Vi.MockFn.mockReturnValue(0)->ignore

    expect(calc.add(1, 2))->toBe(0)
    spy->Vi.MockFn.asAssertion->toHaveBeenCalled
    spy->Vi.MockFn.mockRestore->ignore
  })
})

describe("Vi — mock lifecycle", () => {
  afterEach(() => Vi.clearAllMocks())

  testAsync("mockResolvedValueOnce resolves the next call", async () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockResolvedValueOnce(42)->ignore
    let result = await (m->Vi.MockFn.asFn)()
    expect(result)->toBe(42)
  })

  testAsync("mockRejectedValueOnce rejects the next call", async () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockRejectedValueOnce(JsError.make("boom"))->ignore
    await expect((m->Vi.MockFn.asFn)())->rejects->Async.toThrowWithMessage("boom")
  })

  test("mockReturnThis is chainable and callable", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockReturnThis->ignore
    (m->Vi.MockFn.asFn)()->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenCalledOnce
  })

  test("mockName / getMockName round-trip", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockName("greeter")->ignore
    expect(m->Vi.MockFn.getMockName)->toBe("greeter")
  })

  test("getMockImplementation reflects the configured implementation", () => {
    let m = Vi.fn1()
    expect((m->Vi.MockFn.getMockImplementation)->Option.isNone)->toBeTruthy
    m->Vi.MockFn.mockImplementation(x => x + 1)->ignore
    expect((m->Vi.MockFn.getMockImplementation)->Option.isSome)->toBeTruthy
  })

  test("withImplementation overrides only during the callback", () => {
    let m = Vi.fn1()
    m->Vi.MockFn.mockImplementation(_ => "base")->ignore
    let f = m->Vi.MockFn.asFn
    m
    ->Vi.MockFn.withImplementation(_ => "temp", () => {
      expect(f("x"))->toBe("temp")
    })
    ->ignore
    expect(f("y"))->toBe("base")
  })
})

describe("Vi — mock inspection & hoisting", () => {
  afterEach(() => Vi.clearAllMocks())

  test("mocked views a function as a typed mock", () => {
    let m = Vi.fn1()
    let f = m->Vi.MockFn.asFn
    Vi.mocked(f)->Vi.MockFn.mockReturnValue("hi")->ignore
    expect(f("x"))->toBe("hi")
  })

  test("isMockFunction distinguishes mocks from plain functions", () => {
    let m = Vi.fn0()
    expect(Vi.isMockFunction(m->Vi.MockFn.asFn))->toBeTruthy
    expect(Vi.isMockFunction(() => 1))->toBeFalsy
  })

  test("hoisted runs a factory and returns its value", () => {
    let v = Vi.hoisted(() => 123)
    expect(v)->toBe(123)
  })
})

describe("Vi — fake timers", () => {
  test("advanceTimersByTime fires pending timers", () => {
    Vi.useFakeTimers()
    let fired = ref(false)
    setTimeout(() => fired := true, 1000)
    expect(fired.contents)->toBeFalsy
    Vi.advanceTimersByTime(1000)
    expect(fired.contents)->toBeTruthy
    Vi.useRealTimers()
  })
})
