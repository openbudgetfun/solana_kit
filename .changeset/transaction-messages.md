---
solana_kit_transaction_messages: minor
solana_kit_instructions: patch
---

Implement transaction messages package ported from `@solana/transaction-messages`.

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
