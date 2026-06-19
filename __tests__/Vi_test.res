/**
 * Dogfood tests for the `Vi` mock / spy / fake-timer bindings.
 */
open Vitest

// Minimal setTimeout binding, used to drive the fake-timer tests.
@val external setTimeout: (unit => unit, int) => unit = "setTimeout"

// A small record whose method we can spy on. ReScript records compile to plain
// JS objects, so `Vi.spyOn` can replace the field in place.
type calculator = {add: (int, int) => int}

// Retry signal thrown by the `waitFor` callback until the condition is met.
exception NotReady

// Factory for an object with a real accessor property — ReScript records only
// compile to data properties, so getters/setters need raw JS to exist.
%%raw(`
function makeBox(initial) {
  let _v = initial
  return { get value() { return _v }, set value(x) { _v = x } }
}
`)
@val external makeBox: int => 'a = "makeBox"
@get external boxValue: 'a => int = "value"
@set external setBoxValue: ('a, int) => unit = "value"

// Readers for the stub tests: the global / env names that the tests stub.
@val external stubbedGlobal: int = "__viPhase6Global__"
@val @scope(("process", "env")) external stubbedEnv: string = "__VI_PHASE6_ENV__"

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

  test("calls and results record every invocation", () => {
    let m = Vi.fn1()
    m->Vi.MockFn.mockImplementation(x => x + 1)->ignore
    let f = m->Vi.MockFn.asFn
    f(1)->ignore
    f(2)->ignore
    expect((m->Vi.MockFn.calls)->Array.length)->toBe(2)
    expect((m->Vi.MockFn.results)->Array.length)->toBe(2)
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

  test("mockReturnValueOnce applies only to the next call", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockReturnValue(0)->ignore
    m->Vi.MockFn.mockReturnValueOnce(7)->ignore
    let f = m->Vi.MockFn.asFn
    expect(f())->toBe(7)
    expect(f())->toBe(0)
  })

  test("mockImplementationOnce overrides only the next call", () => {
    let m = Vi.fn1()
    m->Vi.MockFn.mockImplementation(x => x)->ignore
    m->Vi.MockFn.mockImplementationOnce(x => x * 10)->ignore
    let f = m->Vi.MockFn.asFn
    expect(f(2))->toBe(20)
    expect(f(2))->toBe(2)
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

describe("Vi — reset semantics", () => {
  test("mockClear resets recorded calls but keeps the implementation", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockReturnValue(5)->ignore
    (m->Vi.MockFn.asFn)()->ignore
    m->Vi.MockFn.mockClear->ignore
    m->Vi.MockFn.asAssertion->not_->toHaveBeenCalled
    // Implementation survives mockClear.
    expect((m->Vi.MockFn.asFn)())->toBe(5)
  })

  test("mockReset clears the implementation too", () => {
    let m = Vi.fn1()
    m->Vi.MockFn.mockImplementation(x => x + 1)->ignore
    m->Vi.MockFn.mockReset->ignore
    expect((m->Vi.MockFn.getMockImplementation)->Option.isNone)->toBeTruthy
  })

  test("resetAllMocks and restoreAllMocks are callable", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockReturnValue(1)->ignore
    Vi.resetAllMocks()
    Vi.restoreAllMocks()
    expect(true)->toBeTruthy
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

// Module-level flag, set by an `onTestFinished` callback in one test and
// asserted by the next test (tests run sequentially by default).
let finishedRan = ref(false)

describe("Vitest — per-test hooks", () => {
  // Regression: the hook callbacks must accept the per-test `testContext`
  // argument (binding signature `testContext => unit`), not `unit => unit`.
  test("registers onTestFinished and onTestFailed", () => {
    onTestFinished(_ctx => finishedRan := true)
    // Smoke check: registering onTestFailed in a passing test must not throw.
    onTestFailed(_ctx => ())
    expect(true)->toBeTruthy
  })

  test("onTestFinished callback ran after the previous test", () => {
    expect(finishedRan.contents)->toBeTruthy
  })
})

describe("Vi — resolve matchers", () => {
  afterEach(() => Vi.clearAllMocks())

  testAsync("toHaveResolved / toHaveResolvedWith", async () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockResolvedValue(7)->ignore
    let _ = await (m->Vi.MockFn.asFn)()
    m->Vi.MockFn.asAssertion->toHaveResolved
    m->Vi.MockFn.asAssertion->toHaveResolvedWith(7)
  })

  testAsync("toHaveResolvedTimes / Nth / Last", async () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockResolvedValueOnce(1)->ignore
    m->Vi.MockFn.mockResolvedValueOnce(2)->ignore
    let f = m->Vi.MockFn.asFn
    let _ = await f()
    let _ = await f()
    m->Vi.MockFn.asAssertion->toHaveResolvedTimes(2)
    m->Vi.MockFn.asAssertion->toHaveNthResolvedWith(1, 1)
    m->Vi.MockFn.asAssertion->toHaveLastResolvedWith(2)
  })
})

describe("Vi — waiting", () => {
  testAsync("waitFor retries until the callback stops throwing", async () => {
    let n = ref(0)
    let result = await Vi.waitFor(() => {
      n := n.contents + 1
      if n.contents < 3 {
        throw(NotReady)
      }
      n.contents
    })
    expect(result)->toBe(3)
  })

  testAsync("waitUntil resolves once the predicate is truthy", async () => {
    let n = ref(0)
    let _ = await Vi.waitUntil(() => {
      n := n.contents + 1
      n.contents >= 3
    })
    expect(n.contents)->toBe(3)
  })
})

describe("Vi — async timers & inspection", () => {
  afterEach(() => Vi.useRealTimers())

  testAsync("advanceTimersByTimeAsync fires pending timers", async () => {
    Vi.useFakeTimers()
    let fired = ref(false)
    setTimeout(() => fired := true, 1000)
    await Vi.advanceTimersByTimeAsync(1000)
    expect(fired.contents)->toBeTruthy
  })

  testAsync("runAllTimersAsync drains the queue", async () => {
    Vi.useFakeTimers()
    let fired = ref(false)
    setTimeout(() => fired := true, 5000)
    await Vi.runAllTimersAsync()
    expect(fired.contents)->toBeTruthy
  })

  testAsync("runOnlyPendingTimersAsync runs currently pending timers", async () => {
    Vi.useFakeTimers()
    let fired = ref(false)
    setTimeout(() => fired := true, 100)
    await Vi.runOnlyPendingTimersAsync()
    expect(fired.contents)->toBeTruthy
  })

  testAsync("advanceTimersToNextTimerAsync advances one timer", async () => {
    Vi.useFakeTimers()
    let fired = ref(false)
    setTimeout(() => fired := true, 100)
    await Vi.advanceTimersToNextTimerAsync()
    expect(fired.contents)->toBeTruthy
  })

  test("advanceTimersToNextFrame is callable under fake timers", () => {
    Vi.useFakeTimers()
    Vi.advanceTimersToNextFrame()
    expect(Vi.isFakeTimers())->toBeTruthy
  })

  test("isFakeTimers and getTimerCount reflect timer state", () => {
    expect(Vi.isFakeTimers())->toBeFalsy
    Vi.useFakeTimers()
    expect(Vi.isFakeTimers())->toBeTruthy
    setTimeout(() => (), 1000)
    expect(Vi.getTimerCount())->toBe(1)
  })

  test("getMockedSystemTime / getRealSystemTime", () => {
    expect((Vi.getMockedSystemTime())->Option.isNone)->toBeTruthy
    Vi.useFakeTimers()
    Vi.setSystemTimeMs(1000.0)
    expect((Vi.getMockedSystemTime())->Option.isSome)->toBeTruthy
    expect(Vi.getRealSystemTime() > 0.0)->toBeTruthy
  })
})

describe("Vi — accessor spies", () => {
  test("spyOnGetter intercepts property reads", () => {
    let box = makeBox(1)
    let spy = Vi.spyOnGetter(box, "value")
    spy->Vi.MockFn.mockReturnValue(99)->ignore
    expect(boxValue(box))->toBe(99)
    spy->Vi.MockFn.asAssertion->toHaveBeenCalled
    spy->Vi.MockFn.mockRestore->ignore
  })

  test("spyOnSetter intercepts property writes", () => {
    let box = makeBox(1)
    let spy = Vi.spyOnSetter(box, "value")
    setBoxValue(box, 5)
    spy->Vi.MockFn.asAssertion->toHaveBeenCalledWith(5)
    spy->Vi.MockFn.mockRestore->ignore
  })
})

describe("Vi — global & environment stubs", () => {
  test("stubGlobal / unstubAllGlobals", () => {
    Vi.stubGlobal("__viPhase6Global__", 123)
    expect(stubbedGlobal)->toBe(123)
    Vi.unstubAllGlobals()
  })

  test("stubEnv / unstubAllEnvs", () => {
    Vi.stubEnv("__VI_PHASE6_ENV__", "hello")
    expect(stubbedEnv)->toBe("hello")
    Vi.unstubAllEnvs()
  })
})

describe("Vi — module mocking completion", () => {
  testAsync("importActual loads the real module", async () => {
    let p: {"sep": string} = await Vi.importActual("node:path")
    expect(p["sep"]->String.length > 0)->toBeTruthy
  })

  testAsync("importMock auto-mocks module functions", async () => {
    let m: {"join": 'a} = await Vi.importMock("node:path")
    expect(Vi.isMockFunction(m["join"]))->toBeTruthy
  })

  test("mockObject replaces methods with mocks", () => {
    let obj = {"compute": () => 1}
    let mocked = Vi.mockObject(obj)
    expect(Vi.isMockFunction(mocked["compute"]))->toBeTruthy
  })

  test("doMock returns a disposable handle", () => {
    // Regression: vi.doMock returns a Disposable (typed as Vi.disposable),
    // not unit. Annotating the binding result keeps the signature honest.
    let _handle: Vi.disposable = Vi.doMock("node:path", () => {"sep": "/"})
    Vi.doUnmock("node:path")
    expect(true)->toBeTruthy
  })

  test("doUnmock is callable", () => {
    Vi.doUnmock("node:path")
    expect(true)->toBeTruthy
  })

  testAsync("dynamicImportSettled resolves", async () => {
    await Vi.dynamicImportSettled()
    expect(true)->toBeTruthy
  })
})

describe("Vi — timer tick mode", () => {
  afterEach(() => Vi.useRealTimers())

  test("setTimerTickMode is callable under fake timers", () => {
    Vi.useFakeTimers()
    Vi.setTimerTickMode("manual")
    expect(Vi.isFakeTimers())->toBeTruthy
  })

  test("setTimerTickModeWithInterval accepts an interval argument", () => {
    // Regression: the "interval" mode takes a second `interval` (ms) argument.
    Vi.useFakeTimers()
    Vi.setTimerTickModeWithInterval("interval", 50)
    expect(Vi.isFakeTimers())->toBeTruthy
  })
})
