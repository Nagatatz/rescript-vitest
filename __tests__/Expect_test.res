/**
 * Dogfood tests for the `expect` matchers.
 *
 * These both prove the bindings type-check and serve as runnable examples.
 */
open Vitest

// A thunk that throws, used to exercise the exception matchers.
exception Boom

// The JS `Error` constructor, used to exercise `toBeInstanceOf`.
@val external errorClass: 'a = "Error"

// JS constructors used to exercise `Expect.any`.
@val external stringClass: 'a = "String"
@val external numberClass: 'a = "Number"

describe("Expect — equality", () => {
  test("toBe compares by identity", () => {
    expect(1 + 1)->toBe(2)
    expect("a" ++ "b")->toBe("ab")
  })

  test("toEqual compares structurally", () => {
    expect([1, 2, 3])->toEqual([1, 2, 3])
    expect((1, "x"))->toEqual((1, "x"))
  })

  test("not_ negates", () => {
    expect(1)->not_->toBe(2)
    expect([1])->not_->toEqual([2])
  })
})

describe("Expect — truthiness & numbers", () => {
  test("truthiness", () => {
    expect(true)->toBeTruthy
    expect(0)->toBeFalsy
    expect(Null.null)->toBeNull
  })

  test("comparisons", () => {
    expect(5)->toBeGreaterThan(3)
    expect(5)->toBeGreaterThanOrEqual(5)
    expect(2)->toBeLessThan(3)
    expect(3.14159)->toBeCloseTo(3.14)
    expect(3.14159)->toBeCloseToWithDigits(3.1416, 4)
  })
})

describe("Expect — strings & collections", () => {
  test("strings", () => {
    expect("hello world")->toContainString("world")
    expect("hello")->toMatch("ell")
    expect("hello")->toMatchRegExp(%re("/^h.*o$/"))
  })

  test("collections", () => {
    expect([1, 2, 3])->toContain(2)
    expect([1, 2, 3])->toHaveLength(3)
    expect([{"id": 1}])->toContainEqual({"id": 1})
  })

  test("objects", () => {
    expect({"a": 1, "b": 2})->toMatchObject({"a": 1})
    expect({"a": 1})->toHaveProperty("a")
    expect({"a": 1})->toHavePropertyValue("a", 1)
  })
})

describe("Expect — type & predicate matchers", () => {
  test("toBeTypeOf matches the runtime typeof", () => {
    expect("hi")->toBeTypeOf("string")
    expect(42)->toBeTypeOf("number")
  })

  test("toBeInstanceOf checks the constructor", () => {
    expect(JsError.make("boom"))->toBeInstanceOf(errorClass)
  })

  test("toBeOneOf checks membership in candidates", () => {
    expect(2)->toBeOneOf([1, 2, 3])
  })

  test("toSatisfy applies a predicate", () => {
    expect(4)->toSatisfy(x => x > 3)
  })
})

describe("Expect — exceptions", () => {
  test("toThrow", () => {
    expect(() => throw(Boom))->toThrow
  })

  test("toThrow with a message", () => {
    expect(() => JsError.throw(JsError.make("kaboom")))->toThrowWithMessage("kaboom")
  })
})

describe("Expect — mock call-argument matchers", () => {
  afterEach(() => Vi.clearAllMocks())

  test("toHaveBeenCalledWith matches a single argument", () => {
    let m = Vi.fn1()
    (m->Vi.MockFn.asFn)("hi")->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenCalledWith("hi")
  })

  test("toHaveBeenCalledWith2 matches two arguments", () => {
    let m = Vi.fn2()
    (m->Vi.MockFn.asFn)(1, 2)->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenCalledWith2(1, 2)
  })

  test("toHaveBeenLastCalledWith inspects the most recent call", () => {
    let m = Vi.fn1()
    let f = m->Vi.MockFn.asFn
    f("a")->ignore
    f("b")->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenLastCalledWith("b")
  })

  test("toHaveBeenNthCalledWith inspects a call by index", () => {
    let m = Vi.fn1()
    let f = m->Vi.MockFn.asFn
    f("x")->ignore
    f("y")->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenNthCalledWith(1, "x")

    let m2 = Vi.fn2()
    let g = m2->Vi.MockFn.asFn
    g(1, 2)->ignore
    g(3, 4)->ignore
    m2->Vi.MockFn.asAssertion->toHaveBeenNthCalledWith2(2, 3, 4)
  })

  test("toHaveBeenCalledExactlyOnceWith requires a single matching call", () => {
    let m = Vi.fn1()
    (m->Vi.MockFn.asFn)("only")->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenCalledExactlyOnceWith("only")

    let m2 = Vi.fn2()
    (m2->Vi.MockFn.asFn)(1, 2)->ignore
    m2->Vi.MockFn.asAssertion->toHaveBeenCalledExactlyOnceWith2(1, 2)
  })
})

describe("Expect — mock return-value matchers", () => {
  afterEach(() => Vi.clearAllMocks())

  test("toHaveReturnedTimes counts successful returns", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockReturnValue(1)->ignore
    let f = m->Vi.MockFn.asFn
    f()->ignore
    f()->ignore
    m->Vi.MockFn.asAssertion->toHaveReturnedTimes(2)
  })

  test("toHaveReturnedWith matches a returned value", () => {
    let m = Vi.fn0()
    m->Vi.MockFn.mockReturnValue(7)->ignore
    (m->Vi.MockFn.asFn)()->ignore
    m->Vi.MockFn.asAssertion->toHaveReturnedWith(7)
  })

  test("toHaveLastReturnedWith / toHaveNthReturnedWith inspect returns by position", () => {
    let m = Vi.fn1()
    m->Vi.MockFn.mockImplementation(x => x * 2)->ignore
    let f = m->Vi.MockFn.asFn
    f(3)->ignore
    f(5)->ignore
    m->Vi.MockFn.asAssertion->toHaveNthReturnedWith(1, 6)
    m->Vi.MockFn.asAssertion->toHaveLastReturnedWith(10)
  })
})

describe("Expect — async", () => {
  testAsync("resolves", async () => {
    await expect(Promise.resolve(42))->resolves->Async.toBe(42)
  })

  testAsync("rejects", async () => {
    await expect(Promise.reject(Boom))->rejects->Async.toThrow
  })
})

describe("Vitest — test modifiers", () => {
  // The skipped branches carry a body that would fail if it ran.
  testSkipIf(true)("skipped when the condition is true", () => expect(1)->toBe(2))
  testSkipIf(false)("runs when the condition is false", () => expect(1)->toBe(1))
  testRunIf(true)("runs when the condition is true", () => expect(1)->toBe(1))
  testRunIf(false)("skipped when the condition is false", () => expect(1)->toBe(2))

  // `fails` inverts the result: these pass *because* the body throws.
  testFails("passes because the body fails", () => expect(1)->toBe(2))
  testFailsAsync("passes because the async body fails", async () => expect(1)->toBe(2))

  testSequential("runs sequentially", () => expect(1)->toBe(1))
  testSequentialAsync("runs sequentially (async)", async () => expect(1)->toBe(1))
})

describeConcurrent("Vitest — describe.concurrent", () => {
  test("runs inside a concurrent suite", () => expect(1)->toBe(1))
})

describeSequential("Vitest — describe.sequential", () => {
  test("runs inside a sequential suite", () => expect(1)->toBe(1))
})

describeShuffle("Vitest — describe.shuffle", () => {
  test("runs inside a shuffled suite", () => expect(1)->toBe(1))
})

describeTodo("Vitest — describe.todo suite")

describeSkipIf(true)("Vitest — describe.skipIf (skipped)", () => {
  test("would fail but the suite is skipped", () => expect(1)->toBe(2))
})
describeSkipIf(false)("Vitest — describe.skipIf (running)", () => {
  test("runs", () => expect(1)->toBe(1))
})

describeRunIf(true)("Vitest — describe.runIf (running)", () => {
  test("runs", () => expect(1)->toBe(1))
})
describeRunIf(false)("Vitest — describe.runIf (skipped)", () => {
  test("would fail but the suite is skipped", () => expect(1)->toBe(2))
})

describeFor([1, 2, 3])("Vitest — describe.for case %i", n => {
  test("the case value is positive", () => expect(n > 0)->toBeTruthy)
})

describe("Expect — asymmetric matchers", () => {
  afterEach(() => Vi.clearAllMocks())

  test("anything matches any present value", () => {
    expect({"id": 1, "name": "a"})->toEqual({"id": Expect.anything(), "name": "a"})
  })

  test("any matches by constructor", () => {
    expect("hello")->toEqual(Expect.any(stringClass))
    expect(42)->toEqual(Expect.any(numberClass))
  })

  test("arrayContaining matches a subset", () => {
    expect([1, 2, 3])->toEqual(Expect.arrayContaining([1, 2]))
  })

  test("objectContaining matches a subset", () => {
    expect({"a": 1, "b": 2})->toEqual(Expect.objectContaining({"a": 1}))
  })

  test("stringContaining / stringMatching match patterns", () => {
    expect("hello world")->toEqual(Expect.stringContaining("world"))
    expect("hello123")->toEqual(Expect.stringMatching("[0-9]+"))
    expect("hello")->toEqual(Expect.stringMatchingRegExp(%re("/^h/")))
  })

  test("closeTo matches approximate numbers", () => {
    expect(2.004)->toEqual(Expect.closeTo(2.0))
    expect(2.0049)->toEqual(Expect.closeToWithPrecision(2.0, 2))
  })

  test("embeds inside toHaveBeenCalledWith", () => {
    let m = Vi.fn1()
    (m->Vi.MockFn.asFn)("hello world")->ignore
    m->Vi.MockFn.asAssertion->toHaveBeenCalledWith(Expect.stringContaining("world"))
  })
})

describe("Vitest — test.for", () => {
  testFor([1, 2, 3])("for-case %i is positive", n => expect(n > 0)->toBeTruthy)
})

describe("Expect — assertion guards, soft, poll, unreachable", () => {
  test("assertions counts the assertions that ran", () => {
    Expect.assertions(1)
    expect(1)->toBe(1)
  })

  test("hasAssertions requires at least one assertion", () => {
    Expect.hasAssertions()
    expect(true)->toBeTruthy
  })

  test("soft collects failures without aborting", () => {
    Expect.soft(1)->toBe(1)
    Expect.soft("a")->toBe("a")
  })

  testAsync("poll retries until the matcher passes", async () => {
    let n = ref(0)
    await Expect.poll(() => {
      n := n.contents + 1
      n.contents
    })->Async.toBe(3)
  })

  test("unreachable throws when executed", () => {
    expect(() => Expect.unreachable())->toThrow
    expect(() => Expect.unreachableWithMessage("should not happen"))->toThrow
  })
})

describe("Expect — negated asymmetric matchers", () => {
  test("Not.arrayContaining / objectContaining", () => {
    expect([1, 2, 3])->toEqual(Expect.Not.arrayContaining([9]))
    expect({"a": 1})->toEqual(Expect.Not.objectContaining({"b": 2}))
  })

  test("Not.stringContaining / stringMatching", () => {
    expect("hello")->toEqual(Expect.Not.stringContaining("xyz"))
    expect("hello")->toEqual(Expect.Not.stringMatching("[0-9]"))
    expect("hello")->toEqual(Expect.Not.stringMatchingRegExp(%re("/[0-9]/")))
  })

  test("Not.closeTo", () => {
    expect(2.5)->toEqual(Expect.Not.closeTo(2.0))
    expect(2.5)->toEqual(Expect.Not.closeToWithPrecision(2.0, 2))
  })
})

describe("Vitest — it modifiers", () => {
  itEach([1, 2])("it-each case %i is positive", n => expect(n > 0)->toBeTruthy)
  itFails("it.fails passes because the body fails", () => expect(1)->toBe(2))
  itSequential("it.sequential runs", () => expect(1)->toBe(1))
  itSkipIf(true)("it.skipIf skips when true", () => expect(1)->toBe(2))
  itRunIf(false)("it.runIf skips when false", () => expect(1)->toBe(2))
  itTodo("it.todo placeholder")
  itConcurrent("it.concurrent runs", async () => expect(1)->toBe(1))
})

describe("Vitest — async conditional tests", () => {
  testSkipIfAsync(true)("async test skipped when condition is true", async () => expect(1)->toBe(2))
  testRunIfAsync(true)("async test runs when condition is true", async () => expect(1)->toBe(1))
})

describe("Expect — file snapshot", () => {
  testAsync("toMatchFileSnapshot writes/compares an external snapshot", async () => {
    await expect("file snapshot content\n")->toMatchFileSnapshot("./__file_snapshots__/sample.txt")
  })
})
