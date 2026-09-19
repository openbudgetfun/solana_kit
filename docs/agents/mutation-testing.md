# Mutation testing

Coverage tells you a line ran. Mutation testing tells you whether a test would have _noticed_ if that line were wrong. It rewrites the source in small ways — flipping a comparison, changing a bound, swapping an operator — and reports how many of those changes the suite catches.

This repo uses [`mutation_test`](https://pub.dev/packages/mutation_test), a language-agnostic mutation runner. It is a Rust `cargo-mutants` equivalent, not a Dart-specific tool, which shapes how the configuration below is written.

## Why it matters here

A test can assert current behavior instead of intended behavior and still pass forever. That failure mode is real in this codebase: a decoder test once asserted `throwsRangeError` for truncated input, which turned a missing byte-length guard into a "verified" invariant and hid the defect until an adversarial harness found it. Coverage could not see the problem, because the line was fully executed.

Mutation testing is the tool that catches this class of defect, because a test asserting the wrong contract kills fewer mutants than one asserting the right one.

## Running it

```bash
mutation:list                    # what can be mutated, and how big each scope is
mutation:check                   # how well each scope's tests cover its dependents
mutation:changed                 # scopes touched since origin/main
mutation:run --scope keys        # one scope
mutation:run --scope keys --full # authoritative, much slower
```

Reports land in `coverage/mutation/<scope>/mutation-test-report.html`. The HTML report shows each source line with its surviving mutants marked, which is the part worth reading; the console summary is only a score.

## Scopes and the accuracy trade-off

`config/mutation/scopes.json` pairs source files with the test directories that can detect a change in them. Two dials matter:

**Default (partial) run.** Only the scope's listed tests run, roughly 2 seconds per mutant. Survivors in code that other packages exercise may be false positives.

**`--full` run.** Every transitive dependent's tests run, so no survivor is a false positive. This is authoritative but costs the workspace test time, roughly 75 seconds per mutant.

The gap is not hypothetical. `solana_kit_codecs_numbers` has 58 transitive dependents, and `solana_kit_codecs_core` has 59. Verifying a mutant in either means running most of the workspace.

How to choose:

- Use the default run while iterating. Read survivors as leads, not verdicts.
- Use `--full` before acting on a survivor that would change code, and before trusting a high kill rate as evidence of test quality.
- `mutation:check` prints, per scope, how many dependents fall outside the test list, so you know how much the default run is leaving out.

The counter-example worth remembering: an encoder offset mutant survived a default run of `codecs_numbers` and looked alarming, but applying it by hand and running three dependent packages killed it 11 times over. The scope, not the tests, was the problem.

## Rules

`config/mutation/rules.xml` defines the mutations. It replaces the builtin rule set, which is unsuitable here:

- The builtin `<` rule also matches the first character of `<<`, turning a bitshift into `< <=`, which is not valid Dart. Every such mutant "survives" because the test process fails to compile and returns non-zero for the wrong reason. The rules here use lookarounds to match only genuine comparisons.
- Builtin argument-reordering rules produce swapped calls that frequently fail to compile, with the same false-survivor effect.
- Builtin rules mutate generic type annotations and doc comments, which no test can kill.

Comments and single-quoted string literals are excluded. Constants like `32` are worth mutating as field widths (`size: 32`), but the same digits appear inside codec names such as `'u32'`, and renaming a description changes only an error message no test should assert on.

## Reading a report honestly

Not every survivor is a gap. Three categories appear, and only the first is actionable:

**Real gap.** A test is missing or asserts too little. Fix the test. A common shape here is asserting an error _code_ but not its _context_: mutating `'max': 65535` to `32767` survives when the test only checks `SolanaErrorCode.codecsNumberOutOfRange`. Those context fields are what a developer reads when a decode fails, so they are worth pinning.

**Equivalent mutant.** The mutation cannot be distinguished from the original by any input. `if (shift > 14)` mutating to `shift > 21` is one example: the overflow check on the next line already rejects those inputs, so no test can kill it. Correct, expected, and not worth chasing.

**Tool artifact.** The rewrite produced something that is not valid Dart, or touched a string or comment. The exclusions and custom rules remove most of these, but a new rule may reintroduce them. If survivors cluster on lines that look like noise, tighten `rules.xml`.

## What not to do

**Do not make this a required CI check yet.** Equivalent mutants survive by nature, so a hard gate would be red without anyone able to make it green. The task is advisory: it reports a rating and exits zero.

**Do not run it workspace-wide.** `untrusted_parsers` alone is 4,341 lines, and the tool runs mutants serially. Start from a scope and a `--changed` run.

**Do not treat a 100% kill rate as proof of correctness.** Mutation testing measures test sensitivity against the mutations the rules happen to generate. It cannot report a behavior nothing tests and no rule mutates.

## Adding a scope

Add an entry to `config/mutation/scopes.json` with `note`, `source`, and `tests`, then run `mutation:check`. Keep `note` specific: it is what tells the next reader which defect the scope is protecting against. Prefer several narrow scopes over one broad scope, because the cost of a run scales with the tests it executes.

If you add a package whose source another package depends on, `mutation:check` will report the new dependent as outside the scope's test list. That is a decision to make consciously: add it for accuracy, or accept the caveat knowingly.
