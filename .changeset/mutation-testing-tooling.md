---
"solana_kit": patch
---

# Add scoped mutation testing tooling

Adds a mutation testing setup built on `mutation_test`, so the suite can be checked for tests that assert current behavior rather than the intended contract. Coverage cannot detect that failure mode: a test asserting the wrong contract still executes every line.

Four devenv tasks wrap a new driver at `scripts/run_mutation_testing.dart`:

- `mutation:list` shows the configured scopes and their sizes.
- `mutation:check` reports how completely each scope's test list covers its transitive dependents.
- `mutation:changed` runs only the scopes touched since `origin/main`.
- `mutation:run` runs a scope directly, with `--scope`, `--full`, and `--coverage` options.

Scopes live in `config/mutation/scopes.json` and pair source files with the test directories that can detect a change in them, covering the numeric codecs, transaction messages, transaction envelopes, string codecs, codec core, keys, PDAs, hashing, and the untrusted-input parsers.

A default run executes only a scope's listed tests, which costs about two seconds per mutant. Because shared packages have many dependents (`solana_kit_codecs_numbers` has 58, `solana_kit_codecs_core` has 59), a survivor in code other packages exercise can be a false positive; `--full` expands the run to every dependent so no survivor is. `mutation:check` reports the size of that gap per scope.

`config/mutation/rules.xml` replaces the builtin rule set, which is unsuitable for Dart: the builtin `<` rule also matches the first character of `<<` and the builtin argument rules reorder call arguments, so both produce mutations that fail to compile and are then reported as survivors. The rules here use lookarounds to match genuine comparisons, and exclude comments and string literals.

This is advisory tooling only. It is not wired into CI: equivalent mutants survive legitimately and would make a required check permanently red. See `docs/agents/mutation-testing.md`.
