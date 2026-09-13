import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    restoreMocks: true,
    // Most tests shell out to `dart format`, `dart analyze`, or `dart test`,
    // so the default 5s budget is exceeded whenever several files run
    // concurrently. Individual heavy tests set their own larger timeouts.
    testTimeout: 30_000,
    hookTimeout: 30_000,
  },
});
