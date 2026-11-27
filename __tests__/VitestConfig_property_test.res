open Vitest

// Independent upstream API oracle: this name does not pass through the binding under test.
@module("vitest/config")
external upstreamMerge: (VitestConfig.config, VitestConfig.config) => VitestConfig.config =
  "mergeConfig"

let makeConfig = (present, customEnv, timeout): VitestConfig.config => {
  let nested: VitestConfig.testConfig = {
    globals: ?(present ? Some(true) : None),
    environment: ?(customEnv ? Some("jsdom") : None),
    testTimeout: ?(timeout > 0 ? Some(timeout) : None),
  }
  {test: nested}
}

test("generated merge options agree with upstream and preserve non-conflicting fields", () => {
  // Enumerate the presence bits independently of the timeout value.
  for bitset in 0 to 15 {
    let baseGlobals = mod(bitset, 2) == 1
    let baseEnvironment = mod(bitset / 2, 2) == 1
    let overrideGlobals = mod(bitset / 4, 2) == 1
    let overrideEnvironment = mod(bitset / 8, 2) == 1
    for timeout in 0 to 15 {
      let base = makeConfig(baseGlobals, baseEnvironment, 31)
      let override = makeConfig(overrideGlobals, overrideEnvironment, timeout)
      let actual = VitestConfig.mergeConfig(base, override)
      actual->expect->toEqual(upstreamMerge(base, override))
      let options = actual.test->Option.getOrThrow
      options.globals->expect->toEqual(baseGlobals || overrideGlobals ? Some(true) : None)
      options.testTimeout->expect->toEqual(Some(timeout == 0 ? 31 : timeout))
    }
  }
})
