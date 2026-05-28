# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-28)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910)

#### Add structural equality and toString to AccountMeta, AccountLookupMeta, and Instruction

Implement `operator ==` and `hashCode` on `AccountMeta`, `AccountLookupMeta`, and `Instruction` so these core value types behave correctly in `Set`s, as `Map` keys, and in test assertions using `expect(...)`.

`AccountMeta` compares by `address` and `role`. `AccountLookupMeta` extends that to also compare `addressIndex` and `lookupTableAddress`. `Instruction` compares `programAddress`, and performs deep equality on the `accounts` list and `data` byte buffer.

All three classes also gain a `toString()` override that prints their fields, making debug output and test failure messages far more readable than the default `Instance of ...` representation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b)
