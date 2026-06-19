/**
 * Dogfood tests for the `expect` matchers.
 *
 * These both prove the bindings type-check and serve as runnable examples.
 */
open Vitest

// A thunk that throws, used to exercise the exception matchers.
exception Boom

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

describe("Expect — exceptions", () => {
  test("toThrow", () => {
    expect(() => throw(Boom))->toThrow
  })

  test("toThrow with a message", () => {
    expect(() => JsError.throw(JsError.make("kaboom")))->toThrowWithMessage("kaboom")
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
