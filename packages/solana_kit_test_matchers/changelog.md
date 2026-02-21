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

#### Implement test matchers package with Solana-specific test assertions.

**solana_kit_test_matchers** (33 tests):

- `isSolanaErrorWithCode` / `throwsSolanaErrorWithCode` for matching SolanaError by error code
- `isSolanaErrorWithCodeAndContext` for matching error code and context entries
- `isSolanaErrorMatcher` / `throwsSolanaError` for matching any SolanaError
- `equalsBytes` for byte-for-byte Uint8List comparison with detailed mismatch reporting
- `hasByteLength` / `startsWithBytes` for byte array assertions
- `isValidSolanaAddress` / `equalsAddress` for Address validation and comparison
- `isFullySignedTransactionMatcher` / `hasSignatureCount` for Transaction signature verification
