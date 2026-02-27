# Changelog

All notable changes to this package will be documented in this file.

## 0.2.0 (2026-02-27)

### Breaking Changes

#### Initial Release

The initial release of all libraries.

### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for address and signer packages.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

## 0.1.0 (2026-02-21)

### Notes

- First 0.1.0 release of this package.

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

#### Implement signers package ported from `@solana/signers`.

**solana_kit_signers** (88 tests):

- Five core signer interfaces: `MessagePartialSigner`, `MessageModifyingSigner`, `TransactionPartialSigner`, `TransactionModifyingSigner`, `TransactionSendingSigner`
- Composite types: `MessageSigner`, `TransactionSigner`, `KeyPairSigner` with Ed25519 signing
- `NoopSigner` for adding signature slots without actual signing
- `partiallySignTransactionMessageWithSigners` and `signTransactionMessageWithSigners` for signing transaction messages using attached signers
- `signAndSendTransactionMessageWithSigners` for combined sign-and-send workflow
- Signer extraction from instructions and transaction messages via account meta
- Fee payer signer utilities
- Signer deduplication and assertion helpers
