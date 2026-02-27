import { defineConfig } from "tsup";

export default defineConfig([
  {
    entry: { "index.node": "src/index.ts" },
    format: ["cjs", "esm"],
    outDir: "dist",
    platform: "node",
    sourcemap: true,
    treeshake: true,
  },
  {
    entry: { "index.browser": "src/index.ts" },
    format: ["cjs", "esm"],
    outDir: "dist",
    platform: "browser",
    sourcemap: true,
    treeshake: true,
  },
  {
    entry: { "index.react-native": "src/index.ts" },
    format: ["esm"],
    outDir: "dist",
    platform: "browser",
    sourcemap: true,
    treeshake: true,
  },
]);
