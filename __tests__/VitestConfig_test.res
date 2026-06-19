/**
 * Dogfood tests for the `VitestConfig` (`vitest/config`) bindings.
 *
 * `defineConfig` is effectively an identity at runtime, so we assert the config
 * object round-trips its fields, and that `mergeConfig` deep-merges nested
 * objects (overrides win, sibling keys are preserved).
 */
open Vitest

describe("VitestConfig — defineConfig", () => {
  test("passes through top-level and nested test fields", () => {
    let c = VitestConfig.defineConfig({
      test: {globals: true, environment: "node", include_: ["__tests__/**/*_test.res.js"]},
    })

    let t = c.test->Option.getOrThrow
    t.globals->expect->Vitest.toEqual(Some(true))
    t.environment->expect->Vitest.toEqual(Some("node"))
    t.include_->expect->Vitest.toEqual(Some(["__tests__/**/*_test.res.js"]))
  })

  test("reflects nested coverage config", () => {
    let c = VitestConfig.defineConfig({
      test: {coverage: {provider: "v8", enabled: true, reporter: ["text", "html"]}},
    })

    let cov = (c.test->Option.getOrThrow).coverage->Option.getOrThrow
    cov.provider->expect->Vitest.toEqual(Some("v8"))
    cov.enabled->expect->Vitest.toEqual(Some(true))
    cov.reporter->expect->Vitest.toEqual(Some(["text", "html"]))
  })

  test("omits unset optional fields from the emitted object", () => {
    let c = VitestConfig.defineConfig({test: {globals: true}})
    let t = c.test->Option.getOrThrow
    // `environment` was never set, so the optional field reads as None.
    t.environment->expect->Vitest.toEqual(None)
  })

  test("supports recursive projects entries via defineProject", () => {
    let project = VitestConfig.defineProject({test: {environment: "jsdom"}})
    let c = VitestConfig.defineConfig({test: {projects: [project]}})

    let projects = (c.test->Option.getOrThrow).projects->Option.getOrThrow
    projects->Array.length->expect->toBe(1)
    ((projects->Array.getUnsafe(0)).test->Option.getOrThrow).environment
    ->expect
    ->Vitest.toEqual(Some("jsdom"))
  })
})

describe("VitestConfig — mergeConfig", () => {
  test("deep-merges nested test config, overrides winning", () => {
    let base = VitestConfig.defineConfig({
      test: {globals: true, environment: "node"},
    })
    let override = VitestConfig.defineConfig({
      test: {environment: "jsdom"},
    })

    let merged = VitestConfig.mergeConfig(base, override)
    let t = merged.test->Option.getOrThrow
    // overridden key wins
    t.environment->expect->Vitest.toEqual(Some("jsdom"))
    // sibling key from base is preserved
    t.globals->expect->Vitest.toEqual(Some(true))
  })
})
