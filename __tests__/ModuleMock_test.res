/**
 * Dogfood tests for `Vi.mockWithFactory` / `Vi.unmock`. They live in their own
 * file because `vi.mock` affects every later import of the module in the file:
 * the mock is registered at module top level, and the tests observe it through
 * dynamic imports (which resolve after the registration either way, hoisted
 * or not).
 */
open Vitest

/** Dynamic `import()`, so each test controls when the module is resolved. */
let dynImport: string => promise<{"platform": unit => string}> = %raw("(m) => import(m)")

// Replace `node:os` with a factory result for later imports in this file.
Vi.mockWithFactory("node:os", () => {"platform": () => "mocked-os"})

describe("Vi — vi.mock with a factory and vi.unmock", () => {
  testAsync("mockWithFactory replaces the module with the factory result", async () => {
    let os = await dynImport("node:os")
    expect(os["platform"]())->toBe("mocked-os")
  })

  testAsync("unmock restores the real module for later imports", async () => {
    Vi.unmock("node:os")
    // Drop the cached mocked instance so the next import re-resolves.
    Vi.resetModules()
    let os = await dynImport("node:os")
    expect(os["platform"]())->not_->toBe("mocked-os")
  })
})
