/**
 * Dogfood tests for the `.only` modifiers. `.only` is file-scoped — any other
 * suite / test in the same file is skipped — so they live in their own file.
 * `vitest.config.js` sets `allowOnly: true` so this file also passes in CI,
 * where Vitest otherwise rejects `.only` cases.
 */
open Vitest

describeOnly("Vitest — describe.only", () => {
  testOnly("test.only runs", () => expect(1)->toBe(1))
  testOnlyAsync("test.only async runs", async () => expect(1)->toBe(1))
  itOnly("it.only runs", () => expect(1)->toBe(1))
})

describe("Vitest — sibling suite without .only", () => {
  // Skipped by Vitest because the file contains `.only` cases; it would fail if run.
  test("is skipped", () => expect(1)->toBe(2))
})
