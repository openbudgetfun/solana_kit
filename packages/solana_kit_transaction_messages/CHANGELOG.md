# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct
workspace dependencies, shared analysis_options.yaml, and an empty barrel export
file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec),
  fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages,
  transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Implement transaction messages package ported from `@solana/transaction-messages`.

**solana_kit_transaction_messages** (99 tests):

- `TransactionMessage` immutable class with `TransactionVersion` (legacy, v0), fee payer, lifetime constraint, and instruction management
- `LifetimeConstraint` sealed class with `BlockhashLifetimeConstraint` and `DurableNonceLifetimeConstraint` subtypes
- Transaction message creation, fee payer setting, and instruction append/prepend
- Blockhash lifetime: validation (`isTransactionMessageWithBlockhashLifetime`), assertion, and setter
- Durable nonce lifetime: validation, assertion, and setter with automatic `AdvanceNonceAccount` instruction management
- `compileTransactionMessage`: compiles high-level messages to wire-format `CompiledTransactionMessage`
- Account compilation with correct ordering (fee payer, writable signers, readonly signers, writable non-signers, readonly non-signers)
- Address lookup table compression (`compressTransactionMessageUsingAddressLookupTables`)
- Message decompilation (`decompileTransactionMessage`) to reconstruct from compiled format
- Full codec suite: transaction version, header (3-byte), instruction, address table lookup, and complete message encoder/decoder

**solana_kit_instructions** (patch):

- `AccountLookupMeta` now extends `AccountMeta` for type compatibility in instruction accounts lists
