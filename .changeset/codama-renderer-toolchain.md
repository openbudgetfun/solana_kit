---
"codama-renderers-dart": patch
---

# Update the renderer toolchain to TypeScript 7 and Vitest 5

The build and test toolchain moves to TypeScript 7.0.2, Vitest 5.0.0, `@vitest/coverage-v8` 5.0.0, and `@types/node` 26.5.1. Generated Dart output is unchanged; this is a tooling-only release.

TypeScript 6 and later no longer discover `@types` packages implicitly under `moduleResolution: "bundler"`, and they require an explicit common source directory when emitting declarations. Both projects therefore declare the Node types and the declaration root directory:

```jsonc
// tsconfig.json
{ "compilerOptions": { "types": ["node"] } }
// tsconfig.declarations.json
{ "compilerOptions": { "rootDir": "./src" } }
```

The Vitest config also sets explicit `testTimeout` and `hookTimeout` budgets. Most tests in this package shell out to `dart format`, `dart analyze`, or `dart test`, so the 5s default was already marginal for the heaviest cases.
