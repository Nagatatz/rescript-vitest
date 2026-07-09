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
      test: {coverage: {provider: #v8, enabled: true, reporter: ["text", "html"]}},
    })

    let cov = (c.test->Option.getOrThrow).coverage->Option.getOrThrow
    cov.provider->expect->Vitest.toEqual(Some(#v8))
    cov.enabled->expect->Vitest.toEqual(Some(true))
    cov.reporter->expect->Vitest.toEqual(Some(["text", "html"]))
  })

  test("round-trips the remaining test fields", () => {
    let c = VitestConfig.defineConfig({
      root: "./packages/app",
      test: {
        exclude: ["**/node_modules/**"],
        setupFiles: ["./setup.js"],
        pool: "forks",
        testTimeout: 10000,
        hookTimeout: 5000,
        reporters: ["default"],
        watch: false,
        coverage: {exclude: ["**/*.config.js"]},
      },
    })

    c.root->expect->Vitest.toEqual(Some("./packages/app"))
    let t = c.test->Option.getOrThrow
    t.exclude->expect->Vitest.toEqual(Some(["**/node_modules/**"]))
    t.setupFiles->expect->Vitest.toEqual(Some(["./setup.js"]))
    // `pool` stays a plain string so custom pools remain expressible.
    t.pool->expect->Vitest.toEqual(Some("forks"))
    t.testTimeout->expect->Vitest.toEqual(Some(10000))
    t.hookTimeout->expect->Vitest.toEqual(Some(5000))
    t.reporters->expect->Vitest.toEqual(Some(["default"]))
    t.watch->expect->Vitest.toEqual(Some(false))
    (t.coverage->Option.getOrThrow).exclude->expect->Vitest.toEqual(Some(["**/*.config.js"]))
  })

  test("accepts a custom (non-builtin) environment string", () => {
    // `environment` stays a string so custom environment packages work.
    let c = VitestConfig.defineConfig({test: {environment: "happy-dom"}})
    (c.test->Option.getOrThrow).environment->expect->Vitest.toEqual(Some("happy-dom"))
  })

  test("omits unset optional fields from the emitted object", () => {
    let c = VitestConfig.defineConfig({test: {globals: true}})
    let t = c.test->Option.getOrThrow
    // `environment` was never set, so the optional field reads as None.
    t.environment->expect->Vitest.toEqual(None)
  })

  test("defineConfigFn accepts the function form (configEnv => config)", () => {
    // `defineConfig` is identity at runtime, so the function form returns the
    // closure itself. We verify the binding accepts a `configEnv => config`
    // closure and that the closure maps the resolved env to a config.
    let build = (env: VitestConfig.configEnv) =>
      VitestConfig.defineConfig({test: {globals: env.mode == "test"}})
    let _fn = VitestConfig.defineConfigFn(build)

    let produced = build({mode: "test", command: "serve"})
    (produced.test->Option.getOrThrow).globals->expect->Vitest.toEqual(Some(true))
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
