/**
 * VitestConfig — type-safe ReScript bindings for the `vitest/config` entry.
 *
 * This module types the configuration side of Vitest (the `defineConfig` /
 * `mergeConfig` helpers and the `test` config object), complementing the
 * test-runtime bindings in `Vitest.res` / `Vi.res`.
 *
 * Scope is intentionally minimal: only the most commonly used `test` fields are
 * typed. Full Vite-level configuration (`plugins`, `resolve`, `server`, `build`,
 * …) and the long tail of `test` options are deliberately NOT bound — author
 * those in a plain JS config file instead. See the project plan for the
 * rationale (config objects are write-once data with a large, churning surface).
 *
 * Usage:
 *
 *   let config = VitestConfig.defineConfig({
 *     test: {globals: true, environment: "node"},
 *   })
 *
 * To use the result as the actual `vitest.config`, add a thin JS shim, since
 * ReScript does not emit `export default`:
 *
 *   // vitest.config.js
 *   import {config} from "./MyConfig.res.js"
 *   export default config
 *
 * Notes:
 * - Records use ReScript's optional fields (`field?: ...`); unset fields are
 *   omitted from the emitted JS object, matching how Vitest reads config.
 * - Vitest 4 folds workspace setups into `test.projects`; the legacy
 *   `defineWorkspace` helper is out of scope.
 */

/**
 * Code-coverage configuration (`test.coverage`). Only the most common fields are
 * typed; `provider` selects the engine (`"v8"` | `"istanbul"`).
 */
type coverageConfig = {
  provider?: string,
  enabled?: bool,
  reporter?: array<string>,
  // `include` is a ReScript keyword; map the field to JS "include" via @as.
  @as("include") include_?: array<string>,
  exclude?: array<string>,
}

/**
 * The `test` configuration object — the Vitest-specific portion of the config.
 * `projects` references `config` recursively (Vitest 4 workspace projects).
 */
type rec testConfig = {
  globals?: bool,
  environment?: string,
  // `include` is a ReScript keyword; map the field to JS "include" via @as.
  @as("include") include_?: array<string>,
  exclude?: array<string>,
  setupFiles?: array<string>,
  coverage?: coverageConfig,
  pool?: string,
  testTimeout?: int,
  hookTimeout?: int,
  reporters?: array<string>,
  watch?: bool,
  projects?: array<config>,
}

/**
 * A Vitest user config. Only `test` and the Vite-level `root` are typed here;
 * other Vite-level fields are out of scope (use a JS config file for those).
 */
and config = {
  test?: testConfig,
  root?: string,
}

/**
 * The environment passed to the function form of `defineConfig`:
 * `mode` (e.g. "test"/"production") and `command` (e.g. "serve"/"build").
 */
type configEnv = {
  mode: string,
  command: string,
}

/** Identity-like helper that returns a typed config object for Vitest to read. */
@module("vitest/config")
external defineConfig: config => config = "defineConfig"

/**
 * Function form of `defineConfig`: receives the resolved `configEnv` and returns
 * a config, enabling mode/command-dependent settings.
 */
@module("vitest/config")
external defineConfigFn: (configEnv => config) => config = "defineConfig"

/**
 * Deep-merge two configs. `defaults` provides the base, `overrides` wins on
 * conflicts (nested objects are merged, not replaced).
 */
@module("vitest/config")
external mergeConfig: (config, config) => config = "mergeConfig"

/**
 * Type a single entry of `test.projects`. Behaves like `defineConfig` but is the
 * idiomatic helper for project-level configuration.
 */
@module("vitest/config")
external defineProject: config => config = "defineProject"
