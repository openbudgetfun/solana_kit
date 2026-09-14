# Error codes

`SolanaErrorCode` numbers must match the upstream `@solana/kit` error codes. A caller comparing an error across the two SDKs compares the number, so a drifted number is a silent compatibility break rather than a cosmetic one.

## The rule

1. **A code that exists upstream uses the upstream number.** When upstream adds a code, look up its number in `.repos/kit/packages/errors/src/codes.ts` and use it verbatim. Copy the upstream message text into `messages.dart` as well.
2. **A port-only code must not occupy a number upstream uses.** Codes with no upstream counterpart go at the end of their domain's block, for example `8078999` in the codec block (`8078000`–`8078027`). Upstream allocates densely from the start of each block, so the trailing slots stay free.
3. **A port-only code gets its own domain when it has no natural home.** `8400000`-block codes are Mobile Wallet Adapter, `8600000`-block codes are Helius. Prefer deleting a port-only code that nothing throws over inventing a number for it.

## Enforcement

```bash
upstream:error-codes      # or: dart run scripts/check_error_code_parity.dart
```

The checker compares `SolanaErrorCode` against `.repos/kit/packages/errors/src/codes.ts` and fails on a number mismatch or an occupied number. It also runs as part of `docs:check`. Run `clone:repos` first so the upstream file exists; without it the checker exits with a setup error rather than passing.

Codes upstream has that this port does not are reported as a count, not a failure, because some cover JavaScript-only surfaces such as `@solana/react`.

## Current state

326 codes, 291 upstream, 6 upstream-only. The upstream-only six are `REACT__MISSING_PROVIDER`, `REACT__MISSING_CAPABILITY`, `REACT__SUBSCRIPTION_CLOSED_WITHOUT_ERROR`, `PROGRAM_CLIENTS__RESOLVED_INSTRUCTION_INPUT_MUST_BE_SIGNER`, and two `INVARIANT_VIOLATION__` codes for iterator and transaction-plan guards.

Two port-only codes sit in the codec block:

- `codecsInvalidBoolean` (`8078999`) — this port validates that a boolean is encoded as `0` or `1`; upstream does not.
- `codecsInvalidUtf8Bytes` and `codecsInvalidUtf8String` are upstream codes and use upstream's numbers, `8078026` and `8078027`. They replaced a `FormatException` that the UTF-8 codec used to raise.

## When upstream renumbers

Upstream reserves the right to change numbers in a major release. If the checker starts failing after an upstream sync, treat the renumber as a breaking change for this port: bump the affected package, and say in the changeset which codes moved and from what. Do not edit the checker's expectations to make a mismatch pass.
