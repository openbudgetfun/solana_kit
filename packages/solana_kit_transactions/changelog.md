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

#### Implement transactions package ported from `@solana/transactions`.

**solana_kit_transactions** (64 tests):

- `Transaction` class with `messageBytes` (Uint8List) and `signatures` (Map<Address, SignatureBytes?>) fields
- `TransactionWithLifetime` with blockhash and durable nonce lifetime constraints
- `compileTransaction` to compile a TransactionMessage into a Transaction with signature slots and lifetime constraint
- `partiallySignTransaction` and `signTransaction` for async Ed25519 signing with key pairs
- `getSignatureFromTransaction` to extract fee payer signature
- `isFullySignedTransaction` / `assertIsFullySignedTransaction` for signature completeness checks
- Transaction size calculations with 1232-byte limit enforcement
- `isSendableTransaction` / `assertIsSendableTransaction` combining signature and size checks
- Wire format encoding with `getBase64EncodedWireTransaction`
- Full transaction codec: signatures encoder (shortU16 prefix + 64 bytes each), transaction encoder/decoder

### Fixes

#### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements
