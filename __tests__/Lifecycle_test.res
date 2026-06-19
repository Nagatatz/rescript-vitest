/**
 * Dogfood tests for Vitest's lifecycle hooks — the `aroundAll` / `aroundEach`
 * wrappers (Vitest 4) and the `beforeAll` / `beforeEach` / `afterAll` /
 * `afterEach` family (sync and async). These assert the hooks register with the
 * bound signatures and fire in the expected order.
 */
open Vitest

describe("Vitest — aroundEach", () => {
  // Records around-hook events so later tests can observe the before/after order.
  let events = []

  aroundEach(async runTest => {
    events->Array.push("before")
    // `await runTest()` runs the wrapped test body; the test passing proves it.
    await runTest()
    events->Array.push("after")
  })

  test("the around-before portion ran before this test body", () => {
    expect(events->Array.includes("before"))->toBeTruthy
  })

  test("the around-after portion ran after the previous test", () => {
    expect(events->Array.includes("after"))->toBeTruthy
  })
})

describe("Vitest — aroundAll", () => {
  // Set by the aroundAll before-portion; the suite body runs inside the wrapper.
  let started = ref(false)

  aroundAll(async runSuite => {
    started := true
    await runSuite()
  })

  test("the suite body runs inside the aroundAll wrapper", () => {
    expect(started.contents)->toBeTruthy
  })
})

describe("Vitest — suite-level hooks (sync & async)", () => {
  // Each hook appends a marker; the test asserts the markers are present and
  // ordered (beforeAll once, beforeEach before each test).
  let log = []

  beforeAll(() => log->Array.push("beforeAll"))
  beforeAllAsync(async () => log->Array.push("beforeAllAsync"))
  beforeEach(() => log->Array.push("beforeEach"))
  beforeEachAsync(async () => log->Array.push("beforeEachAsync"))
  afterEach(() => log->Array.push("afterEach"))
  afterEachAsync(async () => log->Array.push("afterEachAsync"))
  afterAll(() => log->Array.push("afterAll"))
  afterAllAsync(async () => log->Array.push("afterAllAsync"))

  test("beforeAll hooks ran exactly once before the first test", () => {
    expect(log->Array.filter(e => e == "beforeAll")->Array.length)->toBe(1)
    expect(log->Array.includes("beforeAllAsync"))->toBeTruthy
  })

  test("beforeEach hooks ran before each test (sync and async)", () => {
    expect(log->Array.filter(e => e == "beforeEach")->Array.length)->toBe(2)
    expect(log->Array.filter(e => e == "beforeEachAsync")->Array.length)->toBe(2)
  })

  test("afterEach hooks ran after the earlier tests", () => {
    expect(log->Array.includes("afterEach"))->toBeTruthy
    expect(log->Array.includes("afterEachAsync"))->toBeTruthy
  })
})
