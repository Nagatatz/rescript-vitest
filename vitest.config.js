import { defineConfig } from 'vitest/config'

// The bindings are dogfooded by their own ReScript test suite. ReScript
// compiles `__tests__/**/*_test.res` to `*_test.res.js`, which Vitest runs.
export default defineConfig({
  test: {
    include: ['__tests__/**/*_test.res.js'],
    coverage: {
      provider: 'v8',
      include: ['src/**/*.res.js'],
    },
  },
})
