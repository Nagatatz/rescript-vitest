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
