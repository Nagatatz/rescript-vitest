import { defineConfig } from "vitest/config";

// The bindings are dogfooded by their own ReScript test suite. ReScript
// compiles `__tests__/**/*_test.res` to `*_test.res.js`, which Vitest runs.
export default defineConfig({
  test: {
    include: ["__tests__/**/*_test.res.js"],
    // `__tests__/Only_test.res` dogfoods the `.only` modifiers; Vitest rejects
    // `.only` in CI unless this is set.
    allowOnly: true,
    coverage: {
      provider: "v8",
      include: ["src/**/*.res.js"],
    },
  },
});
