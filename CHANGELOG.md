# Changelog

Consolidated changelog for all workspace packages and renderers.

## solana_kit

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for codec and umbrella packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement umbrella package re-exporting all Solana Kit Dart SDK packages.

**solana_kit** (10 tests):

- Re-exports all 28 public packages from the SDK (accounts, addresses, codecs, errors, instructions, keys, rpc, signers, transactions, etc.)
- `getMinimumBalanceForRentExemption` helper computing rent exemption without RPC call
- Handles ambiguous exports with explicit `hide` directives for conflicting names

#### Fixes

- Validate quickstart.md code examples against actual implemented APIs and mark all 136 spec tasks as complete.

---

## solana_kit_accounts

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for address and signer packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement accounts package ported from `@solana/accounts`.

**solana_kit_accounts** (45 tests):

- `Account<TData>` and `BaseAccount` with owner, lamports, executable, rentEpoch fields
- `EncodedAccount` typedef for base64-encoded account data
- `MaybeAccount<TData>` sealed class: `ExistingAccount` and `NonExistingAccount` variants
- `assertAccountExists()` and `assertAccountsExist()` for null-safe account unwrapping
- `parseBase64RpcAccount()`, `parseBase58RpcAccount()`, `parseJsonRpcAccount()` parsers
- `decodeAccount()`, `decodeMaybeAccount()` with codec-based data decoding
- `assertAccountDecoded()`, `assertAccountsDecoded()` for decoded type assertions
- `fetchEncodedAccount()`, `fetchEncodedAccounts()` via RPC `getAccountInfo`/`getMultipleAccounts`
- `fetchJsonParsedAccount()`, `fetchJsonParsedAccounts()` for JSON-parsed account data

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

---

## solana_kit_addresses

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for address and signer packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement addresses and keys packages ported from `@solana/addresses` and `@solana/keys`.

**solana_kit_addresses** (65 tests):

- `Address` extension type wrapping validated base58-encoded 32-byte strings
- Address codec (`getAddressEncoder`/`getAddressDecoder`/`getAddressCodec`) for 32-byte fixed-size encoding
- Address comparator with base58 collation rules matching Solana runtime ordering
- Ed25519 curve checking (`compressedPointBytesAreOnCurve`, `isOnCurveAddress`, `isOffCurveAddress`)
- PDA derivation (`getProgramDerivedAddress`) with SHA-256, bump seed search, and seed validation
- `createAddressWithSeed` for deterministic address derivation
- Public key to/from address conversion utilities

**solana_kit_keys** (36 tests):

- `Signature` and `SignatureBytes` extension types for Ed25519 signatures
- Key pair generation, creation from bytes, and creation from private key bytes
- Ed25519 sign/verify operations using `ed25519_edwards` package
- Signature validation (string length, byte length, base58 decoding)
- Private key validation and public key derivation

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

---

## solana_kit_codecs

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for codec and umbrella packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement options package and codecs umbrella re-export.

**solana_kit_options** (90 tests):

- Rust-like `Option<T>` sealed class with `Some<T>` and `None<T>` subclasses
- Option codec with 6 encoding modes: prefix-based, zeroes, custom none value, combined prefix+zeroes, combined prefix+custom, and absence-based detection
- `unwrapOption()` and `unwrapOptionOr()` for extracting values with fallback
- `wrapNullable()` for converting `T?` to `Option<T>`
- `unwrapOptionRecursively()` for deep unwrapping of nested Options in Maps/Lists

**solana_kit_codecs** (umbrella):

- Re-exports all codec sub-packages: core, numbers, strings, data structures
- Re-exports options package (matching TypeScript `@solana/codecs` behavior)

---

## solana_kit_codecs_core

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for foundational utility packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement `solana_kit_codecs_core` and `solana_kit_codecs_numbers` packages, ported

from `@solana/codecs-core` and `@solana/codecs-numbers` in the TypeScript SDK.

**solana_kit_codecs_core** provides the foundational codec interfaces and utilities:

- Sealed class hierarchy: `Encoder<T>`, `Decoder<T>`, `Codec<TFrom, TTo>` with fixed-size and variable-size variants
- Composition utilities: `combineCodec`, `transformCodec`, `fixCodecSize`, `reverseCodec`, `addCodecSentinel`, `addCodecSizePrefix`, `offsetCodec`, `padCodec`, `resizeCodec`
- Byte utilities: `mergeBytes`, `padBytes`, `fixBytes`, `containsBytes`
- Assertion helpers for byte array validation
- 135 tests covering all codec operations

**solana_kit_codecs_numbers** provides number encoding/decoding:

- Integer codecs: u8, i8, u16, i16, u32, i32, u64, i64, u128, i128
- Float codecs: f32, f64
- Variable-size shortU16 codec (Solana compact encoding)
- Configurable endianness (little-endian default, big-endian option)
- BigInt support for 64-bit and 128-bit integers
- 152 tests including exhaustive shortU16 roundtrip validation

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## solana_kit_codecs_data_structures

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for codec and umbrella packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement codecs_strings and codecs_data_structures packages ported from the

TypeScript `@solana/codecs-strings` and `@solana/codecs-data-structures`.

**codecs_strings** (15 tests):

- UTF-8 codec using dart:convert with null character stripping
- Base16 (hex) codec with optimized nibble conversion
- Base58 codec using BigInt arithmetic for Solana address encoding
- Base64 codec tolerant of missing padding (matches Node.js behavior)
- Base10 codec for decimal string encoding
- Generic baseX codec for arbitrary alphabets
- BaseX reslice codec for power-of-2 bases using bit accumulator

**codecs_data_structures** (90 tests):

- Unit (void), boolean, and raw bytes codecs
- Array codec with prefix/fixed/remainder sizing (sealed ArrayLikeCodecSize)
- Tuple codec for heterogeneous fixed-length lists
- Struct codec using Map<String, Object?> for named fields
- Map and Set codecs built on array internals
- Nullable codec with configurable none representation (sealed NoneValue)
- Bit array codec with forward/backward bit ordering
- Constant, hidden prefix, and hidden suffix codecs
- Union, discriminated union, and literal union codecs

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## solana_kit_codecs_numbers

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for codec and umbrella packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement `solana_kit_codecs_core` and `solana_kit_codecs_numbers` packages, ported

from `@solana/codecs-core` and `@solana/codecs-numbers` in the TypeScript SDK.

**solana_kit_codecs_core** provides the foundational codec interfaces and utilities:

- Sealed class hierarchy: `Encoder<T>`, `Decoder<T>`, `Codec<TFrom, TTo>` with fixed-size and variable-size variants
- Composition utilities: `combineCodec`, `transformCodec`, `fixCodecSize`, `reverseCodec`, `addCodecSentinel`, `addCodecSizePrefix`, `offsetCodec`, `padCodec`, `resizeCodec`
- Byte utilities: `mergeBytes`, `padBytes`, `fixBytes`, `containsBytes`
- Assertion helpers for byte array validation
- 135 tests covering all codec operations

**solana_kit_codecs_numbers** provides number encoding/decoding:

- Integer codecs: u8, i8, u16, i16, u32, i32, u64, i64, u128, i128
- Float codecs: f32, f64
- Variable-size shortU16 codec (Solana compact encoding)
- Configurable endianness (little-endian default, big-endian option)
- BigInt support for 64-bit and 128-bit integers
- 152 tests including exhaustive shortU16 roundtrip validation

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## solana_kit_codecs_strings

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for codec and umbrella packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement codecs_strings and codecs_data_structures packages ported from the

TypeScript `@solana/codecs-strings` and `@solana/codecs-data-structures`.

**codecs_strings** (15 tests):

- UTF-8 codec using dart:convert with null character stripping
- Base16 (hex) codec with optimized nibble conversion
- Base58 codec using BigInt arithmetic for Solana address encoding
- Base64 codec tolerant of missing padding (matches Node.js behavior)
- Base10 codec for decimal string encoding
- Generic baseX codec for arbitrary alphabets
- BaseX reslice codec for power-of-2 bases using bit accumulator

**codecs_data_structures** (90 tests):

- Unit (void), boolean, and raw bytes codecs
- Array codec with prefix/fixed/remainder sizing (sealed ArrayLikeCodecSize)
- Tuple codec for heterogeneous fixed-length lists
- Struct codec using Map<String, Object?> for named fields
- Map and Set codecs built on array internals
- Nullable codec with configurable none representation (sealed NoneValue)
- Bit array codec with forward/backward bit ordering
- Constant, hidden prefix, and hidden suffix codecs
- Union, discriminated union, and literal union codecs

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## solana_kit_errors

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for foundational utility packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial release of the error handling foundation package. Implements the complete

Solana error system ported from `@solana/errors` in the TypeScript SDK:

- `SolanaError` class with numeric error codes and typed context maps
- `SolanaErrorCode` with 200+ categorized error constants covering addresses, accounts, codecs, crypto, instructions, keys, RPC, signers, transactions, and invariant violations
- Error message templates with `$variable` interpolation for all error codes
- JSON-RPC error conversion with preflight failure unwrapping
- Instruction error mapping for all 54 Solana runtime instruction errors
- Transaction error mapping for all 37 Solana runtime transaction errors
- Simulation error unwrapping for preflight and compute limit estimation
- Context encoding/decoding via base64 URL-safe serialization
- Comprehensive test suite with 7 test files covering all conversion paths

#### Fixes

##### Add `solana_kit_helius` package — a Dart port of the Helius TypeScript SDK.

Provides 12 sub-clients: DAS API, Priority Fees, RPC V2, Enhanced Transactions, Webhooks, ZK Compression, Smart Transactions, Staking, Wallet API, WebSockets, and Auth. Includes 150 unit tests across 80 test files.

Adds 6 Helius-specific error codes (8600000–8600005) to `solana_kit_errors`.

##### Add Mobile Wallet Adapter packages for Solana.

**solana_kit_mobile_wallet_adapter_protocol**: Pure Dart MWA v2.0 protocol with P-256 ECDH/ECDSA, AES-128-GCM encryption, HKDF-SHA256, HELLO handshake, JSON-RPC messaging, association URIs, SIWS, and JWS.

**solana_kit_mobile_wallet_adapter**: Flutter plugin for Android MWA with `transact()`, local/remote association scenarios, wallet-side callbacks, Kit-integrated typed APIs, and platform method channels.

Adds 20 MWA-specific error codes (8400000-8400105) to `solana_kit_errors`.

---

## solana_kit_fast_stable_stringify

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for foundational utility packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement foundation utility packages ported from the `@solana/functional` and

`@solana/fast-stable-stringify` TypeScript packages.

**solana_kit_functional**: Adds the `Pipe` extension which provides a `.pipe()` method on any value for composable functional pipelines. This is the idiomatic Dart equivalent of the TS `pipe()` function, used extensively for building transaction messages. Includes 28 tests covering single/multiple transforms, type changes, object mutation, combining, nested pipes, and error propagation.

**solana_kit_fast_stable_stringify**: Adds `fastStableStringify()` for deterministic JSON serialization with sorted object keys. Handles all Dart primitives, BigInt (serialized as `<value>n`), nested maps, lists, and objects implementing `ToJsonable`. Includes 15 tests matching the upstream SDK's `json-stable-stringify` reference output.

---

## solana_kit_functional

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for foundational utility packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement foundation utility packages ported from the `@solana/functional` and

`@solana/fast-stable-stringify` TypeScript packages.

**solana_kit_functional**: Adds the `Pipe` extension which provides a `.pipe()` method on any value for composable functional pipelines. This is the idiomatic Dart equivalent of the TS `pipe()` function, used extensively for building transaction messages. Includes 28 tests covering single/multiple transforms, type changes, object mutation, combining, nested pipes, and error propagation.

**solana_kit_fast_stable_stringify**: Adds `fastStableStringify()` for deterministic JSON serialization with sorted object keys. Handles all Dart primitives, BigInt (serialized as `<value>n`), nested maps, lists, and objects implementing `ToJsonable`. Includes 15 tests matching the upstream SDK's `json-stable-stringify` reference output.

---

## solana_kit_helius

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Add `solana_kit_helius` package — a Dart port of the Helius TypeScript SDK.

Provides 12 sub-clients: DAS API, Priority Fees, RPC V2, Enhanced Transactions, Webhooks, ZK Compression, Smart Transactions, Staking, Wallet API, WebSockets, and Auth. Includes 150 unit tests across 80 test files.

Adds 6 Helius-specific error codes (8600000–8600005) to `solana_kit_errors`.

---

## solana_kit_instruction_plans

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for program and transaction planning packages.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement instruction plans package ported from `@solana/instruction-plans`.

**solana_kit_instruction_plans** (215 tests):

- `InstructionPlan` sealed class hierarchy: `SingleInstructionPlan`, `SequentialInstructionPlan`, `ParallelInstructionPlan`, `MessagePackerInstructionPlan`
- `TransactionPlan` sealed class hierarchy: `SingleTransactionPlan`, `SequentialTransactionPlan`, `ParallelTransactionPlan`
- `TransactionPlanResult` sealed class hierarchy with successful, failed, canceled, sequential, and parallel result types
- `createTransactionPlanner` converting instruction plans to transaction plans with size-aware message packing
- `createTransactionPlanExecutor` for executing transaction plans with context propagation
- `MessagePacker` with linear, instruction-based, and realloc message packer factories
- Tree traversal utilities: `findInstructionPlan`, `everyInstructionPlan`, `transformInstructionPlan`, `flattenTransactionPlan`
- Type guards and assertions for all plan types
- `appendTransactionMessageInstructionPlan` helper for adding instructions to messages
- `passthroughFailedTransactionPlanExecution` for error handling passthrough
- `TransactionPlanResultSummary` with `summarizeTransactionPlanResult` for result aggregation

---

## solana_kit_instructions

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for address and signer packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement instructions and programs packages ported from `@solana/instructions` and `@solana/programs`.

**solana_kit_instructions** (56 tests):

- `AccountRole` enhanced enum with bitflag values (readonly, writable, readonlySigner, writableSigner)
- 7 role manipulation functions: upgrade/downgrade signer/writable, merge, query
- `AccountMeta` and `AccountLookupMeta` immutable classes with const constructors
- `Instruction` class with optional accounts and data fields
- 6 instruction validation functions: isInstructionForProgram, isInstructionWithAccounts, isInstructionWithData (with assert variants)

**solana_kit_programs** (5 tests):

- `isProgramError` function to identify custom program errors from transaction failures
- Matches error code, instruction index, and program address against transaction message
- `TransactionMessageInput` and `InstructionInput` minimal types for error checking

#### Fixes

##### Implement transaction messages package ported from `@solana/transaction-messages`.

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

---

## solana_kit_keys

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for address and signer packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement addresses and keys packages ported from `@solana/addresses` and `@solana/keys`.

**solana_kit_addresses** (65 tests):

- `Address` extension type wrapping validated base58-encoded 32-byte strings
- Address codec (`getAddressEncoder`/`getAddressDecoder`/`getAddressCodec`) for 32-byte fixed-size encoding
- Address comparator with base58 collation rules matching Solana runtime ordering
- Ed25519 curve checking (`compressedPointBytesAreOnCurve`, `isOnCurveAddress`, `isOffCurveAddress`)
- PDA derivation (`getProgramDerivedAddress`) with SHA-256, bump seed search, and seed validation
- `createAddressWithSeed` for deterministic address derivation
- Public key to/from address conversion utilities

**solana_kit_keys** (36 tests):

- `Signature` and `SignatureBytes` extension types for Ed25519 signatures
- Key pair generation, creation from bytes, and creation from private key bytes
- Ed25519 sign/verify operations using `ed25519_edwards` package
- Signature validation (string length, byte length, base58 decoding)
- Private key validation and public key derivation

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## solana_kit_lints

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable, non-placeholder examples for `solana_kit_lints` and `solana_kit_test_matchers`, including analyzer configuration guidance for lint usage and direct matcher usage examples.

##### Add a `solana_kit_lints` workspace dependency checker and run it as part of

`lint:all` to ensure internal package dependencies use `workspace: true` in `pubspec.yaml` files.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial release of shared lint configuration package. Extends `very_good_analysis`

with project-specific overrides: disables `public_member_api_docs` (docs will be added incrementally) and `lines_longer_than_80_chars` (allows longer lines for readability in codec/RPC code). All 37 packages in the workspace depend on this package via `dev_dependencies` for consistent static analysis.

#### Fixes

- CI/tooling improvements: add devenv composite action, refactor CI to use devenv shell, add dprint exec plugins, and enable additional lint rules.

---

## solana_kit_mobile_wallet_adapter

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Add Mobile Wallet Adapter packages for Solana.

**solana_kit_mobile_wallet_adapter_protocol**: Pure Dart MWA v2.0 protocol with P-256 ECDH/ECDSA, AES-128-GCM encryption, HKDF-SHA256, HELLO handshake, JSON-RPC messaging, association URIs, SIWS, and JWS.

**solana_kit_mobile_wallet_adapter**: Flutter plugin for Android MWA with `transact()`, local/remote association scenarios, wallet-side callbacks, Kit-integrated typed APIs, and platform method channels.

Adds 20 MWA-specific error codes (8400000-8400105) to `solana_kit_errors`.

---

## solana_kit_mobile_wallet_adapter_protocol

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Add Mobile Wallet Adapter packages for Solana.

**solana_kit_mobile_wallet_adapter_protocol**: Pure Dart MWA v2.0 protocol with P-256 ECDH/ECDSA, AES-128-GCM encryption, HKDF-SHA256, HELLO handshake, JSON-RPC messaging, association URIs, SIWS, and JWS.

**solana_kit_mobile_wallet_adapter**: Flutter plugin for Android MWA with `transact()`, local/remote association scenarios, wallet-side callbacks, Kit-integrated typed APIs, and platform method channels.

Adds 20 MWA-specific error codes (8400000-8400105) to `solana_kit_errors`.

---

## solana_kit_offchain_messages

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement offchain messages package ported from `@solana/offchain-message`.

**solana_kit_offchain_messages** (1082 tests):

- `OffchainMessage` sealed class with `OffchainMessageV0` and `OffchainMessageV1` subtypes
- V0: application domain, three content formats (restricted ASCII 1232, UTF-8 1232, UTF-8 65535), signatory list
- V1: simplified with auto-sorted signatories and arbitrary UTF-8 content
- Content validation: ASCII character range (0x20-0x7E), size limits, format enforcement
- Application domain validation (must be valid 32-byte base58 address)
- Full codec suite: V0/V1/unified message codecs, envelope codec with signature handling
- `compileOffchainMessageEnvelope` to create signable envelopes from messages
- `partiallySignOffchainMessageEnvelope` and `signOffchainMessageEnvelope` for Ed25519 signing
- `verifyOffchainMessageEnvelope` for cryptographic signature verification
- Missing signatures encoded as 64 zero bytes in wire format

---

## solana_kit_options

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for foundational utility packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement options package and codecs umbrella re-export.

**solana_kit_options** (90 tests):

- Rust-like `Option<T>` sealed class with `Some<T>` and `None<T>` subclasses
- Option codec with 6 encoding modes: prefix-based, zeroes, custom none value, combined prefix+zeroes, combined prefix+custom, and absence-based detection
- `unwrapOption()` and `unwrapOptionOr()` for extracting values with fallback
- `wrapNullable()` for converting `T?` to `Option<T>`
- `unwrapOptionRecursively()` for deep unwrapping of nested Options in Maps/Lists

**solana_kit_codecs** (umbrella):

- Re-exports all codec sub-packages: core, numbers, strings, data structures
- Re-exports options package (matching TypeScript `@solana/codecs` behavior)

---

## solana_kit_program_client_core

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for program and transaction planning packages.
- Document fix: harden self-plan-and-send program client flows.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement program client core package ported from `@solana/program-client-core`.

**solana_kit_program_client_core** (31 tests):

- `InstructionWithByteDelta` mixin for tracking account storage size changes
- `ResolvedInstructionAccount` type for resolved instruction account values
- `getNonNullResolvedInstructionInput` null-safety validation with descriptive errors
- `getAddressFromResolvedInstructionAccount` extracts Address from Address/PDA/TransactionSigner
- `getResolvedInstructionAccountAsProgramDerivedAddress` validates and extracts PDA
- `getResolvedInstructionAccountAsTransactionSigner` validates and extracts TransactionSigner
- `getAccountMetaFactory` factory converting ResolvedInstructionAccount to AccountMeta with omitted/programId strategies
- `SelfFetchFunctions` augmenting codecs with fetch/fetchMaybe/fetchAll/fetchAllMaybe methods
- Stub for self-plan-and-send functions (pending instruction_plans implementation)

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

---

## solana_kit_programs

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for program and transaction planning packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement instructions and programs packages ported from `@solana/instructions` and `@solana/programs`.

**solana_kit_instructions** (56 tests):

- `AccountRole` enhanced enum with bitflag values (readonly, writable, readonlySigner, writableSigner)
- 7 role manipulation functions: upgrade/downgrade signer/writable, merge, query
- `AccountMeta` and `AccountLookupMeta` immutable classes with const constructors
- `Instruction` class with optional accounts and data fields
- 6 instruction validation functions: isInstructionForProgram, isInstructionWithAccounts, isInstructionWithData (with assert variants)

**solana_kit_programs** (5 tests):

- `isProgramError` function to identify custom program errors from transaction failures
- Matches error code, instruction index, and program address against transaction message
- `TransactionMessageInput` and `InstructionInput` minimal types for error checking

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

---

## solana_kit_rpc

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc runtime packages.
- Document fix: harden rpc transports and subscription channels.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Implement RPC client package ported from `@solana/rpc`.

**solana_kit_rpc** (125 tests):

- `createSolanaRpc` and `createSolanaRpcFromTransport` factory functions combining API + transport + transformers
- `createDefaultRpcTransport` with `solana-client: dart/0.0.1` header and request coalescing
- Request coalescing: deduplicates identical JSON-RPC requests within the same microtask
- Deduplication key generation using `fastStableStringify` for deterministic request hashing
- Integer overflow error creation with human-readable ordinal argument labels
- Default RPC config: `confirmed` commitment, integer overflow handler

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

---

## solana_kit_rpc_api

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc spec and type packages.
- Document test: add rpc contract and model regression suites.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC API package ported from `@solana/rpc-api`.

**solana_kit_rpc_api** (75 tests):

- Config and params classes for all 52 Solana RPC methods (getAccountInfo, getBalance, getBlock, sendTransaction, simulateTransaction, etc.)
- `solanaRpcMethodsForAllClusters` (51 methods) and `solanaRpcMethodsForTestClusters` (52 methods, includes requestAirdrop)
- `getAllowedNumericKeypaths()` for response transformer numeric value whitelisting
- Cluster-variant helpers: `isSolanaRpcMethodForMainnet`, `isSolanaRpcMethodForTestClusters`
- Per-method `toJson()` serialization and params builder functions

---

## solana_kit_rpc_parsed_types

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc spec and type packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC parsed types package ported from `@solana/rpc-parsed-types`.

**solana_kit_rpc_parsed_types** (32 tests):

- Typed representations of JSON-parsed account data from the Solana RPC
- Address lookup table, BPF upgradeable loader, config, nonce, stake, sysvar, token, and vote account types
- Sealed class hierarchies for discriminated unions enabling exhaustive pattern matching
- `RpcParsedType<TType, TInfo>` and `RpcParsedInfo<TInfo>` base classes
- All 10 sysvar account types: clock, epochRewards, epochSchedule, fees, lastRestartSlot, recentBlockhashes, rent, slotHashes, slotHistory, stakeHistory
- Token program accounts: account, mint, multisig with `TokenAccountState` enum

---

## solana_kit_rpc_spec

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc spec and type packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC spec package ported from `@solana/rpc-spec`.

**solana_kit_rpc_spec** (23 tests):

- `JsonRpcApi` with configurable request/response transformers creating `RpcPlan` objects
- `RpcPlan<T>` describing how to execute an RPC request with lazy execution
- `RpcTransport` typedef for pluggable transport layer
- `Rpc` client that wraps API + transport, returning `PendingRpcRequest` objects
- `PendingRpcRequest<T>` with `send()` method for deferred execution
- `isJsonRpcPayload` type guard for JSON-RPC 2.0 payload validation
- `RpcApi` abstract class with `JsonRpcApiAdapter` and `MapRpcApi` implementations

---

## solana_kit_rpc_spec_types

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc spec and type packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC spec types package ported from `@solana/rpc-spec-types`.

**solana_kit_rpc_spec_types** (96 tests):

- `RpcRequest<TParams>` class with method name and typed parameters
- `RpcRequestTransformer` and `RpcResponseTransformer` function typedefs
- `RpcErrorResponsePayload` with code, message, and optional data
- `RpcResponseData` sealed class with `RpcResponseResult` and `RpcResponseError` subtypes
- `createRpcMessage` for JSON-RPC 2.0 message creation with auto-incrementing IDs
- `parseJsonWithBigInts` for JSON parsing that preserves large integers as `BigInt`
- `stringifyJsonWithBigInts` for JSON serialization that renders `BigInt` values as bare numbers

---

## solana_kit_rpc_subscriptions

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc runtime packages.
- Document fix: harden rpc transports and subscription channels.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC subscriptions composition package ported from `@solana/rpc-subscriptions`.

**solana_kit_rpc_subscriptions** (144 tests):

- `createSolanaRpcSubscriptions` and `createSolanaRpcSubscriptionsUnstable` factory functions
- `createSolanaRpcSubscriptionsFromTransport` for custom transport usage
- `getRpcSubscriptionsTransportWithSubscriptionCoalescing` deduplicating identical subscriptions via fastStableStringify hashing
- `getRpcSubscriptionsChannelWithAutoping` periodic keep-alive ping messages with timer reset on activity
- `getChannelPoolingChannelCreator` channel reuse with maxSubscriptionsPerChannel limits and automatic cleanup
- `getRpcSubscriptionsChannelWithJsonSerialization` and `getRpcSubscriptionsChannelWithBigIntJsonSerialization`
- `createDefaultSolanaRpcSubscriptionsChannelCreator` composing JSON + autopinger + pooling
- `createSolanaJsonRpcIntegerOverflowError` with ordinal argument labels
- Default RPC subscription configuration with `confirmed` commitment

---

## solana_kit_rpc_subscriptions_api

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc runtime packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC subscriptions API package ported from `@solana/rpc-subscriptions-api`.

**solana_kit_rpc_subscriptions_api** (61 tests):

- 6 stable subscription methods: `accountNotifications`, `logsNotifications`, `programNotifications`, `rootNotifications`, `signatureNotifications`, `slotNotifications`
- 3 unstable subscription methods: `blockNotifications`, `slotsUpdatesNotifications`, `voteNotifications`
- Sealed `LogsFilter` type (All/AllWithVotes/Mentions) with JSON serialization
- Sealed `BlockNotificationsFilter` type (All/MentionsAccountOrProgram)
- `solanaRpcSubscriptionsMethodsStable` and `solanaRpcSubscriptionsMethodsUnstable` composition
- Helper functions: `notificationNameToSubscribeMethod()`, `notificationNameToUnsubscribeMethod()`
- Config types for each subscription with proper encoding commitment/maxSupportedTransactionVersion

---

## solana_kit_rpc_subscriptions_channel_websocket

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Document fix: harden rpc transports and subscription channels.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC subscriptions WebSocket channel package ported from `@solana/rpc-subscriptions-channel-websocket`.

**solana_kit_rpc_subscriptions_channel_websocket** (23 tests):

- `createWebSocketChannel` factory for creating WebSocket RPC subscription channels
- `RpcSubscriptionsChannel` interface extending `DataPublisher` with `send()` method
- `AbortSignal` / `AbortController` for clean channel shutdown
- `WebSocketChannelConfig` with URL, sendBufferHighWatermark, and optional abort signal
- Message forwarding via DataPublisher `'message'` channel
- Error publishing on abnormal WebSocket closure (non-1000 codes)
- Integration tests using real `HttpServer` with `WebSocketTransformer`

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## solana_kit_rpc_transport_http

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc runtime packages.
- Document fix: harden rpc transports and subscription channels.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC transport HTTP package ported from `@solana/rpc-transport-http`.

**solana_kit_rpc_transport_http** (129 tests):

- `createHttpTransport` factory for JSON-RPC POST requests with configurable headers, custom JSON serialization/deserialization
- `createHttpTransportForSolanaRpc` wrapping transport with BigInt-aware JSON handling via `parseJsonWithBigInts`/`stringifyJsonWithBigInts`
- `isSolanaRequest` type guard checking against 55 known Solana RPC methods
- Header validation: forbidden headers (MDN spec), disallowed headers (Accept, Content-Type, Content-Length, Solana-Client), proxy-\_/sec-\_ prefix matching
- HTTP error handling with `SolanaError` context preservation (status code, message)

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## solana_kit_rpc_transformers

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc runtime packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC transformers package ported from `@solana/rpc-transformers`.

**solana_kit_rpc_transformers** (524 tests):

- Request transformers: BigInt downcast, integer overflow detection, default commitment injection
- Response transformers: BigInt upcast, JSON-RPC error throwing with Solana error unwrapping, result extraction
- Tree traversal utilities with key path wildcards for deep object walking
- Default commitment handling for 39 RPC methods with per-method config position mapping
- Preflight error unwrapping from `-32002` JSON-RPC errors
- Composable transformer pipelines via `getDefaultRequestTransformerForSolanaRpc` and `getDefaultResponseTransformerForSolanaRpc`

---

## solana_kit_rpc_types

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc spec and type packages.
- Document fix: resolve fatal analyzer infos across workspace.
- Document test: add rpc contract and model regression suites.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement RPC types package ported from `@solana/rpc-types`.

**solana_kit_rpc_types** (85 tests):

- `Blockhash` extension type with validation, codec (32-byte base58), and comparator
- `Lamports` extension type (0 to 2^64-1) with generic encoder/decoder/codec wrappers
- `UnixTimestamp` extension type (i64 range) with validation
- `StringifiedBigInt` and `StringifiedNumber` extension types with validation
- `Commitment` enum (processed, confirmed, finalized) with comparator
- `MicroLamports`, `SignedLamports`, `Slot`, `Epoch` type aliases
- Encoded data types: `Base58EncodedBytes`, `Base64EncodedBytes`, data response records
- Account info types: `AccountInfoBase` and encoding-specific variants
- `TokenAmount`, `TokenBalance` for SPL token data
- `TransactionError` and `InstructionError` sealed class hierarchies
- `TransactionVersion`, `Reward`, `TransactionStatus` types
- Cluster URL types: `MainnetUrl`, `DevnetUrl`, `TestnetUrl`
- `SolanaRpcResponse<T>` wrapper with slot context
- Account filter types: `DataSlice`, memcmp and datasize filters

---

## solana_kit_signers

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for address and signer packages.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement signers package ported from `@solana/signers`.

**solana_kit_signers** (88 tests):

- Five core signer interfaces: `MessagePartialSigner`, `MessageModifyingSigner`, `TransactionPartialSigner`, `TransactionModifyingSigner`, `TransactionSendingSigner`
- Composite types: `MessageSigner`, `TransactionSigner`, `KeyPairSigner` with Ed25519 signing
- `NoopSigner` for adding signature slots without actual signing
- `partiallySignTransactionMessageWithSigners` and `signTransactionMessageWithSigners` for signing transaction messages using attached signers
- `signAndSendTransactionMessageWithSigners` for combined sign-and-send workflow
- Signer extraction from instructions and transaction messages via account meta
- Fee payer signer utilities
- Signer deduplication and assertion helpers

---

## solana_kit_subscribable

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for rpc runtime packages.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement subscribable package ported from `@solana/subscribable`.

**solana_kit_subscribable** (33 tests):

- `DataPublisher` interface with `on(channelName, subscriber)` returning unsubscribe function
- `WritableDataPublisher` concrete implementation with `publish(channelName, data)` for testing
- `createStreamFromDataPublisher` converting DataPublisher to Dart `Stream<TData>` with error channel support
- `createAsyncIterableFromDataPublisher` with AbortSignal support, message queuing, and pre-poll message dropping
- `demultiplexDataPublisher` splitting single channel into multiple typed channels with lazy subscription and reference counting
- Idempotent unsubscribe and proper cleanup on abort

---

## solana_kit_sysvars

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement sysvars package ported from `@solana/sysvars`.

**solana_kit_sysvars** (52 tests):

- 10 sysvar address constants (Clock, EpochRewards, EpochSchedule, Instructions, LastRestartSlot, RecentBlockhashes, Rent, SlotHashes, SlotHistory, StakeHistory)
- `SysvarClock` codec (40 bytes): slot, epochStartTimestamp, epoch, leaderScheduleEpoch, unixTimestamp
- `SysvarEpochSchedule` codec (33 bytes): slotsPerEpoch, leaderScheduleSlotOffset, warmup, firstNormalEpoch, firstNormalSlot
- `SysvarEpochRewards` codec (81 bytes): distributionStartingBlockHeight, numPartitions, parentBlockhash, totalPoints (u128), totalRewards, distributedRewards, active
- `SysvarRent` codec (17 bytes): lamportsPerByteYear, exemptionThreshold (f64), burnPercent
- `SysvarLastRestartSlot` codec (8 bytes), `SysvarSlotHashes` variable-size array codec
- `SysvarSlotHistory` bitvector codec (131,097 bytes) with discriminator validation
- `SysvarRecentBlockhashes` (deprecated) and `SysvarStakeHistory` variable-size array codecs
- `fetchSysvar*` async RPC functions for each sysvar type
- `fetchEncodedSysvarAccount` generic fetch function

---

## solana_kit_test_matchers

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable, non-placeholder examples for `solana_kit_lints` and `solana_kit_test_matchers`, including analyzer configuration guidance for lint usage and direct matcher usage examples.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement test matchers package with Solana-specific test assertions.

**solana_kit_test_matchers** (33 tests):

- `isSolanaErrorWithCode` / `throwsSolanaErrorWithCode` for matching SolanaError by error code
- `isSolanaErrorWithCodeAndContext` for matching error code and context entries
- `isSolanaErrorMatcher` / `throwsSolanaError` for matching any SolanaError
- `equalsBytes` for byte-for-byte Uint8List comparison with detailed mismatch reporting
- `hasByteLength` / `startsWithBytes` for byte array assertions
- `isValidSolanaAddress` / `equalsAddress` for Address validation and comparison
- `isFullySignedTransactionMatcher` / `hasSignatureCount` for Transaction signature verification

---

## solana_kit_transaction_confirmation

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Add runnable examples for specialized and mobile-focused packages, including websocket subscriptions, sysvars, and transaction confirmation flows.
- Document fix: resolve fatal analyzer infos across workspace.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 17 higher-level packages including the full RPC stack,

program interaction layers, and the umbrella package. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification), rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket, rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities), program_client_core (base client), sysvars (system variables)
- **Transaction Lifecycle**: transaction_confirmation (polling/confirmation)
- **Umbrella**: solana_kit (re-exports all packages for convenience)

##### Implement transaction confirmation package ported from `@solana/transaction-confirmation`.

**solana_kit_transaction_confirmation** (60 tests):

- `createRecentSignatureConfirmationPromiseFactory` with dual-pronged subscription + one-shot query
- `createBlockHeightExceedencePromiseFactory` monitoring slot notifications for block height tracking
- `createNonceInvalidationPromiseFactory` detecting durable nonce advancement
- `getTimeoutPromise` with commitment-based timeouts (30s processed, 60s confirmed/finalized)
- `raceStrategies` core strategy racing with safe future handling
- `waitForRecentTransactionConfirmation` high-level blockhash-based confirmation
- `waitForDurableNonceTransactionConfirmation` high-level nonce-based confirmation
- `waitForRecentTransactionConfirmationUntilTimeout` (deprecated) timeout-based fallback
- Dependency injection pattern for RPC functions to keep dependencies minimal

---

## solana_kit_transaction_messages

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for program and transaction planning packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement transaction messages package ported from `@solana/transaction-messages`.

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

---

## solana_kit_transactions

### 0.2.0 (2026-02-27)

#### Breaking Changes

##### Initial Release

The initial release of all libraries.

#### Fixes

- Align knope package scopes, update workspace maintenance dependencies, and apply lint/format cleanup updates across touched packages.
- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Document docs: add mdt workspace docs tooling and shared README sections.
- Document docs: add real examples for program and transaction planning packages.
- Use `workspace: true` for all internal package dependencies and replace melos with native Dart workspace commands.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial scaffold for 18 core packages forming the foundation and middle layers of

the Solana Kit dependency graph. Each package has its pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml, and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **Crypto & Identity**: addresses (base58), keys (Ed25519), signers (interfaces)
- **Codecs**: core interfaces, numbers, strings, data structures, umbrella re-export
- **Utilities**: functional (pipe/compose), options (Rust-like Option codec), fast_stable_stringify, subscribable (reactive patterns)
- **Transaction Building**: instructions, instruction_plans, transaction_messages, transactions (compilation & signing)
- **Other**: offchain_messages, test_matchers

##### Implement transactions package ported from `@solana/transactions`.

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

#### Fixes

##### Enhance core SDK packages with additional functionality and tests.

- **Codecs core**: Enhanced `addCodecSizePrefix` with additional functionality
- **Codecs data structures**: Array codec improvements
- **Codecs numbers**: `shortU16` codec enhancements
- **Codecs strings**: UTF-8 codec improvements
- **Keys**: Key pair and signatures enhancements
- **RPC transport**: HTTP transport and WebSocket channel updates
- **Transactions**: Transaction codec enhancements

---

## codama_renderers_solana_kit_dart

### 0.1.1 (2026-02-27)

#### Features

- Add `codama-renderers-dart` - a Codama renderer that generates Dart code targeting the solana_kit SDK from Codama IDL definitions.

#### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Fix code generation bugs: AccountRole enum names, cross-type imports, transformDecoder callback signature, template literal interpolation, missing codec imports, and nullable field assertions. Add comprehensive e2e test suite with snapshot tests, JS comparison tests, and Dart validation.

### 0.1.0

#### Features

- Initial release of `codama-renderers-dart`
- Generate Dart code from Codama IDL targeting the solana_kit SDK
- Support for accounts, instructions, defined types, errors, PDAs, and programs
- Type manifest visitor mapping all Codama type nodes to Dart types and codecs
- Fragment-based code generation with automatic import tracking
- Comprehensive test suite with 261 tests

## [0.10.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.10.0) (2026-09-21)

Grouped release for `main`.

### Breaking changes

#### Raise the Dart and Flutter baseline

_Packages:_ _solana_kit_, _solana_kit_accounts_, _solana_kit_address_, _solana_kit_anchor_, _solana_kit_address_constants_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_fixed_points_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_jupiter_, _solana_kit_instruction_plans_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_lints_, _solana_kit_mpl_core_, _solana_kit_mpl_token_metadata_, _solana_kit_options_, _solana_kit_pyth_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transformers_, _solana_kit_rpc_transport_http_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_sns_, _solana_kit_squads_, _solana_kit_subscribable_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_introspection_, _solana_kit_transaction_messages_, _solana_kit_transactions_

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

#### Align error code numbers with upstream and report malformed UTF-8 as a code

_Packages:_ _solana_kit_errors_

`SolanaErrorCode` numbers now match upstream `@solana/kit` exactly. Two port-only codes were occupying numbers upstream uses for its UTF-8 codes, which made any cross-SDK comparison of those numbers wrong.

The UTF-8 codec also stops raising a bare `FormatException` and reports through the error codes upstream defines:

- `codecsInvalidUtf8Bytes` (`8078026`) for a malformed byte sequence, carrying the `offset` where decoding failed.
- `codecsInvalidUtf8String` (`8078027`) for a lone surrogate, carrying its `index`. This is thrown when encoding with `fatal: true` and, with `fatal: false`, both directions keep replacing the offending unit with `U+FFFD`.

Two port-only codes moved or went away:

- `codecsInvalidBoolean` moved from `8078027` to `8078999`. The number had to change because `8078027` is upstream's `CODECS__INVALID_UTF8_STRING`. This port validates that booleans are encoded as `0` or `1` and upstream does not, so the code has no upstream counterpart and now sits at the end of the codec block, where upstream cannot collide with it. If you match on `SolanaErrorCode.codecsInvalidBoolean.value`, update the number; matching on the enum member is unaffected.
- `codecsStringContainsNullCharacters` was removed. Nothing in the workspace threw it, and upstream has no equivalent. Use `Utf8CodecConfig.removeNullCharacters` to control null handling instead.

```dart
try {
  getUtf8Decoder().decode(bytes);
} on SolanaError catch (error) {
  if (error.code == SolanaErrorCode.codecsInvalidUtf8Bytes) {
    print('bad bytes at ${error.context['offset']}');
  }
}
```

`solana_kit_memo`, `solana_kit_offchain_messages`, and `solana_kit_attestation_service` only had tests asserting the old `FormatException` for malformed UTF-8; those assertions now check the error code, and `solana_kit_memo` declares the `solana_kit_errors` dev dependency that needs.

`upstream:error-codes`, which also runs as part of `docs:check`, compares this enum against `.repos/kit/packages/errors/src/codes.ts` and fails on a number mismatch or an occupied number, so this cannot drift again without CI saying so.

_Owner:_ Ifiok Jr. · _Introduced in:_ [a8f643f](https://github.com/openbudgetfun/solana_kit/commit/a8f643f1ae7e6594fbfa972d473f7042b1f6ace0)

### Features

#### Replace stubbed functions with real implementations

_Packages:_ _solana_kit_, _solana_kit_addresses_, _solana_kit_rpc_, _solana_kit_transaction_messages_

Several public functions promised behavior they did not deliver. Each is now implemented, with the missing API surface added alongside it.

##### `estimateResourceLimitsFactory` now simulates

The previous implementation returned its argument unchanged, so it performed no simulation: no compute unit measurement, no loaded accounts data size, no failure reporting. It also could not have worked where it lived, because it needs an RPC client and the transaction compiler, and `solana_kit_transaction_messages` depends on neither. Upstream defines this function in the umbrella `@solana/kit` package for the same reason, so it now lives in `package:solana_kit` with that dependency available.

It takes an `EstimateResourceLimitsFactoryConfig` holding the RPC client and returns a function that:

- Sets the compute unit limit to the maximum (`1400000`) and, for version 1 messages, the loaded accounts data size limit to the maximum (`67108864`) before simulating, so the simulation is not cut short by a resource ceiling.
- Asks the node to replace the blockhash for blockhash-lifetime transactions, and uses the real nonce for durable nonce transactions.
- Returns the `unitsConsumed` the node reported, capped at the `u32` ceiling, plus `loadedAccountsDataSize`.
- Throws `transactionFailedToEstimateComputeLimit` when the node reports no compute units, `transactionFailedToEstimateLoadedAccountsDataSizeLimit` when a version 1 simulation omits the loaded accounts size, and `transactionFailedWhenSimulatingToEstimateResourceLimits` with the decoded transaction error as `cause` when the transaction itself fails. All three codes already existed and were never thrown.

Three supporting pieces land with it:

- `simulateTransaction` and its `simulateTransactionValue` result are now available on the RPC client. The method was reachable only by hand-assembling a request before this.
- `maxLoadedAccountsDataSizeLimit` (`67108864`) is exported.
- `estimateAndSetResourceLimitsFactory` no longer computes a loaded accounts data size for legacy and version 0 messages. It previously did, which spent an extra simulation and could attach a `SetLoadedAccountsDataSizeLimit` instruction the runtime ignores. The loaded accounts limit is now only ever set on version 1 messages, matching upstream.

```dart
final estimate = estimateResourceLimitsFactory(
  EstimateResourceLimitsFactoryConfig(rpc: rpc),
);
final withLimits = await estimateAndSetResourceLimitsFactory(estimate)(message);
```

##### `solana_kit_functional` removed

The package is gone. Its only utility, the `pipe` extension, has lived in `solana_kit_transaction_messages` since the previous breaking release and is re-exported by `solana_kit`, so the package duplicated what the SDK already provided and existed only as an empty placeholder pending retirement. Anyone still importing it should switch to `solana_kit_transaction_messages` (or the `solana_kit` umbrella), which is a one-line import change.

##### `solana_kit_addresses` gains the PDA guards

`isProgramDerivedAddress` and `assertIsProgramDerivedAddress` were absent, leaving `addressesMalformedPda` and `addressesPdaBumpSeedOutOfRange` defined but unreachable. Both are now implemented: they validate that a value is an `(Address, int)` record, that the bump seed is in `[0, 255]`, and that the address is well formed.

##### `solana_kit_helius` builds real smart transactions

`createSmartTransaction` returned a bare blockhash while documenting that it would estimate compute units and priority fees. It now performs the full sequence: validate, estimate compute units through `simulateTransaction`, sample the priority fee by account key, resolve the fee in both microLamports-per-unit and total lamports, and refresh the blockhash. It returns a `SmartTransaction` carrying the limits, fee, lifetime, instructions, fee payer, and account keys; signing stays with the caller because the client holds signer addresses rather than keys.

Two related silent defaults were removed:

- `getComputeUnits` returned `200000` when the node omitted `unitsConsumed`. It now throws, because inventing a number sizes the transaction for work the simulation never confirmed. It also reports a failed simulation instead of returning the units of one that did not succeed, and it serializes real `Instruction` objects, which previously failed at JSON encoding.
- `broadcastTransaction`, `sendTransactionWithSender`, and `sendSmartTransaction` accepted a `senderUrl` parameter they never used. The parameter is gone; the REST client already targets the sender base URL.

##### Version 1 durable nonce transactions are recognized

`getTransactionLifetimeConstraintFromCompiledTransactionMessage` only inspected the legacy instruction list, which a version 1 compiled message leaves empty in favour of separate instruction headers and payloads. Every version 1 durable nonce transaction therefore decompiled as a blockhash transaction, so a caller could not tell that its lifetime depended on a nonce. The version 1 branch now reads the headers and payloads, throws `transactionInvalidNonceAccountIndex` for an out-of-range nonce account index, and returns the blockhash lifetime only when the first instruction is genuinely not an advance-nonce instruction.

##### Priority fee lamports API

`getTransactionMessagePriorityFeeLamports` and `setTransactionMessagePriorityFeeLamports` add the missing read/write surface for the total-lamport priority fee that only version 1 messages carry. The setter removes the fee on `null`, drops an emptied config, and is a no-op when the value already matches.

##### Wallets can now express and check version 1 support

`SolanaTransactionVersion` gains `version1` plus `wireValue` and `fromWireValue`, so the values a wallet advertises (`legacy`, `0`, `1`) round-trip instead of being collapsed. A `supportsVersion1` extension makes the check usable. Two related corrections:

- The browser registry used to map any advertised entry other than `legacy` onto version 0, so a wallet advertising `1` was reported as version 0 and a caller could build a transaction the wallet cannot sign. Unrecognized entries are now dropped rather than mislabelled.
- The MWA-backed mobile wallet advertises an explicit `legacy`-and-version-0 list instead of `SolanaTransactionVersion.values`, which would have silently started claiming version 1 support as the enum grew. This matches upstream's `wallet-standard-mobile`.

##### Error codes that were defined but unreachable

Three codes had no throw site. `signerWalletAccountCannotSignTransaction` is now thrown when a `WalletAccountSigner` is created for an account advertising neither transaction feature, matching upstream's `createSignerFromWalletAccount`. `heliusApiKeyRequired` is thrown by `HeliusConfig` for a blank key, which previously produced a request that could only fail with a 401. `heliusTransactionSimulationFailed` replaces a bare `StateError` when a compute-unit simulation reports a transaction failure.

The remaining defined-but-unthrown codes were checked against upstream and are parity-faithful: upstream defines them without throwing them anywhere either (`addressesInvalidBase58EncodedAddress`, the four `wallet*` codes, `subscribableRetryNotSupported`, `transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce`), or they belong to abstractions this port intentionally does not have (the React hook path behind `signerWalletMultisignUnimplemented`, the fs-impl package behind `fsUnsupportedEnvironment`, the named-channel pubsub plan behind `invariantViolationDataPublisherChannelUnimplemented`).

##### `solana_kit_dapp_publisher_cli` reports unreadable balances

`parseLamportsValue` returned `0` for a balance response it could not parse. A malformed response therefore looked like an empty wallet. It now throws a `FormatException`, so a transport or schema change is reported as itself rather than as insufficient funds.

_Owner:_ Ifiok Jr. · _Introduced in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

#### Track @solana/kit v8.3.0

_Packages:_ _solana_kit_, _solana_kit_codecs_core_, _solana_kit_codecs_numbers_

The workspace now tracks upstream `@solana/kit` v8.3.0 (previously v8.2.0), and `upstream:parity` passes against it. This entry maps every change in that upstream release to its Dart counterpart.

Ported in this release:

- `u256` and `i256` number codecs (`getU256Codec`, `getI256Codec` and their encoder/decoder pairs) serialize 32 bytes, honour the `endian` option, validate the full range on encode, and decode to `BigInt`, mirroring the existing 64-bit and 128-bit codecs.
- Tap codec helpers observe values or bytes without modifying them: `tapEncoder`, `tapDecoder`, and `tapCodec` observe values, while `tapEncoderBytes`, `tapDecoderBytes`, and `tapCodecBytes` observe raw bytes and offsets. Each wrapper preserves the size characteristics of what it wraps, and any tap may throw, which makes them validation guards that need no identity `transformEncoder`.

Already present before this release, and now covered by the v8.3.0 claim:

- The `getAgGenesisCert` RPC method and its allowed numeric keypaths.
- `isSolanaRequest` recognising `getAgGenesisCert` and `getTransactionsForAddress`, which is also what fixed upstream's `bigint` parsing for `getTransactionsForAddress` responses.

No Dart change needed:

- `HasAddress` and the `InstructionAccountInput` / `InstructionSignerInput` widening are TypeScript type-level changes. Dart has no structural typing, and this port's `ResolvedInstructionAccount` already wraps an `Object` value, so it accepts addresses, address-bearing objects, `ProgramDerivedAddress` values, and `AccountMeta` role overrides at runtime without a cast.
- Marking `role` as `readonly` on the writable and signer account types is already true here: `AccountMeta.role` is a `final` field.
- `createLazyKeyPairSignerFromBytes` exists upstream to defer an asynchronous WebCrypto key import. Signer creation in this port is synchronous, so there is nothing to defer and the type is not needed.

Verification:

- `upstream:parity` passes against `@solana/kit@8.3.0`
- `upstream:check` reports the metadata is internally consistent for tracked version 8.3.0
- The `@solana/kit` reference pin moved to tag `v8.3.0`

_Owner:_ Ifiok Jr. · _Introduced in:_ [220066e](https://github.com/openbudgetfun/solana_kit/commit/220066ecb27aa738fd787ac8ada3918540435cc1)

#### Track the memo v4 program and add memo extraction helpers

_Packages:_ _solana_kit_address_constants_

The workspace now tracks `solana-program/memo` at `js@v0.14.1` (previously `js@v0.13.1`). The `mpl-token-metadata` reference pin also moves to `353d01be4af3`; its IDL is byte-identical, so that package is unaffected.

`solana_kit_address_constants` moves `memoProgramAddress` to the v4 memo program (`Memo4c2pN8afCj432Lb7RMVKi9PbQnnW7ewFFaV3oAH`), matching the upstream IDL `publicKey` as of `js@v0.14.0`. The previous v3 address stays available as the new `memoLegacyProgramAddressV3` constant, and `memoLegacyProgramAddress` (v1) is unchanged. Code that builds new memo instructions picks up the v4 program automatically; code that must keep targeting v3 names the legacy constant explicitly.

`solana_kit_memo` ports the upstream extraction helpers from `js@v0.14.1`:

- `getMemosFromInstructions` scans a list of instructions, matches every deployed Memo program address, and returns the UTF-8 decoded memo text with the raw bytes, source program address, and instruction index.
- `ExtractedMemo` carries one extracted memo.
- `supportedMemoProgramAddresses` lists every deployed Memo program address ordered from oldest (v1) to newest (v4).

The generated layer is regenerated against `js@v0.14.1` with the current renderer: the program page is byte-identical because the program address flows through the well-known constants, and the AddMemo data decoder now validates byte length strictly, throwing `SolanaError` with `codecsInvalidByteLength` on trailing bytes. `solana_kit_errors` moves from a dev dependency to a dependency because the generated decoder references it.

`codama-renderers-dart` maps the v4 address to `memoProgramAddress` and the v3 address to `memoLegacyProgramAddressV3` in its well-known address registry, so regenerated clients re-export the canonical constants instead of hardcoding address strings.

Build new memo instructions against `memoProgramAddress` (v4). Where a memo must be executed by a program the runtime provides, check what is deployed: SurfPool, used by this repository's on-chain integration tests, ships the v1 and v3 programs as executable bytecode but resolves v4 to a placeholder, so those tests invoke `memoLegacyProgramAddressV3`. All three programs share the same instruction format, so only the program the transaction targets differs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [9dcb59a](https://github.com/openbudgetfun/solana_kit/commit/9dcb59a09c4b13fc471a286612da570a8141e3c7)

#### Add 256-bit number codecs and tap codec helpers

_Packages:_ _solana_kit_codecs_core_, _solana_kit_codecs_numbers_

Ports the two additive codec surfaces from upstream `@solana/kit` v8.3.0.

`solana_kit_codecs_numbers` gains 256-bit integer codecs: `getU256Codec`, `getU256Encoder`, and `getU256Decoder` for unsigned values in `[0, 2^256 - 1]`, plus `getI256Codec`, `getI256Encoder`, and `getI256Decoder` for signed values in `[-(2^255), 2^255 - 1]`. Both serialize as 32 bytes, honour the `endian` option, and always decode to `BigInt`, matching the existing 64-bit and 128-bit codecs.

`solana_kit_codecs_core` gains tap helpers that observe values or bytes without modifying them. Because any callback may throw, they double as validation guards that need no identity `transformEncoder`:

```dart
final guarded = tapDecoderBytes(getU8Decoder(), (bytes, offset) {
  if (bytes[offset] > 1) throw StateError('Expected a 0 or a 1');
});

final spanned = tapEncoderBytes(getU8Encoder(), (bytes, pre, post) {
  print('wrote ${post - pre} bytes at $pre');
});
```

`tapEncoder`, `tapDecoder`, and `tapCodec` observe values; `tapEncoderBytes`, `tapDecoderBytes`, and `tapCodecBytes` observe bytes and offsets. Each wrapper preserves the size characteristics of the codec it wraps, so `FixedSizeEncoder` stays fixed-size and `VariableSizeEncoder` keeps its `maxSize`.

Note that Dart's `Codec` is not an `Encoder` or a `Decoder`, so the value-level wrappers are typed against the encoder or decoder they observe; use `tapCodec` and `tapCodecBytes` to wrap a codec.

_Owner:_ Ifiok Jr. · _Introduced in:_ [220066e](https://github.com/openbudgetfun/solana_kit/commit/220066ecb27aa738fd787ac8ada3918540435cc1)

#### Add the upstream size-prefix and UTF-8 codec options

_Packages:_ _solana_kit_codecs_data_structures_, _solana_kit_codecs_strings_

Ports the last two surfaces from upstream `@solana/kit` v8.3.0. Both are additive: no existing behavior changes.

`requireSizePrefix` is a named parameter on `getArrayDecoder`, `getArrayCodec`, `getSetDecoder`, `getSetCodec`, `getMapDecoder`, and `getMapCodec`. Upstream defaults it to `false`, where an exhausted byte array decodes as an empty collection so a collection can be appended to an existing layout. This port defaults it to `true` and throws, because a silently empty collection hides truncated input. Pass `requireSizePrefix: false` to opt in:

```dart
final lenient = getArrayCodec(getU8Codec(), requireSizePrefix: false);
lenient.decode(Uint8List(0)); // []
getArrayCodec(getU8Codec()).decode(Uint8List(0)); // throws
```

`Utf8CodecConfig` is accepted by `getUtf8Encoder`, `getUtf8Decoder`, and `getUtf8Codec`, and carries upstream's three options:

- `fatal` rejects malformed input instead of replacing it. Upstream defaults to `false`, decoding bad bytes as `U+FFFD`; this port defaults to `true` and raises a `FormatException` from decoding and, for lone surrogates, from encoding.
- `ignoreBOM` preserves a leading byte order mark. Both default to `false`, which strips it, matching Dart's `Utf8Decoder`.
- `removeNullCharacters` strips `U+0000` from decoded strings. Upstream defaults to `true`; this port defaults to `false` so the decoded value reflects the bytes exactly.

The two divergent defaults exist so that malformed or null-padded account and instruction data cannot decode silently. To take upstream's behavior explicitly:

```dart
final codec = getUtf8Codec(
  const Utf8CodecConfig(fatal: false, removeNullCharacters: true),
);
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [cf4ab87](https://github.com/openbudgetfun/solana_kit/commit/cf4ab873e32bb2ce2f4fe69e73fbc8aa6162894b)

#### Align error code numbers with upstream and report malformed UTF-8 as a code

_Packages:_ _solana_kit_codecs_strings_

`SolanaErrorCode` numbers now match upstream `@solana/kit` exactly. Two port-only codes were occupying numbers upstream uses for its UTF-8 codes, which made any cross-SDK comparison of those numbers wrong.

The UTF-8 codec also stops raising a bare `FormatException` and reports through the error codes upstream defines:

- `codecsInvalidUtf8Bytes` (`8078026`) for a malformed byte sequence, carrying the `offset` where decoding failed.
- `codecsInvalidUtf8String` (`8078027`) for a lone surrogate, carrying its `index`. This is thrown when encoding with `fatal: true` and, with `fatal: false`, both directions keep replacing the offending unit with `U+FFFD`.

Two port-only codes moved or went away:

- `codecsInvalidBoolean` moved from `8078027` to `8078999`. The number had to change because `8078027` is upstream's `CODECS__INVALID_UTF8_STRING`. This port validates that booleans are encoded as `0` or `1` and upstream does not, so the code has no upstream counterpart and now sits at the end of the codec block, where upstream cannot collide with it. If you match on `SolanaErrorCode.codecsInvalidBoolean.value`, update the number; matching on the enum member is unaffected.
- `codecsStringContainsNullCharacters` was removed. Nothing in the workspace threw it, and upstream has no equivalent. Use `Utf8CodecConfig.removeNullCharacters` to control null handling instead.

```dart
try {
  getUtf8Decoder().decode(bytes);
} on SolanaError catch (error) {
  if (error.code == SolanaErrorCode.codecsInvalidUtf8Bytes) {
    print('bad bytes at ${error.context['offset']}');
  }
}
```

`solana_kit_memo`, `solana_kit_offchain_messages`, and `solana_kit_attestation_service` only had tests asserting the old `FormatException` for malformed UTF-8; those assertions now check the error code, and `solana_kit_memo` declares the `solana_kit_errors` dev dependency that needs.

`upstream:error-codes`, which also runs as part of `docs:check`, compares this enum against `.repos/kit/packages/errors/src/codes.ts` and fails on a number mismatch or an occupied number, so this cannot drift again without CI saying so.

_Owner:_ Ifiok Jr. · _Introduced in:_ [a8f643f](https://github.com/openbudgetfun/solana_kit/commit/a8f643f1ae7e6594fbfa972d473f7042b1f6ace0)

### Fixes

#### Add scoped mutation testing tooling

_Packages:_ _solana_kit_

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

_Owner:_ Ifiok Jr. · _Introduced in:_ [186ba3d](https://github.com/openbudgetfun/solana_kit/commit/186ba3d9b982b64f6d32156d41f59465fc5770b2)

#### Restore complete version inventories in package READMEs

_Packages:_ _solana_kit_anchor_, _solana_kit_jupiter_, _solana_kit_mpl_core_, _solana_kit_mpl_token_metadata_, _solana_kit_pyth_, _solana_kit_sns_, _solana_kit_squads_

The `versions.json` data source that renders every package README's installation section had drifted: packages first released after the legacy knope era were never added, so their READMEs told consumers to depend on a bare `^` with no version. The retired `solana_kit_functional` entry and a stale `solana_kit_mobile_wallet_adapter_example` version were also lingering.

The inventory now matches every package's `pubspec.yaml`, the `solana_kit_functional` key is gone, and the affected installation sections render the real published version again:

```yaml
dependencies:
  "solana_kit_jupiter": ^0.9.3
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [4c8855b](https://github.com/openbudgetfun/solana_kit/commit/4c8855bd608bb9f05324b001b552c9329679e441)

#### Verify both hand-written SHA-256 implementations against an independent hash

_Packages:_ _solana_kit_anchor_, _solana_kit_sns_

`solana_kit_anchor` and `solana_kit_sns` each carry their own pure-Dart SHA-256. Anchor uses it to derive program discriminators and SNS to derive name account addresses, so a defect in either changes which instruction or account a program resolves to — a wrong result rather than an exception. Both were covered only by a handful of fixed NIST vectors, which pin the round function but rarely land on the padding and block boundaries where a length bug hides.

Each package now has a `sha256_differential_test.dart` comparing its implementation against `package:crypto` (the same dependency `solana_kit_addresses` already uses). Coverage includes every input length from 0 to 200, which crosses the 55/56-byte padding transitions and the 64-byte block boundary, lengths from 255 through 10000 for multi-block behavior, randomized inputs, and all-zero and all-`0xff` buffers. Anchor additionally checks `instructionDiscriminator` against the truncated namespaced digest, and SNS checks `getHashedName` against `sha256("SPL Name Service" + name)`.

Both implementations agree with the reference on every case. No library behavior changes.

_Owner:_ Ifiok Jr. · _Introduced in:_ [f21cd21](https://github.com/openbudgetfun/solana_kit/commit/f21cd21d26750d70f0c72e6acf8440346cf8175e)

#### Speed up base-X codecs, BigInt JSON parsing, and fixed-point parsing

_Packages:_ _solana_kit_addresses_, _solana_kit_codecs_strings_, _solana_kit_fixed_points_, _solana_kit_rpc_spec_types_, _solana_kit_transaction_messages_

Same results, less work per call. No public API, output byte, or error behavior changed; `upstream:parity` passes against `@solana/kit@8.3.0` and the full workspace suite is green.

The base-X codecs converted through `BigInt`, scaled the alphabet with `String.indexOf` and a fresh one-character string per input character, and built output with repeated `insert(0, …)` calls that reallocate and shift the whole list each time. Encoding a typical base58 address cost roughly 600 µs, so compiling a 20-account transaction spent measurable milliseconds on address encoding alone. The conversion now folds digits into a byte buffer with word-sized carry arithmetic, indexes the alphabet through a cached code-unit lookup, and writes output in order:

```dart
// Before: BigInt division per character plus O(n²) list inserts.
// After: one carry pass per character over a preallocated buffer.
final converted = _convertToBytes(value, alphabet);
bytes
  ..fillRange(offset, offset + converted.leadingZeroes, 0)
  ..setAll(offset + converted.leadingZeroes, converted.bytes);
```

Measured on an interleaved best-of-N benchmark, with the previous implementation running in the same process to cancel machine noise:

| Operation                        | Before   | After   | Improvement |
| -------------------------------- | -------- | ------- | ----------- |
| base58 encode, typical address   | 22.97 µs | 2.88 µs | 8.0x        |
| base58 decode, 32 bytes          | 16.79 µs | 3.24 µs | 5.2x        |
| base58 encode, 64-byte signature | 52.89 µs | 8.44 µs | 6.3x        |

`parseJsonWithBigInts` allocated a one-character string and ran up to two regular expressions per character of the payload, then rebuilt the document character by character. It now scans by code unit, copies literal runs as substrings, and hoists the exponent pattern:

| Operation                 | Before   | After    | Improvement |
| ------------------------- | -------- | -------- | ----------- |
| parse a 28 KB RPC payload | 2.198 ms | 1.089 ms | 2.0x        |

Also removed in the same pass: a redundant full copy in the UTF-8 encoder and the base64 decoder (both `utf8.encode` and `base64.decode` already return `Uint8List`), a double copy of every version-1 instruction payload, and two regular expressions that were compiled per parsed value in the fixed-point codecs.

Behavior is pinned by tests rather than assumed. `base_x_property_test.dart` round-trips random byte strings across every length from 0 to 512 bytes, covers leading-zero-only input, alphabets wider than a byte, and non-power-of-two alphabets, and asserts arbitrary-precision digit strings beyond 64 bits. A degenerate one-character alphabet is now rejected with an `ArgumentError` when the codec is created; previously it produced silent zero output on encode and looped forever on decode.

`bench:all` also gains coverage where the regression was invisible: the address benchmark previously measured only the all-ones System Program address, which is base58's leading-zero fast path and exercises no base conversion at all.

_Owner:_ Ifiok Jr. · _Introduced in:_ [b22257e](https://github.com/openbudgetfun/solana_kit/commit/b22257e1d1cb146eda742cd3da352b6a90a49f1d)

#### Reject truncated numeric reads with `SolanaError` instead of `RangeError`

_Packages:_ _solana_kit_codecs_numbers_, _solana_kit_transaction_messages_, _solana_kit_transactions_

A decoder reading a fixed-width field out of malformed wire data could raise a raw `RangeError` or `IndexError` out of the SDK instead of the documented `SolanaError`, so a caller catching `SolanaError` saw an escaped exception rather than a rejection it could handle. A truncated account, transaction, or RPC payload reaching the decoders was enough to trigger it; no signature or cluster access was required.

The guard that upstream `@solana/kit` applies in its number decoder factory was missing from three ports of it. `numberDecoderFactory` and `floatDecoderFactory` read through a `ByteData` view without first checking that the requested width was available, and the six `BigInt` decoders (`u64`, `i64`, `u128`, `i128`, `u256`, `i256`) indexed bytes directly with the same gap. All eight now call `assertByteArrayIsNotEmptyForCodec` and `assertByteArrayHasEnoughBytesForCodec` before reading, raising `codecsCannotDecodeEmptyByteArray` or `codecsInvalidByteLength` as upstream does. A new `bigIntDecoderFactory` carries the guard for the multi-word widths.

Two further escape sites in `solana_kit_transaction_messages` are fixed. The version 1 instruction payload slice computed `pos + numInstructionDataBytes` and sliced without confirming the buffer held that many bytes; it now asserts the length the way upstream's `fixDecoderSize` wrapper does. The transaction version decoder read `bytes[offset]` unguarded — upstream tolerates this because JavaScript yields `undefined`, which then silently takes the legacy branch and misreports a truncated buffer as an unversioned message, so this port rejects the empty buffer rather than reproducing that fallback.

Encoders are unchanged and still raise `RangeError` when a destination buffer is too small. Upstream writes into a scratch buffer and then `bytes.set`s it, which throws in JavaScript too, so that behavior is deliberate parity rather than a defect.

Callers that caught `RangeError` around a decode should catch `SolanaError`. Callers that already caught `SolanaError` now see malformed input rejected where it previously surfaced as a crash.

_Owner:_ Ifiok Jr. · _Introduced in:_ [f21cd21](https://github.com/openbudgetfun/solana_kit/commit/f21cd21d26750d70f0c72e6acf8440346cf8175e)

#### Track @solana/kit v8.3.0

_Packages:_ _solana_kit_errors_

The workspace now tracks upstream `@solana/kit` v8.3.0 (previously v8.2.0), and `upstream:parity` passes against it. This entry maps every change in that upstream release to its Dart counterpart.

Ported in this release:

- `u256` and `i256` number codecs (`getU256Codec`, `getI256Codec` and their encoder/decoder pairs) serialize 32 bytes, honour the `endian` option, validate the full range on encode, and decode to `BigInt`, mirroring the existing 64-bit and 128-bit codecs.
- Tap codec helpers observe values or bytes without modifying them: `tapEncoder`, `tapDecoder`, and `tapCodec` observe values, while `tapEncoderBytes`, `tapDecoderBytes`, and `tapCodecBytes` observe raw bytes and offsets. Each wrapper preserves the size characteristics of what it wraps, and any tap may throw, which makes them validation guards that need no identity `transformEncoder`.

Already present before this release, and now covered by the v8.3.0 claim:

- The `getAgGenesisCert` RPC method and its allowed numeric keypaths.
- `isSolanaRequest` recognising `getAgGenesisCert` and `getTransactionsForAddress`, which is also what fixed upstream's `bigint` parsing for `getTransactionsForAddress` responses.

No Dart change needed:

- `HasAddress` and the `InstructionAccountInput` / `InstructionSignerInput` widening are TypeScript type-level changes. Dart has no structural typing, and this port's `ResolvedInstructionAccount` already wraps an `Object` value, so it accepts addresses, address-bearing objects, `ProgramDerivedAddress` values, and `AccountMeta` role overrides at runtime without a cast.
- Marking `role` as `readonly` on the writable and signer account types is already true here: `AccountMeta.role` is a `final` field.
- `createLazyKeyPairSignerFromBytes` exists upstream to defer an asynchronous WebCrypto key import. Signer creation in this port is synchronous, so there is nothing to defer and the type is not needed.

Verification:

- `upstream:parity` passes against `@solana/kit@8.3.0`
- `upstream:check` reports the metadata is internally consistent for tracked version 8.3.0
- The `@solana/kit` reference pin moved to tag `v8.3.0`

_Owner:_ Ifiok Jr. · _Introduced in:_ [220066e](https://github.com/openbudgetfun/solana_kit/commit/220066ecb27aa738fd787ac8ada3918540435cc1)

#### Raise the Dart and Flutter baseline

_Packages:_ _solana_kit_test_matchers_

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

#### Add version 1 transaction coverage with oversized payloads

_Packages:_ _solana_kit_transactions_

Adds regression tests for the version 1 transaction wire format introduced by SIMD-0296 and SIMD-0385, which raise the transaction size ceiling from 1232 to 4096 bytes.

`packages/solana_kit_transactions/test/v1_transaction_test.dart` pins the exact bytes against vectors generated by upstream `@solana/kit` 8.3.0, so a regression in the v1 envelope, config mask, or config value encoding fails loudly instead of silently producing transactions the cluster rejects. The vectors live in `test/fixtures/v1_wire_vectors.json`, alongside a README documenting how to regenerate them; the largest asserts a 3216-byte transaction byte-for-byte, which no legacy transaction can represent.

On-chain coverage lands in `packages/solana_kit_integration_tests/test/integration/v1_transaction_test.dart`. It submits a v1 transaction with a 1600-byte memo — over the legacy ceiling — and asserts the node accepts it, recovers the full memo, reports the inline `transactionConfig` with the requested compute unit and loaded accounts limits, and moves lamports. The same suite asserts the node rejects a payload above 4096 bytes.

A second on-chain suite, `resource_limit_estimation_test.dart`, submits a v1 transaction whose limits were produced by `estimateResourceLimitsFactory` and asserts the node executes it.

`IntegrationTestEnv` gains `sendV1Instructions` and `buildV1WireTransaction` helpers, and `fetchTransaction` now requests `maxSupportedTransactionVersion: 1` so v1 responses can be read back rather than failing with RPC error `-32015`. No public library behavior changes.

_Owner:_ Ifiok Jr. · _Introduced in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

## [0.9.3](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.3) (2026-09-12)

Grouped release for `main`.

### Features

#### Add the Solana Attestation Service program client

_Packages:_ _solana_kit_address_constants_

Introduces `solana_kit_attestation_service`, a generated program client for the Solana Attestation Service, the on-chain protocol for verifiable credentials where issuers register credentials, declare schemas, and issue attestations that verifiers can fetch and decode.

The package ships generated instruction builders and parsers for all 12 instructions, codecs for the `Credential`, `Schema`, and `Attestation` accounts with their 1-byte discriminators, the seven program PDAs (credential, schema, attestation, schema mint, attestation mint, event authority, and SAS authority), the `AttestationServiceError` codes with an `isAttestationServiceError` matcher, and a schema-driven codec that serializes and deserializes an attestation's raw `data` blob against its schema layout, including Rust `char` code points and lossless hex fallbacks for non-UTF-8 string bytes.

```dart
final (credential, _) = await findCredentialPda(
  seeds: const CredentialSeeds(authority: authority, name: 'my-credential'),
);
final data = serializeAttestationData(schema, {'name': 'Alice', 'age': 42});
```

`solana_kit_address_constants` gains the canonical `solanaAttestationServiceProgramAddress` constant.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #251](https://github.com/openbudgetfun/solana_kit/pull/251)

### Fixes

- _Packages:_ _solana_kit_codecs_, _solana_kit_fixed_points_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_types_ **Document program errors and the generated program-client contract.** Add library doc comments synchronized from shared MDT sections to thirteen packages: program error matching (`isProgramError` + `TransactionMessageInput`) and the generated program-client API shape are now documented inline in each library and in the errors docs page; six barrels that had no library doc comment gain one; three one-line library headers are expanded. No code changes. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #248](https://github.com/openbudgetfun/solana_kit/pull/248)

## [0.9.2](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.2) (2026-09-06)

Grouped release for `main`.

### 🚀 Feature

#### Track @solana/kit v8.2.0

_Packages:_ _solana_kit_, _solana_kit_instruction_plans_, _solana_kit_rpc_api_

The workspace now tracks upstream `@solana/kit` v8.2.0 and the parity harness passes against it.

- New `getAgGenesisCert` RPC method returning the Alpenglow genesis certificate (or `null`), with allowed numeric keypaths that keep `blockId`, `bitmap`, and `signature` byte arrays as numbers while upcasting `slot` to `BigInt`.
- `isSolanaRequest` recognizes `getAgGenesisCert` and the previously missed `getTransactionsForAddress`.
- New `createTransactionPlanExecutorWithConcurrentLeaves` mirroring upstream: every leaf starts concurrently (including across sequential plans), a failed leaf does not cancel siblings, non-divisible sequential plans are supported, and the executor builds results from the shared callback contract — context stored on the mutable map is preserved on failures.

Reference pins refreshed to the latest upstream tags (compute-budget v0.18.1, memo v0.13.1, token v0.16.1, token-2022 v0.16.1, stake v0.9.1, address-lookup-table v0.14.1, system v0.14.1, loader-v3 v0.6.1 — all packaging-only upstream changes), and the Codama renderer dependencies moved to codama 1.10.2 / renderers-core 1.4.0.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #239](https://github.com/openbudgetfun/solana_kit/pull/239)

### 🐛 Fixed

#### Update the README upstream compatibility claim

_Packages:_ _solana_kit_

The `solana_kit` README now states the latest supported `@solana/kit` version as `8.2.0` and that this Dart port tracks upstream APIs and behavior through `v8.2.0`, matching the claims already propagated across the root readme and the docs site.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #240](https://github.com/openbudgetfun/solana_kit/pull/240) · _Related issues:_ [#239](https://github.com/openbudgetfun/solana_kit/issues/239)

#### Preserve account identities during batch fetches

_Packages:_ _solana_kit_accounts_

Snapshot requested addresses before sending batch account requests, so changing the input list while the request is pending cannot attach returned account data to a different address or discard requested results. This applies to both encoded and JSON-parsed account fetches.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Validate Anchor and Pyth event data

_Packages:_ _solana_kit_anchor_, _solana_kit_pyth_

Validate Anchor event provenance against the IDL program's runtime invocation stack, ignoring foreign-program and embedded-message event forgeries. Bound Hermes price conversion work for extreme untrusted exponents to prevent application stalls.

Preserve all 64 bits of unsigned Pyth confidence and slot fields so large confidence intervals cannot become negative and bypass application upper-bound checks.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Restore Anchor runtime error compatibility

_Packages:_ _solana_kit_anchor_

Align the standard Anchor error table with `anchor-lang` 0.31.1 so errors returned by deployed Anchor programs resolve to the correct code, name, and message.

Add live Surfpool compatibility coverage for Anchor, Metaplex Core, Metaplex Token Metadata, Squads V4, RPC subscriptions, transaction introspection, lookup tables, instruction plans, and transaction immutability.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #243](https://github.com/openbudgetfun/solana_kit/pull/243)

#### Harden key verification and publication

_Packages:_ _solana_kit_addresses_, _solana_kit_keys_

Reject small-order Ed25519 public keys and signature nonce points, including non-canonical aliases, to prevent weak-key signature forgery. Publish key files from a mode-`0700` staging directory so destination replacement cannot redirect secret bytes and readers of a file reservation cannot retain access to the completed key file.

Correct PDA documentation to state that callers may supply at most 15 seeds, reserving the sixteenth seed for the automatically appended bump.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Validate codec boundaries and compact lengths

_Packages:_ _solana_kit_codecs_core_, _solana_kit_codecs_numbers_

Numeric codecs now keep reads and writes within the supplied byte view, preventing access to adjacent backing-buffer data. Short-u16 decoders reject overflowing values and overlong aliases so malformed compact lengths cannot be accepted as valid Solana wire data. Size-prefixed decoders reject negative, fractional, non-finite, and oversized lengths before decoding their contents.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Bound array decoding from untrusted bytes

_Packages:_ _solana_kit_codecs_data_structures_

Reject missing, invalid, and excessive array counts, and stop remainder decoders that fail to consume input. Callers can set a smaller `maxItems` limit for application-specific formats.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Validate option and hexadecimal wire inputs

_Packages:_ _solana_kit_codecs_strings_, _solana_kit_options_

Reject invalid option presence flags, truncated None padding, and mismatched constant None markers. Reject incomplete hexadecimal byte pairs that previously lost their final character and returned incorrect write offsets.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Validate fixed-point ranges

_Packages:_ _solana_kit_fixed_points_

Reject signed fixed-point values outside their declared range before encoding, preventing positive and negative values from wrapping into the opposite sign on the wire. Validate fixed-point shapes in assertion helpers and reject digit-free decimal input instead of parsing it as zero. Add regression tests for both fixed-point representations, byte orders, and signed range boundaries.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Secure Jupiter transport and repair Swap v2 and Token v2 flows

_Packages:_ _solana_kit_jupiter_

Require HTTPS by default, reject credentials embedded in base URLs, and disable HTTP redirects so API keys and signed transactions cannot be forwarded to another origin. Explicitly trusted development endpoints can opt into HTTP with `allowInsecureHttp`.

Send the documented managed-execution payload, require an order request ID, expose execution status and result codes, and support the taker required to assemble swaps. Preserve Swap v2 lookup tables, additional and tip instructions, and blockhash metadata. Correct token-tag queries and category/interval paths, validate category inputs, and reject malformed price responses instead of treating them as empty markets.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Preserve instructions across transaction packing

_Packages:_ _solana_kit_instruction_plans_

Keep overflowing instructions pending for the next message instead of returning oversized messages that can lose already packed instructions. Abort planning if a message update overflows after a stateful packer has consumed instructions, preserving transaction-plan integrity.

Preserve the original execution error and partial result tree when an executor callback fails with an unsigned transaction in its context, so callers can still identify earlier successful transactions.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Remove stale deprecation lint suppressions

_Packages:_ _solana_kit_instruction_plans_, _solana_kit_rpc_parsed_types_

Drop ignore comments for `remove_deprecations_in_breaking_versions` that no longer suppress anything after the version transition to a non-breaking release.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d6b4f6c`](https://github.com/openbudgetfun/solana_kit/commit/d6b4f6cbf0e3a22498ffb7593d3242eaff1e53b9)

#### Honor RPC HTTP cancellation and protect credentials

_Packages:_ _solana_kit_rpc_, _solana_kit_rpc_transport_http_

Honor RPC cancellation signals while sending HTTP requests and streaming response bodies. Keep requests with cancellation signals independent so cancelling one caller cannot cancel another caller's request. Require `http` 1.5 or newer for native request abortion support.

Reject HTTP redirects without forwarding custom authentication headers to the redirect destination.

Prevent connection, cancellation, and response-stream HTTP exceptions from exposing credentials embedded in endpoint URLs or client error messages.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Track @solana/kit v8.2.0

_Packages:_ _solana_kit_rpc_, _solana_kit_rpc_transport_http_

The workspace now tracks upstream `@solana/kit` v8.2.0 and the parity harness passes against it.

- New `getAgGenesisCert` RPC method returning the Alpenglow genesis certificate (or `null`), with allowed numeric keypaths that keep `blockId`, `bitmap`, and `signature` byte arrays as numbers while upcasting `slot` to `BigInt`.
- `isSolanaRequest` recognizes `getAgGenesisCert` and the previously missed `getTransactionsForAddress`.
- New `createTransactionPlanExecutorWithConcurrentLeaves` mirroring upstream: every leaf starts concurrently (including across sequential plans), a failed leaf does not cancel siblings, non-divisible sequential plans are supported, and the executor builds results from the shared callback contract — context stored on the mutable map is preserved on failures.

Reference pins refreshed to the latest upstream tags (compute-budget v0.18.1, memo v0.13.1, token v0.16.1, token-2022 v0.16.1, stake v0.9.1, address-lookup-table v0.14.1, system v0.14.1, loader-v3 v0.6.1 — all packaging-only upstream changes), and the Codama renderer dependencies moved to codama 1.10.2 / renderers-core 1.4.0.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #239](https://github.com/openbudgetfun/solana_kit/pull/239)

#### Harden RPC JSON integer boundaries

_Packages:_ _solana_kit_rpc_spec_types_

Preserve user JSON objects instead of interpreting `$n` fields as BigInt markers when parsing responses or serializing requests. Reject positive integer exponents above 10,000 before expansion to bound resource use from compact untrusted JSON, while preserving exact normal-range integers, strict JSON syntax, and cyclic-value errors.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Recover failed RPC subscription cache entries

_Packages:_ _solana_kit_rpc_subscriptions_

Recover subscription acquisition after transport failures, prevent repeated errors from evicting a replacement subscription, and reuse channel capacity released while the subscription pool was full.

Handle native channel stream errors in subscription coalescing, channel pooling, and keepalive pinging so failed connections are cleaned up without uncaught asynchronous errors.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Fix subscription protocol and URL validation

_Packages:_ _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_channel_websocket_

Execute the default Solana subscription JSON-RPC handshake, validate its server subscription ID, isolate notifications on pooled channels, and send unsubscribe requests during cancellation. Preserve notifications received during acquisition with a bounded initial buffer and route protocol, channel, and decoding failures to subscribers.

Normalize WebSocket destination literals before applying private-host protection, covering expanded and hexadecimal IPv4-mapped IPv6 forms and trailing DNS root dots without rejecting public hostnames that resemble IPv6 prefixes.

Reject cancelled WebSocket handshakes promptly, close late connections, reject sends after cancellation, and finish public streams when their channel ends.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Protect transaction signing integrity

_Packages:_ _solana_kit_signers_, _solana_kit_transactions_

Freeze transaction message and signature buffers so retained references cannot change reviewed signing payloads. Decode v1 message-first transaction envelopes with the correct signature ordering. Preserve v1 configuration when attaching signers and honor fee payer address replacements without retaining the old fee payer signer.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Propagate stream errors and cancellation

_Packages:_ _solana_kit_subscribable_

Contain native source errors and malformed notification type/transformer failures within subscription streams, where consumer error handlers can receive them. Release reactive connection listeners when caller cancellation fires, and avoid opening a connection after a loading subscriber resets or disposes its store.

Fix reactive stream bridge cancellation while awaiting a quiet store, unsubscribe after predicate failures, and preserve latest-value delivery and error precedence while consumers are paused.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Fix confirmation subscription lifecycle

_Packages:_ _solana_kit_transaction_confirmation_

Settle cancelled confirmation strategies, propagate subscription failures and unexpected closure, and preserve slot notifications received during the initial block-height lookup.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Validate introspected account metadata

_Packages:_ _solana_kit_transaction_introspection_

Reject loaded-address counts that disagree with compiled lookup tables before resolving account indices, preventing malformed RPC metadata from shifting account identities and roles. Reject duplicate inner-instruction groups instead of emitting repeated execution traces.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Preserve inspected transaction message data

_Packages:_ _solana_kit_transaction_messages_

Preserve v1 instructions, transaction version, and resource and priority fee configuration during decompilation. Reject inconsistent v1 instruction payloads and configuration values. Keep declared signer accounts static and materialize lookup accounts correctly when compiling legacy and v1 messages, preventing signer privilege loss and invalid account layouts.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

## [0.9.1](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.1) (2026-08-30)

Grouped release for `main`.

### 🐛 Fixed

#### Fix publish validation for ecosystem packages

_Packages:_ _solana_kit_anchor_, _solana_kit_jupiter_, _solana_kit_mpl_core_, _solana_kit_mpl_token_metadata_, _solana_kit_squads_

Declare the `meta` and `solana_kit_accounts` dependencies that the generated Squads and mpl-token-metadata clients import, so `dart pub publish` validation passes, and normalize `readme.md` to `README.md` across the ecosystem packages to satisfy the pub README requirement.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a53391f`](https://github.com/openbudgetfun/solana_kit/commit/a53391f69a4668422096a31bcac46397770a5d33)

## [0.9.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.9.0) (2026-08-30)

Grouped release for `main`.

### 💥 Breaking Change

#### Support Anchor programs in Dart

_Packages:_ _solana_kit_anchor_

Add the Anchor runtime package: Anchor sighash discriminators (`sha256("namespace:name")[0..8]`), Anchor IDL 0.30 parsing, a dynamic coder that builds account, instruction, and event codecs from an IDL at runtime, a pure-Dart SHA-256, and Anchor error resolution against the standard table plus program-defined IDL errors. Generic IDL type instantiations are rejected at codec-build time.

```dart
import 'package:solana_kit_anchor/solana_kit_anchor.dart';

final idl = AnchorIdlProgram.parse(idlJson);
final coder = AnchorCoder(idl);
final args = coder.encodeInstructionData('initialize', {
  'authority': authorityAddress,
});
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

#### Add the Jupiter Exchange client

_Packages:_ _solana_kit_jupiter_

Add the Jupiter Exchange client package: Swap API v2 (`/order`, `/execute`, `/build`), Price API v3, Token API v2, base64 transaction decoding, an injectable HTTP transport, and keyless or `x-api-key` authentication on `https://api.jup.ag`.

```dart
final jupiter = createJupiterClient(JupiterConfig(apiKey: 'key'));
final order = await jupiter.swap.getOrder(
  JupiterOrderRequest(
    inputMint: sol,
    outputMint: usdc,
    amount: BigInt.from(10000000),
  ),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

#### Add the Metaplex Core program client

_Packages:_ _solana_kit_mpl_core_

Add the mpl-core (Metaplex Core) program client generated from the metaplex-foundation shank IDL: 42 instruction builders, 6 account codecs, 57 error helpers, program-level instruction identification and parsing, and PDA derivations for the asset signer, preconfigured plugin accounts, dynamic extra accounts, and oracle accounts.

```dart
final (assetSigner, bump) = await findAssetSignerPda(asset: asset);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

#### Add the Token Metadata program client

_Packages:_ _solana_kit_mpl_token_metadata_

Add the mpl-token-metadata program client, generated with `codama-renderers-dart` from the metaplex-foundation shank IDL: 58 instruction builders, 14 account codecs, 203 error helpers, instruction identification and parsing, and PDA derivations for metadata, master editions, edition markers, collection and use authority records, token records, delegate records, and program-as-burner.

```dart
final (metadata, bump) = await findMetadataPda(mint: mint);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

#### Add the Pyth Network client

_Packages:_ _solana_kit_pyth_

Add the Pyth Network client package: the Hermes HTTP client (price feeds, binary price updates), Wormhole VAA and accumulator update parsing, Solana price-account and price-update-v2 decoders, `postUpdateAtomic`/`postUpdate` instruction builders for the Pyth Solana receiver program, and typed price-feed models.

```dart
final hermes = HermesClient(HermesConfig());
final feeds = await hermes.getLatestPriceFeeds([feedId]);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

#### Sync upstream `@solana/kit` v8.1.0

_Packages:_ _solana_kit_rpc_transformers_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Tracks upstream APIs and behavior through `v8.1.0`:

- **`solana_kit_transaction_messages` (breaking)**: removed the deprecated compute-unit-limit helpers `fillTransactionMessageProvisoryComputeUnitLimit` and `estimateAndSetComputeUnitLimitFactory`, matching upstream `@solana/kit`'s removal of the deprecated `@solana/kit` estimation helpers (#1948). Use `fillTransactionMessageProvisoryResourceLimits` and `estimateAndSetResourceLimitsFactory` instead, which additionally reserve and set the loaded accounts data size limit for version 1 transactions. `setTransactionMessageComputeUnitLimit` and `setTransactionMessageConfig` now reject compute unit limits the runtime will not honor — an integer outside `[0, 1400000]` — throwing `SolanaErrorCode.transactionComputeUnitLimitOutOfRange`, and reject invalid heap sizes — not a multiple of 1024 bytes in `[32768, 262144]` — throwing `SolanaErrorCode.transactionInvalidHeapSize` (upstream #1972). Added the upstream `heap-size.ts` module as `getTransactionMessageHeapSize`/`setTransactionMessageHeapSize` with the same validation, and `resource_limit_validation.dart` with `assertIsValidComputeUnitLimit`/`assertIsValidHeapSize`, `minHeapSize`, `maxHeapSize`, and `heapSizeMultipleOf`. Decoding is unaffected: `decompileTransactionMessage` still returns messages carrying out-of-range values.

  Migration:
  - `fillTransactionMessageProvisoryComputeUnitLimit(m)` → `fillTransactionMessageProvisoryResourceLimits(m)`.
  - `estimateAndSetComputeUnitLimitFactory(estimate)` → `estimateAndSetResourceLimitsFactory(estimateResourceLimitsFactory(estimate))`.
- **`solana_kit_transactions` (breaking)**: removed the fixed-size constants `transactionPacketSize`, `transactionPacketHeader`, and `transactionSizeLimit`, matching upstream's removal of `TRANSACTION_PACKET_SIZE`, `TRANSACTION_PACKET_HEADER`, and `TRANSACTION_SIZE_LIMIT` (#1948). Use `getTransactionSizeLimit` to derive the limit for a specific transaction, or the per-version constants `legacyTransactionSizeLimit` (1232) and `v1TransactionSizeLimit` (4096).

  Migration: `TRANSACTION_SIZE_LIMIT - getTransactionSize(t)` → `getTransactionSizeLimit(t) - getTransactionSize(t)`.
- `solana_kit_errors`: added the `failedToSignTransaction` (13) and `failedToSignTransactions` (14) error codes with upstream messages, plus the transaction codes `transactionComputeUnitLimitOutOfRange` (5663039) and `transactionInvalidHeapSize` (5663040) (upstream #1902, #1972).
- `solana_kit_instruction_plans`: added `createFailedToSendTransactionError`, `createFailedToSendTransactionsError`, `createFailedToSignTransactionError`, `createFailedToSignTransactionsError`, and `createFailedToExecuteTransactionPlanError`, mirroring upstream `@solana/instruction-plans`' `transaction-plan-errors.ts` (#1902, #1434). The signing factories carry the same non-enumerable `transactionPlanResult` and optional `logs`/`preflightData` context as their sending counterparts, but the message includes no submission-location indicator because signing never submits. The executor now throws through `createFailedToExecuteTransactionPlanError`.
- `solana_kit`: added the `ClientWithTransactionSending` and `ClientWithTransactionSigning` client interfaces, mirroring upstream `@solana/plugin-interfaces` (#1899). `signTransaction`/`signTransactions` accept the same flexible inputs as their sending counterparts and return signed transactions without submitting them. Sending results guarantee a signature-bearing `context`; signing makes no default guarantee about the context, matching the upstream `TContext` parameterization (adapted to Dart's map-based result contexts).
- **`solana_kit_rpc_transformers` (breaking)**: removed `getBigIntDowncastRequestTransformer`, matching upstream #1948. It was no longer used by the default Solana RPC request transformer: the Solana RPC transport serializes `BigInt` values losslessly as large integer literals via `stringifyJsonWithBigInts`, and Agave parses JSON integers across the full `u64` range without precision loss, so downcasting `BigInt`s to (potentially lossy) `int`s is unnecessary. `getDefaultRequestTransformerForSolanaRpc` no longer downcasts; if you still need this behavior, recreate it with `getTreeWalkerRequestTransformer` and a visitor that replaces `BigInt` nodes with `int` values.
- `solana_kit_rpc_transformers`: the numeric allow-list keeps `transactionConfig.computeUnitLimit`, `transactionConfig.heapSize`, and `transactionConfig.loadedAccountsDataSizeLimit` from version 1 transaction responses as numbers instead of upcasting them to `BigInt` (upstream #1951).
- Documentation now tracks `@solana/kit` `v8.1.0`, and the reference pin in `config/reference-repos.json` moved to `bb54243d8a57` (tag `v8.1.0`).

Migration example:

```dart
// Before (removed):
// final estimate = estimateComputeUnitLimitFactory(rpc);
// var message = await estimateAndSetComputeUnitLimitFactory(estimate)(message);
// final freeBytes = transactionSizeLimit - getTransactionSize(transaction);

// After:
final estimate = estimateResourceLimitsFactory(rpc);
var message = await estimateAndSetResourceLimitsFactory(estimate)(message);
final freeBytes =
    getTransactionSizeLimit(transaction) - getTransactionSize(transaction);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #225](https://github.com/openbudgetfun/solana_kit/pull/225) · _Related issues:_ [#1899](https://github.com/openbudgetfun/solana_kit/issues/1899), [#1902](https://github.com/openbudgetfun/solana_kit/issues/1902), [#1910](https://github.com/openbudgetfun/solana_kit/issues/1910), [#1913](https://github.com/openbudgetfun/solana_kit/issues/1913), [#1948](https://github.com/openbudgetfun/solana_kit/issues/1948), [#1951](https://github.com/openbudgetfun/solana_kit/issues/1951), [#1957](https://github.com/openbudgetfun/solana_kit/issues/1957), [#1970](https://github.com/openbudgetfun/solana_kit/issues/1970), [#1971](https://github.com/openbudgetfun/solana_kit/issues/1971), [#1972](https://github.com/openbudgetfun/solana_kit/issues/1972), [#1979](https://github.com/openbudgetfun/solana_kit/issues/1979), [#220](https://github.com/openbudgetfun/solana_kit/issues/220)

#### Add the Solana Name Service client

_Packages:_ _solana_kit_sns_

Add the Solana Name Service client package: `.sol` domain key derivation (V1/V2 records, subdomains, sub-records), name registry codecs, record V1/V2 address derivation and content codecs, reverse-record helpers, pure-Dart SHA-256, and all protocol program-address constants from the official sns-sdk.

```dart
final domainKey = await findDomainKey('mysite');
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

#### Add the Squads V4 multisig client

_Packages:_ _solana_kit_squads_

Add the Squads V4 multisig program client, generated with `codama-renderers-dart` from the Squads-Protocol v4 Anchor IDL: 36 instruction builders, 9 account codecs, 45 error helpers, program-level parsing, and PDA derivations for multisigs, vaults, transactions, proposals, spending limits, and program config, with `newConfigAuthority` argument naming matching the upstream TS SDK.

```dart
final (multisig, bump) = await findMultisigPda(createKey: createKey);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

### 🚀 Feature

#### Sync upstream `@solana/kit` v8.1.0

_Packages:_ _solana_kit_, _solana_kit_errors_, _solana_kit_instruction_plans_

Tracks upstream APIs and behavior through `v8.1.0`:

- **`solana_kit_transaction_messages` (breaking)**: removed the deprecated compute-unit-limit helpers `fillTransactionMessageProvisoryComputeUnitLimit` and `estimateAndSetComputeUnitLimitFactory`, matching upstream `@solana/kit`'s removal of the deprecated `@solana/kit` estimation helpers (#1948). Use `fillTransactionMessageProvisoryResourceLimits` and `estimateAndSetResourceLimitsFactory` instead, which additionally reserve and set the loaded accounts data size limit for version 1 transactions. `setTransactionMessageComputeUnitLimit` and `setTransactionMessageConfig` now reject compute unit limits the runtime will not honor — an integer outside `[0, 1400000]` — throwing `SolanaErrorCode.transactionComputeUnitLimitOutOfRange`, and reject invalid heap sizes — not a multiple of 1024 bytes in `[32768, 262144]` — throwing `SolanaErrorCode.transactionInvalidHeapSize` (upstream #1972). Added the upstream `heap-size.ts` module as `getTransactionMessageHeapSize`/`setTransactionMessageHeapSize` with the same validation, and `resource_limit_validation.dart` with `assertIsValidComputeUnitLimit`/`assertIsValidHeapSize`, `minHeapSize`, `maxHeapSize`, and `heapSizeMultipleOf`. Decoding is unaffected: `decompileTransactionMessage` still returns messages carrying out-of-range values.

  Migration:
  - `fillTransactionMessageProvisoryComputeUnitLimit(m)` → `fillTransactionMessageProvisoryResourceLimits(m)`.
  - `estimateAndSetComputeUnitLimitFactory(estimate)` → `estimateAndSetResourceLimitsFactory(estimateResourceLimitsFactory(estimate))`.
- **`solana_kit_transactions` (breaking)**: removed the fixed-size constants `transactionPacketSize`, `transactionPacketHeader`, and `transactionSizeLimit`, matching upstream's removal of `TRANSACTION_PACKET_SIZE`, `TRANSACTION_PACKET_HEADER`, and `TRANSACTION_SIZE_LIMIT` (#1948). Use `getTransactionSizeLimit` to derive the limit for a specific transaction, or the per-version constants `legacyTransactionSizeLimit` (1232) and `v1TransactionSizeLimit` (4096).

  Migration: `TRANSACTION_SIZE_LIMIT - getTransactionSize(t)` → `getTransactionSizeLimit(t) - getTransactionSize(t)`.
- `solana_kit_errors`: added the `failedToSignTransaction` (13) and `failedToSignTransactions` (14) error codes with upstream messages, plus the transaction codes `transactionComputeUnitLimitOutOfRange` (5663039) and `transactionInvalidHeapSize` (5663040) (upstream #1902, #1972).
- `solana_kit_instruction_plans`: added `createFailedToSendTransactionError`, `createFailedToSendTransactionsError`, `createFailedToSignTransactionError`, `createFailedToSignTransactionsError`, and `createFailedToExecuteTransactionPlanError`, mirroring upstream `@solana/instruction-plans`' `transaction-plan-errors.ts` (#1902, #1434). The signing factories carry the same non-enumerable `transactionPlanResult` and optional `logs`/`preflightData` context as their sending counterparts, but the message includes no submission-location indicator because signing never submits. The executor now throws through `createFailedToExecuteTransactionPlanError`.
- `solana_kit`: added the `ClientWithTransactionSending` and `ClientWithTransactionSigning` client interfaces, mirroring upstream `@solana/plugin-interfaces` (#1899). `signTransaction`/`signTransactions` accept the same flexible inputs as their sending counterparts and return signed transactions without submitting them. Sending results guarantee a signature-bearing `context`; signing makes no default guarantee about the context, matching the upstream `TContext` parameterization (adapted to Dart's map-based result contexts).
- **`solana_kit_rpc_transformers` (breaking)**: removed `getBigIntDowncastRequestTransformer`, matching upstream #1948. It was no longer used by the default Solana RPC request transformer: the Solana RPC transport serializes `BigInt` values losslessly as large integer literals via `stringifyJsonWithBigInts`, and Agave parses JSON integers across the full `u64` range without precision loss, so downcasting `BigInt`s to (potentially lossy) `int`s is unnecessary. `getDefaultRequestTransformerForSolanaRpc` no longer downcasts; if you still need this behavior, recreate it with `getTreeWalkerRequestTransformer` and a visitor that replaces `BigInt` nodes with `int` values.
- `solana_kit_rpc_transformers`: the numeric allow-list keeps `transactionConfig.computeUnitLimit`, `transactionConfig.heapSize`, and `transactionConfig.loadedAccountsDataSizeLimit` from version 1 transaction responses as numbers instead of upcasting them to `BigInt` (upstream #1951).
- Documentation now tracks `@solana/kit` `v8.1.0`, and the reference pin in `config/reference-repos.json` moved to `bb54243d8a57` (tag `v8.1.0`).

Migration example:

```dart
// Before (removed):
// final estimate = estimateComputeUnitLimitFactory(rpc);
// var message = await estimateAndSetComputeUnitLimitFactory(estimate)(message);
// final freeBytes = transactionSizeLimit - getTransactionSize(transaction);

// After:
final estimate = estimateResourceLimitsFactory(rpc);
var message = await estimateAndSetResourceLimitsFactory(estimate)(message);
final freeBytes =
    getTransactionSizeLimit(transaction) - getTransactionSize(transaction);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #225](https://github.com/openbudgetfun/solana_kit/pull/225) · _Related issues:_ [#1899](https://github.com/openbudgetfun/solana_kit/issues/1899), [#1902](https://github.com/openbudgetfun/solana_kit/issues/1902), [#1910](https://github.com/openbudgetfun/solana_kit/issues/1910), [#1913](https://github.com/openbudgetfun/solana_kit/issues/1913), [#1948](https://github.com/openbudgetfun/solana_kit/issues/1948), [#1951](https://github.com/openbudgetfun/solana_kit/issues/1951), [#1957](https://github.com/openbudgetfun/solana_kit/issues/1957), [#1970](https://github.com/openbudgetfun/solana_kit/issues/1970), [#1971](https://github.com/openbudgetfun/solana_kit/issues/1971), [#1972](https://github.com/openbudgetfun/solana_kit/issues/1972), [#1979](https://github.com/openbudgetfun/solana_kit/issues/1979), [#220](https://github.com/openbudgetfun/solana_kit/issues/220)

#### Typed tuple codecs and explicit integer factories

_Packages:_ _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_

Add typed `getTuple2Encoder`/`getTuple2Decoder` helpers to `solana_kit_codecs_data_structures`, exposing two-element tuples as Dart records. Give the integer codec factories in `solana_kit_codecs_numbers` explicit generic specializations while preserving their existing `FixedSizeEncoder<num>` public return types. `codama-renderers-dart` now emits `getTuple2*` for arity-2 tuple nodes, escapes Dart reserved-word identifiers, keeps generated `instructionData` locals collision-free, and gives generated byte/list fields recursive value equality and hashing.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

### 🐛 Fixed

#### Sync upstream `@solana/kit` v7.1.1

_Packages:_ _solana_kit_, _solana_kit_codecs_strings_, _solana_kit_instruction_plans_, _solana_kit_rpc_transformers_

Tracks upstream APIs and behavior through `v7.1.1`:

- `solana_kit`: README now documents `v7.1.1` as the latest supported upstream version.
- `solana_kit_codecs_strings`: base-X decoders now report the end of the buffer as the next offset when no bytes remain to decode, matching upstream `@solana/codecs-strings` (#1926).
- `solana_kit_rpc_transformers`: subscription responses for `blockSubscribe`/`blockNotification` now consult the `blockNotifications` numeric allow-list, matching upstream `@solana/rpc-transformers` (#1925).
- `solana_kit_instruction_plans`: `successfulSingleTransactionPlanResultFromTransaction` is deprecated in favor of `successfulSingleTransactionPlanResult` with an explicit context, matching upstream `@solana/instruction-plans` (#1924).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #220](https://github.com/openbudgetfun/solana_kit/pull/220) · _Related issues:_ [#1924](https://github.com/openbudgetfun/solana_kit/issues/1924), [#1925](https://github.com/openbudgetfun/solana_kit/issues/1925), [#1926](https://github.com/openbudgetfun/solana_kit/issues/1926)

#### Support Keccak-256 on Flutter web

_Packages:_ _solana_kit_codecs_core_

Preserve exact 64-bit Keccak state with `BigInt`, allowing JavaScript and WebAssembly Flutter builds to use the existing Keccak-256 API safely.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #224](https://github.com/openbudgetfun/solana_kit/pull/224)

#### Harden Pyth and SNS validation

_Packages:_ _solana_kit_pyth_, _solana_kit_sns_

Require the Pyth price-update account signer declared by the receiver IDL, validate Pyth account headers and bounded integer inputs, normalize malformed update data to typed decode errors, and cover the signer requirement through the Surfpool transaction flow. Also enforce SNS record lengths, EVM address sizes, and TLD-trimmed domain-key inputs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

### 📖 Documentation

#### Typed tuple codecs and explicit integer factories

_Packages:_ _solana_kit_

Add typed `getTuple2Encoder`/`getTuple2Decoder` helpers to `solana_kit_codecs_data_structures`, exposing two-element tuples as Dart records. Give the integer codec factories in `solana_kit_codecs_numbers` explicit generic specializations while preserving their existing `FixedSizeEncoder<num>` public return types. `codama-renderers-dart` now emits `getTuple2*` for arity-2 tuple nodes, escapes Dart reserved-word identifiers, keeps generated `instructionData` locals collision-free, and gives generated byte/list fields recursive value equality and hashing.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #227](https://github.com/openbudgetfun/solana_kit/pull/227)

#### Unslop package docs and code comments

_Packages:_ _solana_kit_, _solana_kit_accounts_, _solana_kit_address_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_fixed_points_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_functional_, _solana_kit_instruction_plans_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_lints_, _solana_kit_options_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transformers_, _solana_kit_rpc_transport_http_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_subscribable_, _solana_kit_test_matchers_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_introspection_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Rewrote every package README from a reader's perspective with verified, compilable examples, removed AI-tell phrasing from docs and code comments, and added a test that analyzes every Dart block in Markdown so examples cannot drift from the API.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #223](https://github.com/openbudgetfun/solana_kit/pull/223)

## [0.8.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.8.0) (2026-08-19)

Grouped release for `main`.

### 💥 Breaking Change

#### Preserve UTF-8 data exactly during decoding

_Packages:_ _solana_kit_codecs_strings_

UTF-8 codecs now preserve embedded null characters and reject malformed byte sequences. Lossy compatibility modes and null-character rejection modes have been removed; callers can opt into null removal explicitly with `removeNullCharacters` after decoding.

```dart
final value = getUtf8Codec().decode(bytes);
final withoutPadding = removeNullCharacters(value);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #218](https://github.com/openbudgetfun/solana_kit/pull/218)

### 🚀 Feature

#### Publish this package

_Packages:_ _solana_kit_lints_

This makes publishing with melos simpler for the whole repo.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`c61ccb2`](https://github.com/openbudgetfun/solana_kit/commit/c61ccb2dbc7dc9c7abe23e765e15b5da9b5ff81a)

### 🐛 Fixed

#### Reject over-capacity generated values

_Packages:_ _solana_kit_codecs_core_

Adds an opt-in non-truncating mode to fixed-size encoders and codecs. Codama fixed-size types now use that mode so generated string, byte, and collection encoders pad values within capacity but reject oversized encoded values.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #216](https://github.com/openbudgetfun/solana_kit/pull/216)

#### Reject non-canonical boolean decoder values

_Packages:_ _solana_kit_codecs_data_structures_, _solana_kit_errors_

Boolean codecs now reject values other than zero and one with a typed error, including nullable prefixes that use boolean tags.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #217](https://github.com/openbudgetfun/solana_kit/pull/217)

## [0.7.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.7.0) (2026-08-18)

Grouped release for `main`.

### 💥 Breaking Change

#### @solana/kit v7.0.0 upstream sync (foundational breaking changes)

_Packages:_ _solana_kit_, _solana_kit_address_constants_, _solana_kit_codecs_data_structures_, _solana_kit_errors_, _solana_kit_instruction_plans_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_transformers_, _solana_kit_rpc_types_, _solana_kit_subscribable_, _solana_kit_transaction_introspection_

Ports the foundational breaking changes from `@solana/kit` v7.0.0:

- **solana_kit_errors**: new `transactionIntrospection` error domain + codes (`transactionFailedToDecompileInstructionAccountIndexOutOfRange`, `transactionIntrospectionCannotDecodeJsonParsedTransaction`, `transactionIntrospectionUnrecognizedGetTransactionResponse`) and instruction-plans max-instructions codes (`instructionPlansInvalidMaxInstructionsPerTransaction`, `instructionPlansMaxInstructionsPerTransactionExceeded`).
- **solana_kit_codecs_data_structures**: `createDependentStructDecoder` fluent builder for structs whose later fields depend on earlier decoded values.
- **solana_kit_instruction_plans**: configurable `maxInstructionsPerTransaction` (default 16, limit 64) on `TransactionPlannerConfig`, individual `TransactionPlanner` invocations, and `MessagePacker`; invocation-specific planner values take precedence without leaking to later calls.
- **solana_kit_rpc_types**: `isSolanaRpcResponse` runtime guard.
- **solana_kit**: removed the local `getMinimumBalanceForRentExemption` helper (rent exemption is becoming dynamic; use the RPC method instead).
- **solana_kit_subscribable**: `ReactiveStreamStore` v7 rewrite — caller-driven `connect()`/`reset()`/`withSignal()`, starts `idle`, collapses `retrying` into `loading` (stale-while-revalidate), renames `getUnifiedState()` → `getState()`; removed `retry()`, value-only `getState()`, `getError()`. `ReactiveActionStore` now passes a fresh `CancellationToken` to every action, cancels superseded/reset/disposed dispatches, suppresses late outcomes, exposes caller cancellation through `withSignal()`, and preserves stale results and errors while running.
- **solana_kit_transaction_introspection**: new first-class package porting `@solana/transaction-introspection` — RPC transaction decoding, instruction and inner-instruction extraction, loaded-address resolution, and instruction walking helpers; re-exported from the `solana_kit` umbrella.
- **solana_kit_rpc_parsed_types** / **solana_kit_rpc_transformers** / **solana_kit_rpc_api**: Agave 4.1.0 parsed-account types — vote commissions/latency as `int` (not `BigInt`); rent sysvar union (`lamportsPerByte` vs deprecated `burnPercent`/`exemptionThreshold`/ `lamportsPerByteYear`); stake `warmupCooldownRate` optional; config `slashPenalty`/`warmupCooldownRate` deprecated; keep vote commissions and latency as `int` in the numeric-keypath allow-lists.

Migration: `getMinimumBalanceForRentExemption(space)` → `rpc.getMinimumBalanceForRentExemption(space).send()`; `store.retry()` → `store.connect()`; `store.getUnifiedState()` → `store.getState()`; the deprecated `ReactiveStore`/`createReactiveStoreFromStreams` → `createReactiveStreamStore`; reactive actions must migrate from `(args) async => result` to `(signal, args) async => result`.

```dart
// Before
final lamports = getMinimumBalanceForRentExemption(space);
store.retry();
final state = store.getUnifiedState();

// After
final lamports = await rpc.getMinimumBalanceForRentExemption(space).send();
store.connect();
final state = store.getState();
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #204](https://github.com/openbudgetfun/solana_kit/pull/204)

### 🚀 Feature

#### @solana/kit v7.1.0 upstream sync

_Packages:_ _solana_kit_, _solana_kit_errors_, _solana_kit_instruction_plans_, _solana_kit_subscribable_

Ports the `@solana/kit` `v7.1.0` changes into the Dart SDK.

##### solana_kit_errors

Adds the three new error codes introduced in `@solana/kit` v7.1.0:

- `offchainMessageContentDoesNotMatchExpected` (`5607018`) — from `@solana/offchain-messages`'s new `assertOffchainMessageV1Equal` helper.
- `offchainMessageRequiredSignatoriesDoNotMatchExpected` (`5607019`) — same.
- `subscribableStreamClosedWithoutError` (`8195001`) — from `@solana/subscribable`'s new `bridgeStoreToAsyncIterable` helper.

##### solana_kit_subscribable

Adds `bridgeStoreToAsyncIterable`, which adapts a `ReactiveStreamStore` into a pull-based `Stream` (the Dart equivalent of the upstream `AsyncIterable`). It seeds from the store's current snapshot, yields loaded values (latest-wins), throws on error (substituting `subscribableStreamClosedWithoutError` when the error payload is nullish), and ends cleanly when the `CancellationToken` fires. The caller owns the store's lifecycle (`connect()`/`reset()`).

##### solana_kit_offchain_messages

Adds `assertOffchainMessageV1Equal`, which asserts that a version 1 offchain message received from an untrusted signer is the message you expected it to sign. Compares content (reporting UTF-8 byte lengths) and required signatories (order-insensitive, sorted for comparison), throwing `offchainMessageContentDoesNotMatchExpected` / `offchainMessageRequiredSignatoriesDoNotMatchExpected` on mismatch.

##### solana_kit_instruction_plans

`createTransactionPlanExecutor`'s `executeTransactionMessage` callback may now return the context of a successful result (a map that must include a `signature`) instead of a `Signature` or `Transaction`. The returned context is merged with the mutable context, taking precedence. Returning a `Signature` or `Transaction` still behaves as before (stored as `context['signature']` / `context['transaction']` with the signature derived).

##### solana_kit_rpc_transformers / solana_kit_rpc_api

- New `tokenBalancesConfigs` export (`accountIndex`, `uiTokenAmount.decimals`, `uiTokenAmount.uiAmount`).
- `getTransaction`, `getBlock`, and `simulateTransaction` now allow-list `uiTokenAmount.uiAmount` (previously upcast to `BigInt` when whole).
- `simulateTransaction` now allow-lists token-balance `accountIndex` and `uiTokenAmount.decimals`.
- `getTransaction` and `getBlock` now allow-list the transaction `version` (previously arrived as `0n` while typechecking as `0`).
- `getTransactionsForAddress` allowed-numeric keypaths.

##### solana_kit

Adds the v7.1.0 client-interface helpers:

- `ClientWithGetMinimumBalance` and `ClientWithFetchAccounts` interfaces.
- `createClientWithGetMinimumBalanceFromRpc` — computes the rent-exempt minimum balance via `getMinimumBalanceForRentExemption` (with the `withoutHeader` rate-recovery trick).
- `createClientWithFetchAccountsFromRpc` — dispatches on address count (`getAccountInfo` / `getMultipleAccounts` / empty short-circuit).
- `createClientWithInterfacesFromRpc` — returns both interfaces.

Also re-exports the `@solana/promises` helpers as Dart counterparts: `isAbortError`, `getAbortablePromise`, and `safeRace` (adapted to Dart's cancellation model via `CancellationToken`; `AbortError` lives in `solana_kit_subscribable`).

##### solana_kit_rpc_api

Adds the `getTransactionsForAddress` RPC method request side: config (commitment, filters, limit, minContextSlot, paginationToken, sortOrder, encoding, maxSupportedTransactionVersion, transactionDetails), filters (blockTime/signature/slot comparisons, status, tokenAccounts), and the params builder.

##### solana_kit_rpc_types

- Adds the `getTransactionsForAddress` response types: `signatures` and `full` modes (with per-entry base fields, transaction/status variants, and the `TransactionDetails` enum).
- Adds the shared `meta.costUnits` field to the transaction meta types.

Already present in the Dart port (no change needed):

- `@solana/codecs-data-structures` `getBitArrayEncoder` next-offset fix (`offset + size`) — the Dart encoder already returns `offset + size`.
- `@solana/transaction-messages` `compressTransactionMessageUsingAddressLookupTables` rejecting v1 transactions — a compile-time-only type narrowing upstream; not expressible in Dart's single-class `TransactionMessage` model, so no runtime change.

`@solana/react` changes are not ported (React-only).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #206](https://github.com/openbudgetfun/solana_kit/pull/206)

### 🐛 Fixed

#### Kit-plugin style Surfpool client + SDK-based integration tests

_Packages:_ _solana_kit_, _solana_kit_errors_

##### `solana_kit_surfpool` (minor)

Add `createSurfpoolClient()` / `connectSurfpoolClient()` returning a `SurfpoolClient` wired up like the `@solana/surfpool/kit` plugin for TypeScript:

- `rpc` / `rpcSubscriptions` — Solana Kit RPC and subscriptions clients pointed at the Surfnet.
- `payer` — the Surfnet's pre-funded `KeyPairSigner` (embedded mode) or a caller-provided funded signer (attach mode).
- `cheatcodes` — a typed `SurfnetCheatcodes` RPC covering every `surfnet_*` cheatcode with the prefix stripped (`timeTravel`, `pauseClock`, `setAccount`, `writeProgram`, …).
- `rpcUrl` / `wsUrl` — the Surfnet's HTTP and WebSocket URLs.
- `airdrop` / `getMinimumBalance` — funding and rent-exemption helpers.
- `stop()` — idempotent teardown that stops the Surfnet when this client started it.

`createSurfpoolClient` stops the Surfnet if wiring fails, so no orphaned process or ports are left behind. The new API is fully unit-tested with 100% patch coverage.

##### `codama-renderers-dart` (patch)

Fix `visitSizePrefixType` so BigInt-width size prefixes (u64/u128/i64/i128) generate `transformEncoder`/`transformDecoder` wrappers instead of substituting u32. The system program's bincode String length is u64, so the u32 substitution broke on-chain encoding of seed fields.

##### `solana_kit_system` (patch)

Regenerate the system program client with the size-prefix renderer fix; `createAccountWithSeed`, `allocateWithSeed`, `assignWithSeed`, and `transferSolWithSeed` now encode their u64 String-length prefixes correctly.

##### `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle `account_index` values returned as `BigInt` by some RPC nodes (e.g. SurfPool), matching the earlier instruction-error-index fix.

##### `solana_kit` (patch)

Convert `test/integration/rpc_basic_test.dart` to start its own Surfpool via the SDK instead of requiring an externally launched validator.

##### `solana_kit_mpl_bubblegum` (patch)

Convert the compressed-NFT integration test to start its own Surfpool via the SDK; add `solana_kit_surfpool` as a dev dependency.

##### `solana_kit_integration_tests` (minor)

Integration tests now start their own Surfpool per test file via the SDK (auto-allocated ports, parallel-safe) instead of requiring an externally launched instance. Adds the gap-coverage tests: loader full deploy, system seed-based instructions, config store (committed `config-v3.0.0.so` artifact), subscriptions on-chain lifecycle, ALT extend/deactivate/close, error paths, token/2022 transfer+burn+setAuthority+closeAccount, stake authorize, and ATA idempotency.

```dart
// Before: manual Surfnet wiring
final surfnet = await Surfnet.start();
final rpc = createSolanaRpc(surfnet.rpcUrl);

// After: kit-plugin style client
final client = await createSurfpoolClient();
final rpc = client.rpc;
final payer = client.payer;
await client.cheatcodes.timeTravel(...);
await client.stop();
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #208](https://github.com/openbudgetfun/solana_kit/pull/208)

#### On-chain integration tests for program clients + sendTransaction encoding fix

_Packages:_ _solana_kit_address_constants_, _solana_kit_errors_, _solana_kit_transaction_confirmation_

##### `solana_kit_transaction_confirmation` (patch)

Fix `sendAndConfirmTransaction` so the `sendTransaction` RPC call declares `encoding: base64`. The helper encodes the transaction as base64 via `getBase64EncodedWireTransaction` but previously left the `encoding` field unset, so real RPC nodes (including SurfPool) defaulted to base58 and rejected the payload with `invalid base58 encoding`. This path had only been exercised against a mocked transport, so the bug was latent.

##### `solana_kit_errors` (patch)

Fix `getSolanaErrorFromTransactionError` to handle instruction-error indices returned as `BigInt` (as SurfPool does). The instruction index was cast `as num`, which threw `_BigIntImpl is not a subtype of num` and masked the real on-chain instruction error. It now converts `BigInt` indices to `int`.

##### `solana_kit_address_constants` / `solana_kit_spl_account_compression` (patch)

Fix the SPL Account Compression, Noop, and MPL Bubblegum program addresses to the live mainnet IDs:

- `splAccountCompressionProgramAddress`: `cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi` -> `cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK`
- `noopProgramAddress`: `noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK` -> `noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV`
- `mplBubblegumProgramAddress`: `BGUMAp9Gph7G9Jn2tU58R5L2qPG1Mj9HP7G3G7VYV2Ma` -> `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- `stakeConfigAddress`: `StakeConfig1111111111111111111111111111` (truncated, invalid length) -> `StakeConfig11111111111111111111111111111111`

The previous values point to accounts that do not exist on mainnet. An audit of every constant in the package against mainnet confirmed all other addresses are correct (native/runtime programs and sysvars are canonical per `solana-sdk-ids`; some native programs and lazily-created sysvars legitimately have no materialized account). SurfPool integration tests for MPL Bubblegum confirmed the corrected IDs resolve to deployed programs.

##### `solana_kit_integration_tests` (new, internal)

A non-published workspace package that runs every generated program client end-to-end against a local SurfPool Surfnet. It ships a shared `IntegrationTestEnv` harness (connects-or-starts SurfPool, funds a payer, builds/signs/sends/confirms transactions, deploys programs) and on-chain suites that assert the real on-chain outcome of each instruction:

- Builtin programs: Memo, System (transfer), Compute Budget, Token (createMint -> mintTo), Token-2022, Associated Token Account, Address Lookup Table, Stake (initialize), and BPF Loader (initializeBuffer).
- Subscriptions: the compiled program (`.so`) is committed under `config/programs/` and deployed on-chain; `initSubscriptionAuthority` runs and its PDA is verified on-chain.
- MPL Bubblegum: Bubblegum + SPL Account Compression + Noop are deployed on-chain (verified executable + owned by the BPF loader) and the full compressed-NFT lifecycle runs end-to-end: `createTree` (with the merkle-tree account sized per the account-compression layout formulas, 31800 bytes for (maxDepth=14, maxBufferSize=64, canopyDepth=0)) -> `mintV1` -> `transfer` (leaf owner signs) -> `burn` (new owner signs). The tree state (root, proof, index) is parsed from the on-chain ConcurrentMerkleTree account and the data/creator hashes are recomputed client-side to drive transfer and burn.

The compiled `.so` artifacts are committed (not rebuilt per run) and pinned to `config/reference-repos.json`; see `config/programs/README.md` for how they are built and when they must be regenerated. Artifact names follow `<package-name-minus-solana_kit>-<program-version>.so` (e.g. `subscriptions-v0.5.0.so`, `mpl_bubblegum-v0.12.0.so`, `spl_account_compression-v0.3.3.so`, `noop-v0.2.0.so`). All four are compiled from the pinned source with `cargo build-sbf` (agave 4.2.0 / platform-tools v1.54) via `scripts/build_program_artifacts.mjs` (devenv task `build:program-artifacts`), which also applies the ahash 0.7.6 `stdsimd` patch needed by the solana-program 1.18.x programs and verifies the baked-in program IDs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #205](https://github.com/openbudgetfun/solana_kit/pull/205)

#### Harden credentials, keys, transports, and untrusted RPC decoding

_Packages:_ _solana_kit_keys_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_transaction_introspection_

Align Helius signup and project provisioning with the v3 bearer-JWT API, generate valid Ed25519 authentication keypairs, validate payment inputs, and redact WebSocket credentials.

Dispose or clear SDK-owned key material deterministically, create key files exclusively with safe POSIX permissions, and preserve caller ownership of Surfpool signers.

Reject malformed RPC transaction and inner-instruction data instead of silently dropping it, expand private WebSocket literal filtering, and update JavaScript dependency overrides to releases without the audited advisories. Make the standalone Codama renderer workspace declare its own build tools and explicitly allow only esbuild's required install script.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #213](https://github.com/openbudgetfun/solana_kit/pull/213) · _Related issues:_ [#159](https://github.com/openbudgetfun/solana_kit/issues/159), [#163](https://github.com/openbudgetfun/solana_kit/issues/163), [#186](https://github.com/openbudgetfun/solana_kit/issues/186), [#198](https://github.com/openbudgetfun/solana_kit/issues/198), [#203](https://github.com/openbudgetfun/solana_kit/issues/203), [#204](https://github.com/openbudgetfun/solana_kit/issues/204), [#205](https://github.com/openbudgetfun/solana_kit/issues/205), [#206](https://github.com/openbudgetfun/solana_kit/issues/206), [#207](https://github.com/openbudgetfun/solana_kit/issues/207), [#208](https://github.com/openbudgetfun/solana_kit/issues/208), [#210](https://github.com/openbudgetfun/solana_kit/issues/210), [#211](https://github.com/openbudgetfun/solana_kit/issues/211), [#34](https://github.com/openbudgetfun/solana_kit/issues/34), [#37](https://github.com/openbudgetfun/solana_kit/issues/37)

#### @solana/kit v7.1.0 upstream sync

_Packages:_ _solana_kit_rpc_api_, _solana_kit_rpc_transformers_, _solana_kit_rpc_types_, _solana_kit_transaction_introspection_

Ports the `@solana/kit` `v7.1.0` changes into the Dart SDK.

##### solana_kit_errors

Adds the three new error codes introduced in `@solana/kit` v7.1.0:

- `offchainMessageContentDoesNotMatchExpected` (`5607018`) — from `@solana/offchain-messages`'s new `assertOffchainMessageV1Equal` helper.
- `offchainMessageRequiredSignatoriesDoNotMatchExpected` (`5607019`) — same.
- `subscribableStreamClosedWithoutError` (`8195001`) — from `@solana/subscribable`'s new `bridgeStoreToAsyncIterable` helper.

##### solana_kit_subscribable

Adds `bridgeStoreToAsyncIterable`, which adapts a `ReactiveStreamStore` into a pull-based `Stream` (the Dart equivalent of the upstream `AsyncIterable`). It seeds from the store's current snapshot, yields loaded values (latest-wins), throws on error (substituting `subscribableStreamClosedWithoutError` when the error payload is nullish), and ends cleanly when the `CancellationToken` fires. The caller owns the store's lifecycle (`connect()`/`reset()`).

##### solana_kit_offchain_messages

Adds `assertOffchainMessageV1Equal`, which asserts that a version 1 offchain message received from an untrusted signer is the message you expected it to sign. Compares content (reporting UTF-8 byte lengths) and required signatories (order-insensitive, sorted for comparison), throwing `offchainMessageContentDoesNotMatchExpected` / `offchainMessageRequiredSignatoriesDoNotMatchExpected` on mismatch.

##### solana_kit_instruction_plans

`createTransactionPlanExecutor`'s `executeTransactionMessage` callback may now return the context of a successful result (a map that must include a `signature`) instead of a `Signature` or `Transaction`. The returned context is merged with the mutable context, taking precedence. Returning a `Signature` or `Transaction` still behaves as before (stored as `context['signature']` / `context['transaction']` with the signature derived).

##### solana_kit_rpc_transformers / solana_kit_rpc_api

- New `tokenBalancesConfigs` export (`accountIndex`, `uiTokenAmount.decimals`, `uiTokenAmount.uiAmount`).
- `getTransaction`, `getBlock`, and `simulateTransaction` now allow-list `uiTokenAmount.uiAmount` (previously upcast to `BigInt` when whole).
- `simulateTransaction` now allow-lists token-balance `accountIndex` and `uiTokenAmount.decimals`.
- `getTransaction` and `getBlock` now allow-list the transaction `version` (previously arrived as `0n` while typechecking as `0`).
- `getTransactionsForAddress` allowed-numeric keypaths.

##### solana_kit

Adds the v7.1.0 client-interface helpers:

- `ClientWithGetMinimumBalance` and `ClientWithFetchAccounts` interfaces.
- `createClientWithGetMinimumBalanceFromRpc` — computes the rent-exempt minimum balance via `getMinimumBalanceForRentExemption` (with the `withoutHeader` rate-recovery trick).
- `createClientWithFetchAccountsFromRpc` — dispatches on address count (`getAccountInfo` / `getMultipleAccounts` / empty short-circuit).
- `createClientWithInterfacesFromRpc` — returns both interfaces.

Also re-exports the `@solana/promises` helpers as Dart counterparts: `isAbortError`, `getAbortablePromise`, and `safeRace` (adapted to Dart's cancellation model via `CancellationToken`; `AbortError` lives in `solana_kit_subscribable`).

##### solana_kit_rpc_api

Adds the `getTransactionsForAddress` RPC method request side: config (commitment, filters, limit, minContextSlot, paginationToken, sortOrder, encoding, maxSupportedTransactionVersion, transactionDetails), filters (blockTime/signature/slot comparisons, status, tokenAccounts), and the params builder.

##### solana_kit_rpc_types

- Adds the `getTransactionsForAddress` response types: `signatures` and `full` modes (with per-entry base fields, transaction/status variants, and the `TransactionDetails` enum).
- Adds the shared `meta.costUnits` field to the transaction meta types.

Already present in the Dart port (no change needed):

- `@solana/codecs-data-structures` `getBitArrayEncoder` next-offset fix (`offset + size`) — the Dart encoder already returns `offset + size`.
- `@solana/transaction-messages` `compressTransactionMessageUsingAddressLookupTables` rejecting v1 transactions — a compile-time-only type narrowing upstream; not expressible in Dart's single-class `TransactionMessage` model, so no runtime change.

`@solana/react` changes are not ported (React-only).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #206](https://github.com/openbudgetfun/solana_kit/pull/206)

#### Attach signers to any matching account meta

_Packages:_ _solana_kit_signers_

`addSignersToInstruction` (and `addSignersToTransactionMessage`) previously only attached a provided signer to an account meta that already declared a signer role (`readonlySigner`/`writableSigner`). Account metas whose role was plain `readonly`/`writable` were silently skipped, even when a signer for that exact address was supplied.

This dropped required signatures for programs whose IDLs mark authority accounts as non-signers. MPL Bubblegum is the canonical example: its `transfer`/`burn` instructions mark `leafOwner`/`leafDelegate` as readonly accounts, yet the program requires the leaf owner (or delegate) to sign (`LeafAuthorityMustSign`). The JS SDK handles this by promoting any account whose address matches a provided signer to `isSigner: true` in `getAccountMetasAndSigners`.

The Dart helpers now mirror that behavior: any account whose address matches a provided signer is wrapped in an `AccountSignerMeta` with its role upgraded via `upgradeRoleToSigner`, and the signer is attached. This fixes signature collection for Bubblegum transfers/burns and any other program with non-signer-marked authority accounts.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #210](https://github.com/openbudgetfun/solana_kit/pull/210)

### 📖 Documentation

#### Reformat package docs

_Packages:_ _solana_kit_accounts_, _solana_kit_address_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_fixed_points_, _solana_kit_fast_stable_stringify_, _solana_kit_functional_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_lints_, _solana_kit_options_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transport_http_, _solana_kit_test_matchers_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Docs have been reformatted to remove line wrapping.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #212](https://github.com/openbudgetfun/solana_kit/pull/212)

## [0.6.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.6.0) (2026-08-12)

Grouped release for `main`.

### 💥 Breaking Change

#### Remove deprecated APIs across the SDK

_Packages:_ _solana_kit_, _solana_kit_fixed_points_, _solana_kit_functional_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_subscribable_, _solana_kit_test_matchers_, _solana_kit_transaction_confirmation_

**Breaking change.** Clears every `remove_deprecations_in_breaking_versions` lint warning by deleting deprecated members and migrating call sites to their documented replacements. No deprecations are suppressed; each deprecated declaration is removed.

##### `createEmptyClient` (solana_kit)

Removed the deprecated `createEmptyClient` alias. Use `createClient` instead.

```dart
// Before
final client = createEmptyClient({'ready': true});
// After
final client = createClient({'ready': true});
```

##### Deprecated fixed-point rounding modes (solana_kit_fixed_points)

Removed the deprecated `FixedPointRoundingMode` values `down`, `up`, and `halfUp`. The surviving modes are `strict`, `floor`, `ceil`, `trunc`, `round`.

- `down` was a duplicate of `trunc` — use `FixedPointRoundingMode.trunc`.
- `halfUp` was a duplicate of `round` — use `FixedPointRoundingMode.round`.
- `up` ("round away from zero") has no single replacement. Use `floor` or `ceil` depending on the sign of the value, or `round` for nearest.

##### Deprecated `Pipe` extension (solana_kit_functional)

Removed the deprecated `Pipe` extension from `solana_kit_functional`. `Pipe` is re-exported from `solana_kit_transaction_messages` and the `solana_kit` umbrella. Switch imports accordingly:

```dart
// Before
import 'package:solana_kit_functional/solana_kit_functional.dart';
// After
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
```

`solana_kit` no longer depends on `solana_kit_functional`. The `solana_kit_functional` package is now an empty placeholder pending full retirement.

##### Deprecated subscriptions compatibility APIs

The deprecated `AbortSignal`/`AbortController` and `DataPublisher`/`WritableDataPublisher`/`createDataPublisher` compatibility APIs were the core transport substrate of the subscriptions stack, not a thin compatibility layer. They are replaced by stream-native and cancellation-token equivalents.

###### Cancellation

- `AbortSignal` → `CancellationToken` (from `solana_kit_subscribable`)
- `AbortController` → `CancellationTokenSource` (from `solana_kit_subscribable`)
- `controller.signal` → `source.token`
- `controller.abort([reason])` → `source.cancel([reason])`
- `signal.isAborted` → `token.isCancelled`
- `signal.reason` → `token.reason`
- `signal.future` → `token.future`

Public field/parameter names that held an `AbortSignal` (e.g. `abortSignal`, `signal`) are kept; only their type changed to `CancellationToken`. `CancellationToken` and `CancellationTokenSource` are re-exported from `solana_kit_rpc_subscriptions` and `solana_kit_rpc_subscriptions_channel_websocket` so consumers do not need a direct `solana_kit_subscribable` dependency.

`AbortError`, `isAbortError`, `getAbortableFuture`, and `normalClosureCode` remain in `solana_kit_rpc_subscriptions_channel_websocket` (behavior unchanged; their `AbortSignal?` params are now `CancellationToken?`).

###### DataPublisher → NotificationStreams

- The transport contract changed from `Future<DataPublisher>` to `Future<NotificationStreams>`.
- `RpcSubscriptionsChannel` now exposes `NotificationStreams get streams` instead of the `on(channelName, subscriber)` method.
- `createDataPublisher()`, `WritableDataPublisher`, `DataPublisher`, and the `DataPublisherStreams` extension are removed.
- The `*FromDataPublisher` helpers are removed: `createStreamFromDataPublisher`, `StreamFromDataPublisherConfig`, `createAsyncIterableFromDataPublisher`, `demultiplexDataPublisher`, `createReactiveStoreFromDataPublisher`, `createReactiveStreamStoreFromDataPublisher`.
- The stream-native helpers are kept: `ChannelStreamController`, `createStreamFromDataAndErrorStreams`, `demultiplexStream`, `createReactiveStoreFromStreams`, `ReactiveStore`, `ReactiveStreamStore`, `createReactiveStreamStore`.

###### Public subscription APIs

`PendingRpcSubscriptionsRequest.subscribe()` and `.reactive()` still return `Future<Stream<T>>` and `Future<ReactiveStore<T>>` respectively. Internally they now consume `NotificationStreams.notifications` / `.errors` instead of `DataPublisher` channels.

###### Migration

```dart
// Before
final controller = AbortController();
final stream = await pending.subscribe(
  RpcSubscribeOptions(abortSignal: controller.signal),
);
controller.abort();

// After
final source = CancellationTokenSource();
final stream = await pending.subscribe(
  RpcSubscribeOptions(abortSignal: source.token),
);
source.cancel();
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3901c24`](https://github.com/openbudgetfun/solana_kit/commit/3901c24a64bf94f8772611f62bd8d289f10fdbb8) · _Last updated in:_ [`7d98d00`](https://github.com/openbudgetfun/solana_kit/commit/7d98d00f839d36b0969791865e687bd411c46f12)

#### Remove deprecated base58 account info types

_Packages:_ _solana_kit_rpc_types_

Removes the deprecated `AccountInfoWithBase58Bytes` and `AccountInfoWithBase58EncodedData` classes. The Solana RPC API now returns account data as base64 (or base64+zstd) instead of base58. Use `AccountInfoWithBase64EncodedData` instead.

```dart
// Before
final account = AccountInfoWithBase58Bytes(data: Base58EncodedBytes('...'));

// After
final account = AccountInfoWithBase64EncodedData(
  data: (Base64EncodedBytes('...'), 'base64'),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #196](https://github.com/openbudgetfun/solana_kit/pull/196)

#### Remove deprecated TokenAmount.uiAmount field

_Packages:_ _solana_kit_rpc_types_

Removes the deprecated `uiAmount` field from `TokenAmount`. The floating-point `uiAmount` field loses precision for large token balances. Use `uiAmountString` instead, which preserves the full string representation from the RPC.

```dart
// Before
final amount = TokenAmount(
  amount: StringifiedBigInt('1000000'),
  decimals: 6,
  uiAmountString: StringifiedNumber('1'),
  uiAmount: 1.0,
);

// After
final amount = TokenAmount(
  amount: StringifiedBigInt('1000000'),
  decimals: 6,
  uiAmountString: StringifiedNumber('1'),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #196](https://github.com/openbudgetfun/solana_kit/pull/196)

#### Remove deprecated TransactionStatus types

_Packages:_ _solana_kit_rpc_types_

Removes the deprecated `TransactionStatus` sealed class and its `TransactionStatusOk` / `TransactionStatusErr` subclasses. The modern API uses a nullable `TransactionError` — `null` means success, non-null means the transaction failed with that error.

```dart
// Before
final status = TransactionStatusOk();
final error = TransactionStatusErr(TransactionErrorSimple('AccountInUse'));

// After — use nullable TransactionError directly
final error = null; // success
final error = TransactionErrorSimple('AccountInUse'); // failure
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #196](https://github.com/openbudgetfun/solana_kit/pull/196)

### 🚀 Feature

#### Upstream @solana/kit 6.10.0 parity

_Packages:_ _solana_kit_errors_, _solana_kit_rpc_api_, _solana_kit_rpc_spec_, _solana_kit_subscribable_, _solana_kit_transaction_messages_

Updates core packages to match upstream `@solana/kit` `6.10.0`:

- **solana_kit_errors**: Adds 6 new error codes from `@solana/errors` 6.10: `JSON_RPC__SERVER_ERROR_NO_SLOT_HISTORY` (-32021), `JSON_RPC__SERVER_ERROR_FILTER_TRANSACTION_NOT_FOUND` (-32020), `TRANSACTION__FAILED_TO_ESTIMATE_LOADED_ACCOUNTS_DATA_SIZE_LIMIT` (5663036), `TRANSACTION__FAILED_WHEN_SIMULATING_TO_ESTIMATE_RESOURCE_LIMITS` (5663037), `SUBSCRIBABLE__RETRY_NOT_SUPPORTED` (8195000), `WALLET__ACCOUNT_NOT_AVAILABLE` (8900003). Adds `subscribable` and `wallet` error domains. Updates `unwrapSimulationError` to treat resource-limit simulation failures as simulation errors.

- **solana_kit_subscribable**: Adds `ReactiveActionStore<TArgs, TResult>` with idle/running/success/error states, `dispatch`/`dispatchAsync`/`reset`. Adds `ReactiveStreamStore<T>` with loading/loaded/error/retrying states, `getUnifiedState` and `retry`. Mirrors upstream `@solana/subscribable` 6.10.

- **solana_kit_rpc_spec**: Adds `PendingRpcRequest.reactiveStore()` returning a `ReactiveActionStore` for reactive request dispatch.

- **solana_kit_rpc_api**: Adds `clientId` to `ClusterNode`. Documents `tpu` and `tpuForwards` as deprecated in favor of QUIC fields.

- **solana_kit_transaction_messages**: Adds resource-limit estimation helpers: `ResourceLimitsEstimate`, `estimateResourceLimitsFactory`, `estimateAndSetResourceLimitsFactory`, `fillTransactionMessageProvisoryResourceLimits`, `getTransactionMessageLoadedAccountsDataSizeLimit`, `setTransactionMessageLoadedAccountsDataSizeLimit`.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #195](https://github.com/openbudgetfun/solana_kit/pull/195)

### 🐛 Fixed

#### Upstream @solana/kit 6.10.0 parity

_Packages:_ _solana_kit_

Updates core packages to match upstream `@solana/kit` `6.10.0`:

- **solana_kit_errors**: Adds 6 new error codes from `@solana/errors` 6.10: `JSON_RPC__SERVER_ERROR_NO_SLOT_HISTORY` (-32021), `JSON_RPC__SERVER_ERROR_FILTER_TRANSACTION_NOT_FOUND` (-32020), `TRANSACTION__FAILED_TO_ESTIMATE_LOADED_ACCOUNTS_DATA_SIZE_LIMIT` (5663036), `TRANSACTION__FAILED_WHEN_SIMULATING_TO_ESTIMATE_RESOURCE_LIMITS` (5663037), `SUBSCRIBABLE__RETRY_NOT_SUPPORTED` (8195000), `WALLET__ACCOUNT_NOT_AVAILABLE` (8900003). Adds `subscribable` and `wallet` error domains. Updates `unwrapSimulationError` to treat resource-limit simulation failures as simulation errors.

- **solana_kit_subscribable**: Adds `ReactiveActionStore<TArgs, TResult>` with idle/running/success/error states, `dispatch`/`dispatchAsync`/`reset`. Adds `ReactiveStreamStore<T>` with loading/loaded/error/retrying states, `getUnifiedState` and `retry`. Mirrors upstream `@solana/subscribable` 6.10.

- **solana_kit_rpc_spec**: Adds `PendingRpcRequest.reactiveStore()` returning a `ReactiveActionStore` for reactive request dispatch.

- **solana_kit_rpc_api**: Adds `clientId` to `ClusterNode`. Documents `tpu` and `tpuForwards` as deprecated in favor of QUIC fields.

- **solana_kit_transaction_messages**: Adds resource-limit estimation helpers: `ResourceLimitsEstimate`, `estimateResourceLimitsFactory`, `estimateAndSetResourceLimitsFactory`, `fillTransactionMessageProvisoryResourceLimits`, `getTransactionMessageLoadedAccountsDataSizeLimit`, `setTransactionMessageLoadedAccountsDataSizeLimit`.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #195](https://github.com/openbudgetfun/solana_kit/pull/195)

#### Add Subscriptions program client

_Packages:_ _solana_kit_address_constants_

Adds a generated Subscriptions program client pinned to `solana-foundation/subscriptions` `ts-client-v0.3.0`, including account, instruction, PDA, type, and error helpers.

Also exposes the canonical Subscriptions program address from `solana_kit_address_constants`.

```dart
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

Future<void> main() async {
  const user = Address('11111111111111111111111111111112');
  const tokenMint = Address('So11111111111111111111111111111111111111112');

  final (authority, bump) = await findSubscriptionAuthorityPda(
    programAddress: subscriptionsProgramAddress,
    seeds: SubscriptionAuthoritySeeds(user: user, tokenMint: tokenMint),
  );

  print('authority=$authority bump=$bump');
}
```

Build typed instructions for fixed and recurring delegations.

```dart
final instruction = getCreateFixedDelegationInstruction(
  programAddress: subscriptionsProgramAddress,
  delegator: delegator,
  subscriptionAuthority: subscriptionAuthority,
  delegationAccount: delegationAccount,
  delegatee: delegatee,
  systemProgram: systemProgram,
  fixedDelegation: CreateFixedDelegationData(
    nonce: BigInt.from(1),
    amount: BigInt.from(1_000_000),
    expiryTs: BigInt.zero,
    expectedSubscriptionAuthorityInitId: BigInt.zero,
  ),
);
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #187](https://github.com/openbudgetfun/solana_kit/pull/187)

#### Harden cryptographic input handling

_Packages:_ _solana_kit_keys_

Harden keypair file writes, validate malformed mobile wallet cryptographic inputs, and update vulnerable renderer test dependencies.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/solana_kit/pull/181)

### 📖 Documentation

#### Centralize package version documentation

_Packages:_ _solana_kit_, _solana_kit_accounts_, _solana_kit_address_, _solana_kit_address_constants_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_fixed_points_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_functional_, _solana_kit_instruction_plans_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_options_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transformers_, _solana_kit_rpc_transport_http_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_subscribable_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Centralize package version metadata in `versions.json` and render package installation snippets from the shared MDT data source. Published package behavior is unchanged.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #188](https://github.com/openbudgetfun/solana_kit/pull/188)

#### Point package README website badges at package docs

_Packages:_ _solana_kit_, _solana_kit_accounts_, _solana_kit_address_, _solana_kit_address_constants_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_fixed_points_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_functional_, _solana_kit_instruction_plans_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_lints_, _solana_kit_options_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transformers_, _solana_kit_rpc_transport_http_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_subscribable_, _solana_kit_test_matchers_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Updated package README website badges to link directly to each package's docs catalog entry and added missing package entries to the documentation website catalog/index.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/solana_kit/pull/192)

## [0.5.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.5.0) (2026-06-01)

Grouped release for `main`.

### 💥 Breaking Change

#### Raise minimum Dart SDK to 3.12

_Packages:_ _solana_kit_, _solana_kit_accounts_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_fixed_points_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_functional_, _solana_kit_instruction_plans_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_options_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transformers_, _solana_kit_rpc_transport_http_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_subscribable_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Raise the minimum supported Dart SDK constraint to `^3.12.0` across public Dart packages.

This is a breaking change because consumers must use Dart 3.12 or newer. Flutter consumers must use a Flutter SDK that bundles Dart 3.12 or newer.

```yaml
environment:
  sdk: ^3.12.0
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`32d5d36`](https://github.com/openbudgetfun/solana_kit/commit/32d5d367abb7615fea5ee341f03d17c2bc0d66dd)

#### new `solana_kit_address` package

_Packages:_ _solana_kit_address_

Initial release of `solana_kit_address` — core Address extension type, codecs, comparator, and PublicKey type extracted from `solana_kit_addresses`.

```dart
import 'package:solana_kit_address/solana_kit_address.dart';

final address = Address('11111111111111111111111111111111');
final codec = Address.codec();
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`249e14e`](https://github.com/openbudgetfun/solana_kit/commit/249e14e1d2976cca8b407d1fda3ac57104104ce4)

#### New `solana_kit_address_constants` package

_Packages:_ _solana_kit_address_constants_

Initial release of `solana_kit_address_constants` — well-known address constants for native programs, sysvars, SPL programs, Metaplex programs, and token mints extracted from `solana_kit_addresses`.

```dart
import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';

final address = systemProgramAddress; // native program
final sysvar = clockSysvarAddress;   // sysvar
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`249e14e`](https://github.com/openbudgetfun/solana_kit/commit/249e14e1d2976cca8b407d1fda3ac57104104ce4)

### 🚀 Feature

#### Add well-known program, sysvar, SPL, Metaplex, and token mint address constants

_Packages:_ _solana_kit_addresses_

Add centralized address constants to `solana_kit_addresses` so that any package can reference well-known on-chain addresses without importing the full domain package or hardcoding strings.

New exports:

- `program_addresses.dart` — All Agave/Solana native program addresses (system, ALT, BPF loaders, compute budget, config, stake, vote, etc.)
- `sysvar_addresses.dart` — All sysvar addresses (clock, rent, recentBlockhashes, fees, rewards, etc.) plus the sysvar owner address
- `spl_addresses.dart` — SPL program addresses (Token, Token-2022, ATA, Memo, Memo Legacy)
- `metaplex_addresses.dart` — Metaplex program addresses (Token Metadata, Bubblegum, Auth Rules, Core, SPL Account Compression, Noop)
- `well_known_addresses.dart` — Well-known token mint addresses (Wrapped SOL, USDC, USDT)

Also re-exports from `solana_kit_address` (Address type, codecs, comparator, PublicKey) and `solana_kit_address_constants` (well-known address constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`4643648`](https://github.com/openbudgetfun/solana_kit/commit/46436481a28eab1c803175bee56e98e89fe8fac6)

#### Refactor subscriptions to stream-native APIs

_Packages:_ _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_subscribable_, _solana_kit_transaction_confirmation_

Refactor subscription internals toward stream-native Dart APIs while keeping the existing `DataPublisher` and `AbortSignal` compatibility APIs available as deprecated APIs.

Added stream-native helpers for channel streams, demultiplexing, reactive stores, and data/error stream composition, and migrated internal subscription consumers to use Dart `Stream`/`StreamSubscription` flows where possible.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fcc74a`](https://github.com/openbudgetfun/solana_kit/commit/6fcc74a6860a5201fdfff03a56411f2084da5444) · _Last updated in:_ [`9988103`](https://github.com/openbudgetfun/solana_kit/commit/99881033c4f8a121f811c217a19c092c629103e4)

### 🐛 Fixed

#### Add well-known program, sysvar, SPL, Metaplex, and token mint address constants

_Packages:_ _solana_kit_, _solana_kit_address_, _solana_kit_address_constants_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Add centralized address constants to `solana_kit_addresses` so that any package can reference well-known on-chain addresses without importing the full domain package or hardcoding strings.

New exports:

- `program_addresses.dart` — All Agave/Solana native program addresses (system, ALT, BPF loaders, compute budget, config, stake, vote, etc.)
- `sysvar_addresses.dart` — All sysvar addresses (clock, rent, recentBlockhashes, fees, rewards, etc.) plus the sysvar owner address
- `spl_addresses.dart` — SPL program addresses (Token, Token-2022, ATA, Memo, Memo Legacy)
- `metaplex_addresses.dart` — Metaplex program addresses (Token Metadata, Bubblegum, Auth Rules, Core, SPL Account Compression, Noop)
- `well_known_addresses.dart` — Well-known token mint addresses (Wrapped SOL, USDC, USDT)

Also re-exports from `solana_kit_address` (Address type, codecs, comparator, PublicKey) and `solana_kit_address_constants` (well-known address constants).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3f596ef`](https://github.com/openbudgetfun/solana_kit/commit/3f596ef95c0d00714db97a4338ac9342f1fabfb7) · _Last updated in:_ [`4643648`](https://github.com/openbudgetfun/solana_kit/commit/46436481a28eab1c803175bee56e98e89fe8fac6)

### 🧪 Testing

#### Improve test coverage to 95%+ across all packages

_Packages:_ _solana_kit_addresses_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_strings_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_instruction_plans_, _solana_kit_keys_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_transformers_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_subscribable_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Added 500+ tests covering equality/hashCode/toString, codec edge cases, error paths, and constructor variants. Removed dead code in fast_stable_stringify. Fixed concurrent modification bug in subscribable.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`48216f9`](https://github.com/openbudgetfun/solana_kit/commit/48216f9af0ff058d7db83994e5bdb3b9be95fdf8) · _Last updated in:_ [`b7f5419`](https://github.com/openbudgetfun/solana_kit/commit/b7f5419bbe792d4ba1731eba227088d8f74a3ebb)

#### Refactor subscriptions to stream-native APIs

_Packages:_ _solana_kit_test_matchers_

Refactor subscription internals toward stream-native Dart APIs while keeping the existing `DataPublisher` and `AbortSignal` compatibility APIs available as deprecated APIs.

Added stream-native helpers for channel streams, demultiplexing, reactive stores, and data/error stream composition, and migrated internal subscription consumers to use Dart `Stream`/`StreamSubscription` flows where possible.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fcc74a`](https://github.com/openbudgetfun/solana_kit/commit/6fcc74a6860a5201fdfff03a56411f2084da5444) · _Last updated in:_ [`9988103`](https://github.com/openbudgetfun/solana_kit/commit/99881033c4f8a121f811c217a19c092c629103e4)

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-30)

Grouped release for `main`.

### 💥 Breaking Change

#### New package available

_Packages:_ _solana_kit_compute_budget_

Compute Budget program client for the Solana Kit Dart SDK. Provides instruction builders for setting compute unit limits and priorities on Solana transactions.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Replace string encodings with typed enums

_Packages:_ _solana_kit_rpc_subscriptions_api_

Replace string encoding fields with typed enums in…

Replace string encoding fields with typed enums in subscription notification config classes.

The `encoding` field on `AccountNotificationsConfig`, `BlockNotificationsConfig`, and `ProgramNotificationsConfig` has been changed from `String?` to `AccountEncoding?` or `TransactionEncoding?` respectively. This is a breaking change: callers that previously passed raw strings like `'base64'` or `'jsonParsed'` must now use the corresponding enum values such as `AccountEncoding.base64` or `AccountEncoding.jsonParsed`.

This aligns the subscriptions API with the same encoding-enum migration applied to the RPC request API, ensuring consistent type safety across both surfaces. The wire format is unchanged — the enums serialize to the same JSON strings — so no server-side compatibility is affected.

Migration example:

```dart
// Before
AccountNotificationsConfig(encoding: 'base64')
// After
AccountNotificationsConfig(encoding: AccountEncoding.base64)
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 🚀 Feature

#### Trim program exports from umbrella

_Packages:_ _solana_kit_

Remove program-specific package exports from the…

Remove program-specific package exports from the `solana_kit` umbrella package so program clients remain explicit imports.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`8285b34`](https://github.com/openbudgetfun/solana_kit/commit/8285b34dc7b78f04693fc0558b6854a776ad03a2) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add SolanaAccountClient for account fetching

_Packages:_ _solana_kit_accounts_

Add SolanaAccountClient as the single implementation…

Add `SolanaAccountClient` as the single implementation layer for `fetchEncodedAccount`, `fetchEncodedAccounts`, `fetchJsonParsedAccount`, and `fetchJsonParsedAccounts`, delegating all RPC calls through typed API methods instead of raw request maps. Extract `FetchAccountConfig` into its own file. Migrate parse helpers from `Map<String, dynamic>` to `Map<String, Object?>`. Switch error construction to the standardized `createSolanaError` and `wrapSolanaError` helpers with `SolanaErrorContextKeys`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Re-export fixed-points from codecs

_Packages:_ _solana_kit_codecs_

Re-export solana_kit_fixed_points from the umbrella…

Re-export `solana_kit_fixed_points` from the umbrella codecs package so callers can access fixed-point codec APIs through the standard `solana_kit_codecs` entrypoint.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add Keccak-256 hash function

_Packages:_ _solana_kit_codecs_core_

Adds a pure-Dart Keccak-256 implementation (`keccak256()`) to `solana_kit_codecs_core`. This is the hash function used by the Bubblegum compressed NFT program (not to be confused with SHA3-256, which uses different padding).

Note: Keccak-256 round constants exceed 2^53, so `ignore_for_file: avoid_js_rounded_ints` is applied to the implementation file. This is acceptable because the Solana SDK targets native platforms where `int` is 64-bit.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add compute budget package

_Packages:_ _solana_kit_compute_budget_

Add solana_kit_compute_budget package with the full…

Add `solana_kit_compute_budget` package with the full generated+helpers Compute Budget program client. Includes all five instructions (RequestUnits, RequestHeapFrame, SetComputeUnitLimit, SetComputeUnitPrice, SetLoadedAccountsDataSizeLimit), codec round-trip tests, instruction identification, and parsed instruction types.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3a0e076`](https://github.com/openbudgetfun/solana_kit/commit/3a0e076245cbed19e5015a912edf3bb6fc7e0f0b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Convert SolanaErrorCode to Dart enum

_Packages:_ _solana_kit_errors_

Convert SolanaErrorCode from a static-int abstract class…

Convert SolanaErrorCode from a static-int abstract class to a Dart enum with a numeric value field, enabling exhaustive switches, type safety, and cleaner API usage.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Deprecate solana_kit_functional

_Packages:_ _solana_kit_functional_, _solana_kit_transaction_messages_

Deprecate solana_kit_functional; the Pipe extension is now re-exported from solana_kit_transaction_messages and the umbrella package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add typed value methods to RPC methods

_Packages:_ _solana_kit_rpc_

Add typed value convenience methods to SolanaRpcMethods…

Add typed value convenience methods to `SolanaRpcMethods` extension

Five new methods join the existing raw-request helpers on `Rpc`:

- `getAccountInfoValue(address, config)` — returns `PendingRpcRequest<SolanaRpcResponse<Map<String, Object?>?>>`, parsing the JSON-RPC response envelope into a typed `SolanaRpcResponse` wrapper so callers access `.value` and `.context.slot` directly instead of manually navigating the raw map.
- `getBalanceValue(address, config)` — returns `PendingRpcRequest<SolanaRpcResponse<Lamports>>`, converting the integer balance into a `Lamports` value type.
- `getLatestBlockhashValue(config)` — returns `PendingRpcRequest<SolanaRpcResponse<LatestBlockhashValue>>`, parsing the blockhash and last-valid-block-height into a structured model.
- `getMultipleAccounts(addresses, config)` — raw multi-account fetch returning `PendingRpcRequest<Map<String, Object?>>`.
- `getMultipleAccountsValue(addresses, config)` — typed multi-account fetch returning `PendingRpcRequest<SolanaRpcResponse<List<Map<String, Object?>?>>>`.

Each `*Value` method uses an internal `_mapPendingRpcRequest` adapter that wraps the underlying raw request plan and applies a response parser, keeping the transport and plan plumbing intact. The existing raw methods (`getAccountInfo`, `getBalance`, `getLatestBlockhash`, etc.) remain unchanged, so this is purely additive.

Additionally, the `createSolanaJsonRpcIntegerOverflowError` helper now calls `createSolanaError(...)` instead of the `SolanaError(...)` constructor, and uses `SolanaErrorContextKeys.methodName` and `SolanaErrorContextKeys.path` for standardised context keys. This aligns error construction with the rest of the `solana_kit_errors` surface.

The README code examples have been updated to demonstrate the preferred typed-call pattern (`rpc.getLatestBlockhashValue().send()`) and a new "Preferred Dart path" callout section guides users toward typed helpers before falling back to raw `rpc.request(...)`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace string encoding fields with AccountEncoding

_Packages:_ _solana_kit_rpc_api_, _solana_kit_rpc_types_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Add LatestBlockhashValue and Sol type

_Packages:_ _solana_kit_rpc_types_

Add LatestBlockhashValue model and full Sol fixed-point…

Add `LatestBlockhashValue` model and full `Sol` fixed-point type

**`LatestBlockhashValue`** (`lib/src/latest_blockhash_value.dart`):

A new `@immutable` value class that wraps the two fields returned by `getLatestBlockhash` — a `Blockhash` and a `BigInt lastValidBlockHeight`. This gives downstream callers a typed model instead of navigating a raw `Map` for the latest-blockhash response. The class implements structural equality (`==` / `hashCode`) and a descriptive `toString`.

**`Sol` extension type and helpers** (`lib/src/sol.dart`):

A complete fixed-point SOL representation backed by an exact Lamports `BigInt`:

- `Sol` is an `extension type` implementing both `Lamports` and `Object`, so it interops seamlessly with existing `Lamports`-accepting APIs.
- `sol(String, {RoundingMode})` parses a decimal SOL string (up to 9 fractional digits) into `Sol`. A `RoundingMode` enum (`strict`, `down`, `up`, `halfUp`) controls behaviour when the input has excess precision.
- `solToLamports` / `lamportsToSol` provide lossless round-trip conversions.
- `Sol.toDecimalString()` formats the value back to a human-readable decimal string without trailing zeros.
- `getSolEncoder()`, `getSolDecoder()`, and `getSolCodec()` produce binary codecs that read/write the underlying 64-bit little-endian Lamports count, matching the on-chain wire format.

Both types are exported from the package barrel (`solana_kit_rpc_types.dart`). The `LatestBlockhashValue` export enables `solana_kit_rpc` to use it in its new typed `getLatestBlockhashValue` method. The `Sol` type adds a long-requested ergonomic layer for displaying and parsing SOL amounts without manual BigInt arithmetic.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

### 📝 Changed

#### Restructure release groups

_Packages:_ _solana_kit_, _solana_kit_accounts_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_functional_, _solana_kit_instruction_plans_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_options_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transformers_, _solana_kit_rpc_transport_http_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_subscribable_, _solana_kit_test_matchers_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

### 🐛 Fixed

#### Add per-package coverage badges

_Packages:_ _solana_kit_, _solana_kit_accounts_, _solana_kit_addresses_, _solana_kit_codecs_, _solana_kit_codecs_core_, _solana_kit_codecs_data_structures_, _solana_kit_codecs_numbers_, _solana_kit_codecs_strings_, _solana_kit_compute_budget_, _solana_kit_errors_, _solana_kit_fast_stable_stringify_, _solana_kit_functional_, _solana_kit_instruction_plans_, _solana_kit_instructions_, _solana_kit_keys_, _solana_kit_lints_, _solana_kit_options_, _solana_kit_program_client_core_, _solana_kit_programs_, _solana_kit_rpc_, _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_subscriptions_, _solana_kit_rpc_subscriptions_api_, _solana_kit_rpc_subscriptions_channel_websocket_, _solana_kit_rpc_transformers_, _solana_kit_rpc_transport_http_, _solana_kit_rpc_types_, _solana_kit_signers_, _solana_kit_subscribable_, _solana_kit_test_matchers_, _solana_kit_transaction_confirmation_, _solana_kit_transaction_messages_, _solana_kit_transactions_

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add integration tests CI job

_Packages:_ _solana_kit_

Add SurfPool integration test CI job and devenv command for running integration tests.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`7983fb5`](https://github.com/openbudgetfun/solana_kit/commit/7983fb5835a8fc4093fab46317f162da76fc47cc) · _Last updated in:_ [`93b3cd3`](https://github.com/openbudgetfun/solana_kit/commit/93b3cd3a255039e6d5025da78154c3d99bd7eb3e)

#### Add per-package codecov flags

_Packages:_ _solana_kit_

Add Codecov patch coverage and package-level coverage…

Add Codecov patch coverage and package-level coverage flags for Dart and renderer packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`30e1d19`](https://github.com/openbudgetfun/solana_kit/commit/30e1d192192800481fbdc6afa57dc1a1fd255986) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Fix duplicate ecosystems.dart section in monochange.toml

_Packages:_ _solana_kit_

Merge duplicate `[ecosystem.dart]` and `[ecosystems.dart]` TOML sections into a single `[ecosystems.dart]` section.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`d5765af`](https://github.com/openbudgetfun/solana_kit/commit/d5765af199ad10b93ff613abe46a942b70205ba1)

#### Deploy docs from main pushes

_Packages:_ _solana_kit_

Deploy the docs site from main pushes instead of…

Deploy the docs site from `main` pushes instead of release-tag events so GitHub Pages deployments comply with the repository's `github-pages` environment branch policy.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`8543d72`](https://github.com/openbudgetfun/solana_kit/commit/8543d72c37cef9f94189c4be9209d57863ebcf88) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add shared test fixtures and coverage gates

_Packages:_ _solana_kit_, _solana_kit_test_matchers_

Add shared workspace test fixtures plus risk-tier package…

Add shared workspace test fixtures plus risk-tier package coverage gates so high-risk Solana Kit packages stay above 90% line coverage in CI.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ba96efb`](https://github.com/openbudgetfun/solana_kit/commit/ba96efba2e88ada3944ab2a9b0694d18d315a89d) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expand MDT doc callouts

_Packages:_ _solana_kit_

Expand MDT-backed documentation callouts for preferred…

Expand MDT-backed documentation callouts for preferred Dart paths, compatibility notes, parity status, security guidance, and Android-only Mobile Wallet Adapter platform messaging across the workspace docs and package surfaces.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`53acc17`](https://github.com/openbudgetfun/solana_kit/commit/53acc174471dc42d8f0c6ce92ca9f636754401e9) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace dynamic with Object?

_Packages:_ _solana_kit_, _solana_kit_rpc_api_, _solana_kit_rpc_types_

Replace dynamic with Object? across lib source files; remaining dynamic usage is only in test matcher API signatures required by the test package.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add barrel-file re-export tests

_Packages:_ _solana_kit_, _solana_kit_codecs_

Add barrel-file re-export tests for solana_kit and solana_kit_codecs umbrella packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expand coverage thresholds to 26 packages

_Packages:_ _solana_kit_

Expand per-package coverage thresholds from 5 packages to…

Expand per-package coverage thresholds from 5 packages to 26 packages; core packages at 80%+, high-risk at 60%+.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add SurfPool integration test directory

_Packages:_ _solana_kit_

Add integration test directory with basic RPC tests…

Add integration test directory with basic RPC tests designed for SurfPool local validator; not run in CI automatically.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fe249a4`](https://github.com/openbudgetfun/solana_kit/commit/fe249a46e06edf2f4cc924b30c4c463e8ea9a910) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Enable public_member_api_docs lint

_Packages:_ _solana_kit_

Enable public_member_api_docs lint rule with file-level suppressions for incremental backfill.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add examples/ directory with 26 scripts

_Packages:_ _solana_kit_

Add a top-level examples/ directory with 26 standalone…

Add a top-level `examples/` directory with 26 standalone Dart example scripts and a README covering addresses, keys, codecs, structs, options, errors, sysvars, offchain messages, transaction building/signing/confirmation, RPC, subscriptions, accounts, Helius DAS/priority-fees, functional pipe, fast-stable-stringify, address comparator, union codecs, and transaction serialisation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add solana-program reference repos

_Packages:_ _solana_kit_

Add solana-program/ reference repos to clone:repos with…

Add solana-program/* reference repos to clone:repos with pinned version tracking for all 11 program repos.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`0d394fb`](https://github.com/openbudgetfun/solana_kit/commit/0d394fba231feb79137da5f74a015180a2c13c99) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add transaction execution boundary

_Packages:_ _solana_kit_, _solana_kit_instruction_plans_

Add a higher-level transaction execution boundary that…

Add a higher-level transaction execution boundary that combines instruction-plan planning, signing, and sending into a single structured outcome, with a signer-based convenience wrapper for common app flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`69db7ef`](https://github.com/openbudgetfun/solana_kit/commit/69db7ef8dce81e51e5980c4254a382c76082617c) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add account client and RPC response models

_Packages:_ _solana_kit_, _solana_kit_rpc_api_, _solana_kit_rpc_types_

Add a higher-level Solana account client plus typed RPC…

Add a higher-level Solana account client plus typed RPC response wrappers for common account, balance, blockhash, and multi-account request flows.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`aa54336`](https://github.com/openbudgetfun/solana_kit/commit/aa54336c1e9a6c4ae5df1adafc1822cfccf342fa) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add upstream parity test harness

_Packages:_ _solana_kit_

Add an executable upstream parity harness that compares…

Add an executable upstream parity harness that compares selected Solana Kit Dart behaviors against the tracked `@solana/kit` release in CI and local development.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bf0f168`](https://github.com/openbudgetfun/solana_kit/commit/bf0f168606f039e9029a4f5c25942e591ef9940d) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Expose upstream-compatible client helpers

_Packages:_ _solana_kit_

Expose the new upstream-compatible convenience surface…

Expose the new upstream-compatible convenience surface from the umbrella package. This re-exports the fixed-point helpers, functional helpers, compute-unit estimation helpers, Dart-native client/plugin composition APIs, identity and payer capability interfaces, and slot-tracking stream/reactive-store helpers used to combine an initial RPC value with live subscription updates.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Fix MDT product callout rendering so preferred-path

_Packages:_ _solana_kit_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`a7355ff`](https://github.com/openbudgetfun/solana_kit/commit/a7355ffb6f9227fcf9462cdc1d13608fa3d5242b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Move reference repos to config JSON

_Packages:_ _solana_kit_

Move reference repo pins out of devenv.nix into…

Move reference repo pins out of `devenv.nix` into `config/reference-repos.json`, and teach `clone:repos` to read that config and report repo status.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`731da8d`](https://github.com/openbudgetfun/solana_kit/commit/731da8da45af0a34e66ad9347f19dbcd6b461485) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Re-export byte containment helpers

_Packages:_ _solana_kit_codecs_

Re-export byte containment compatibility helpers from the…

Re-export byte containment compatibility helpers from the umbrella codecs package so callers can access the @solana/kit 6.9 byte APIs through the expected public entrypoint.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Align byte containment with upstream

_Packages:_ _solana_kit_codecs_core_

Align byte containment helpers with upstream behavior for…

Align byte containment helpers with upstream behavior for negative offsets and boundary checks, including regression coverage for offset handling.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add UTF-8 null-char decoding controls

_Packages:_ _solana_kit_codecs_strings_

Add strict and explicit UTF-8 null-character decoding…

Add strict and explicit UTF-8 null-character decoding controls to `solana_kit_codecs_strings`, while preserving the default `@solana/kit` compatibility behavior that strips decoded null characters.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`ad3e6ad`](https://github.com/openbudgetfun/solana_kit/commit/ad3e6ad2cef3860dd70c2802650b773a25f3b356) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add fixed-point helper package

_Packages:_ _solana_kit_fixed_points_

Add the fixed-point helper package that ports…

Add the fixed-point helper package that ports @solana/fixed-points APIs, including binary and decimal fixed-point arithmetic, conversions, comparisons, formatting, codecs, parsing helpers, rounding, and raw range utilities.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add upstream 6.9 Solana error codes

_Packages:_ _solana_kit_errors_

Add upstream 6.9 Solana error codes and messages for transaction account/instruction limit failures, invalid v1 config masks and config value kinds, filesystem write failures, and JSON-RPC errors with BigInt-compatible codes.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add downstream error codes

_Packages:_ _solana_kit_errors_

Add Solana error codes and messages for downstream…

Add Solana error codes and messages for downstream package features: fixed-point arithmetic (`fixedPoints*`), wallet connectivity (`wallet*`), UTF-8 null-character validation (`codecsStringContainsNullCharacters`), and key-pair grinding/filesystem helpers (`keysInvalidBase58InGrindRegex`, `keysWriteKeyPairUnsupportedEnvironment`).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Document upstream error-code typo

_Packages:_ _solana_kit_errors_

Document the upstream error-code typo for…

Document the upstream error-code typo for accountsOneOrMoreAccountsNotFound (32300001) in codes.dart.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add standardized error construction helpers

_Packages:_ _solana_kit_errors_

Add shared Solana error construction helpers and context…

Add shared Solana error construction helpers and context key conventions, then migrate representative account, RPC, and Helius call sites to preserve structured cause metadata more consistently.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`63778e5`](https://github.com/openbudgetfun/solana_kit/commit/63778e5865705ebf4370427a35466d2d3b2c75b4) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Use version-aware transaction size limits

_Packages:_ _solana_kit_instruction_plans_

Make transaction planning use version-aware…

Make transaction planning use version-aware transaction-message size limits, preserve compile-time transaction limit precedence, and retry packing with the correct transaction limit behavior when a plan exceeds Agave packet constraints.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add structural equality and toString to AccountMeta

_Packages:_ _solana_kit_instructions_

Implement `operator ==` and `hashCode` on `AccountMeta`, `AccountLookupMeta`, and `Instruction` so these core value types behave correctly in `Set`s, as `Map` keys, and in test assertions using `expect(...)`.

`AccountMeta` compares by `address` and `role`. `AccountLookupMeta` extends that to also compare `addressIndex` and `lookupTableAddress`. `Instruction` compares `programAddress`, and performs deep equality on the `accounts` list and `data` byte buffer.

All three classes also gain a `toString()` override that prints their fields, making debug output and test failure messages far more readable than the default `Instance of ...` representation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add key-pair filesystem and grinding compatibility helpers

_Packages:_ _solana_kit_keys_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Zero KeyPair private key memory on GC

_Packages:_ _solana_kit_keys_

SEC-02: Add Finalizer-based memory zeroing for KeyPair private keys.

- Added `Finalizer` that zeros internal key bytes when `KeyPair` is garbage collected
- Added `dispose()` method to explicitly zero key bytes on demand
- Added `isDisposed` property to check if `dispose()` has been called
- `privateKey` and `publicKey` getters now throw `StateError` after `dispose()`
- Documented limitations of Dart's GC-based finalization
- 4 new tests covering dispose behavior

_Owner:_ Ifiok Jr. · _Introduced in:_ [`3c175c3`](https://github.com/openbudgetfun/solana_kit/commit/3c175c3a852f04df89145f1edc5c458abaab253d) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### Improve handwritten test coverage across RPC

_Packages:_ _solana_kit_rpc_api_, _solana_kit_rpc_subscriptions_channel_websocket_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`68fa2e3`](https://github.com/openbudgetfun/solana_kit/commit/68fa2e39683da95e11b79ec3d45e03624948cbe9) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Expand RPC API test coverage

_Packages:_ _solana_kit_rpc_api_

Expand RPC API test coverage with per-method config/params tests and shared param-builder contract tests.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Replace unsafe .cast() with JsonReader

_Packages:_ _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_types_

Introduce internal JsonReader helper that replaces unsafe…

Introduce internal `JsonReader` helper that replaces unsafe `.cast<T>()` list

casts and bare `as` casts in all `fromJson` factories with explicit typed accessors. Parse errors now surface at construction time via a descriptive `FormatException` that includes the field name, rather than deferring until element access. All ten type files (`das_types`, `enhanced_types`, `zk_types`, `wallet_types`, `webhook_types`, `rpc_v2_types`, `auth_types`, `staking_types`, `priority_fee_types`, `smart_transaction_types`) have been migrated. The public API is unchanged.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add equality to value types

_Packages:_ _solana_kit_rpc_api_, _solana_kit_rpc_parsed_types_, _solana_kit_rpc_spec_types_, _solana_kit_rpc_types_

Add == / hashCode / toString to value types across…

Add == / hashCode / toString to value types across rpc_types, rpc_api, rpc_parsed_types, rpc_spec_types, instructions, transaction_messages, and transaction_confirmation.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Align sendTransaction and simulate with 6.9

_Packages:_ _solana_kit_rpc_api_

Align sendTransaction and simulateTransaction behavior…

Align sendTransaction and simulateTransaction behavior with upstream 6.9, including preflight metadata defaults, nullable Agave metadata, BigInt JSON-RPC error code handling, and expanded simulation response metadata types.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add Agave v3 parsed vote-account fields

_Packages:_ _solana_kit_rpc_parsed_types_

Add Agave v3 parsed vote-account fields and parsing coverage so vote account responses accept the new epoch credit and commission metadata returned by recent validators.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Document stream-first subscription preference

_Packages:_ _solana_kit_rpc_subscriptions_, _solana_kit_subscribable_

Document stream-first preference in solana_kit_subscribable and rpc_subscriptions; DataPublisher remains as a compatibility layer.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### Add typed RPC subscription methods

_Packages:_ _solana_kit_rpc_subscriptions_

Add typed convenience methods for common Solana RPC…

Add typed convenience methods for common Solana RPC subscription requests so callers can avoid assembling notification names and params manually.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`0bb3747`](https://github.com/openbudgetfun/solana_kit/commit/0bb37479312578d167009108206a573555be6156) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add RPC subscription store helpers

_Packages:_ _solana_kit_rpc_subscriptions_

Add pending RPC subscription reactive-store helpers and…

Add pending RPC subscription reactive-store helpers and typed subscription composition coverage for the upstream 6.9 subscription utility surface.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Insecure WebSocket only in debug mode

_Packages:_ _solana_kit_rpc_subscriptions_channel_websocket_

SEC-04: Restrict allowInsecureWs to debug mode only.

- In release/profile mode, `ws://` URLs are now always rejected regardless of the `allowInsecureWs` flag
- Prevents accidental use of insecure WebSocket connections in production
- Updated documentation to reflect the debug-only behavior

_Owner:_ Ifiok Jr. · _Introduced in:_ [`f462724`](https://github.com/openbudgetfun/solana_kit/commit/f46272452cbc81021286b10e0e739b27b40c5b5b) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### SSRF protection for WebSocket URLs

_Packages:_ _solana_kit_rpc_subscriptions_channel_websocket_

SEC-05: Add SSRF protection for WebSocket URLs.

- Block connections to private/internal hosts by default (localhost, 10.x, 172.16-31.x, 192.168.x, 169.254.x, fc/fd::)
- Added `allowPrivateHosts` option to `WebSocketChannelConfig` for local development
- 5 new SSRF protection tests

_Owner:_ Ifiok Jr. · _Introduced in:_ [`e77206e`](https://github.com/openbudgetfun/solana_kit/commit/e77206e37c0f793e9dc2b6b1632131b20ef9b959) · _Last updated in:_ [`12316d5`](https://github.com/openbudgetfun/solana_kit/commit/12316d50aadfeefc7563665fbad750e37cba1fd5)

#### Add abortable websocket connection behavior

_Packages:_ _solana_kit_rpc_subscriptions_channel_websocket_

Add abortable websocket connection behavior and tests so subscription channels can be cancelled consistently with upstream promise abort helpers.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add version to solana-client header

_Packages:_ _solana_kit_rpc_transport_http_

Add version constant plumbing so the solana-client header…

Add version constant plumbing so the solana-client header includes the package version.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add SOL conversion helpers alongside lamports helpers

_Packages:_ _solana_kit_rpc_types_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Deduplicate equivalent noop signers

_Packages:_ _solana_kit_signers_

Align signer utilities with upstream 6.9 by deduplicating…

Align signer utilities with upstream 6.9 by deduplicating equivalent noop signers, preserving fee-payer signer config when transaction message config changes, supporting key-pair signer grinding helpers, and including useful assertion context for invalid signer-like values.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add reactive store for subscription flows

_Packages:_ _solana_kit_subscribable_

Add the reactive store helper used by slot-tracking…

Add the reactive store helper used by slot-tracking RPC/subscription flows, including subscriber notification, initial value, and update coverage.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`0ee3d60`](https://github.com/openbudgetfun/solana_kit/commit/0ee3d604028aa8a0fcbcf7e7da9840db39755ccf)

#### Add shared test helpers (FakeRpcTransport

_Packages:_ _solana_kit_test_matchers_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Add ==

_Packages:_ _solana_kit_transaction_confirmation_

Add `==`, `hashCode`, and `toString` to `SignatureStatus` for structural equality support.

`SignatureStatus` now implements value-type equality based on its `confirmationStatus` and `err` fields. This enables correct behavior when using `SignatureStatus` instances in `Set`s, as `Map` keys, and in test assertions that compare expected vs. actual status values.

A `toString` override is also included for readable diagnostics during debugging and test failure output.

This completes the value-semantics initiative (issue #114) for the transaction confirmation package, which was listed in the original scope but omitted from the changeset frontmatter.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`6fd8642`](https://github.com/openbudgetfun/solana_kit/commit/6fd8642354f778981f1ef9b84cdbd611326b680b) · _Last updated in:_ [`5bccc42`](https://github.com/openbudgetfun/solana_kit/commit/5bccc42120e7bc038fc507719727500364a43bd9)

#### Add == and hashCode to public value-type

_Packages:_ _solana_kit_transaction_messages_

Add `==` and `hashCode` to public value-type, config, and response classes.

Implements issue #114. All config, request, and response classes in the RPC layer, as well as core instruction and transaction-message value types, now support structural equality. This enables correct use in `Set`s, as `Map` keys, and in test assertions.

All affected classes are also annotated with `@immutable` to satisfy the `avoid_equals_and_hash_code_on_mutable_classes` lint rule, since every field is already `final`.

Packages that did not previously depend on `meta` now declare `meta: any` explicitly (`solana_kit_rpc_api`, `solana_kit_transaction_confirmation`, `solana_kit_rpc_spec_types`, `solana_kit_rpc_parsed_types`).

_Owner:_ Ifiok Jr. · _Introduced in:_ [`29e8823`](https://github.com/openbudgetfun/solana_kit/commit/29e882327cb854212c39f920bb2ec0eee768a7fd) · _Last updated in:_ [`5bccc42`](https://github.com/openbudgetfun/solana_kit/commit/5bccc42120e7bc038fc507719727500364a43bd9)

#### Add full transaction message v1 support

_Packages:_ _solana_kit_transaction_messages_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

#### Add version-aware transaction size helpers and constants

_Packages:_ _solana_kit_transactions_

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b) · _Last updated in:_ [`a526ea3`](https://github.com/openbudgetfun/solana_kit/commit/a526ea31d2faf8581f9310013ee2ee4b169f9591)

## 0.3.1 (2026-03-30)

### Fixes

- Improve documentation reuse and guidance across the workspace by expanding shared `mdt` blocks, projecting them into synchronized Dart library doc comments, adding analyzable doc-comment snippet tests, and broadening accounts/signers/codecs examples in the docs site and package READMEs.
- Fix release tooling portability on macOS/BSD userlands by removing the Bash 4 `mapfile` dependency and GNU-awk-specific parsing from the workspace sync scripts. Also fix the mobile wallet adapter example and Android compile check to use local workspace overrides so CI can resolve unreleased `solana_kit_*` package versions correctly.

## 0.3.0 (2026-03-29)

### Breaking Changes

#### Sync with upstream @solana/kit v6.1.0 → v6.5.0 changes.

#### solana_kit_errors (minor)

- Add new error codes: `failedToSendTransaction`, `failedToSendTransactions`, `signerWalletAccountCannotSignTransaction`, 8 new transaction error codes (`transactionCannotEncodeWithEmptyMessageBytes`, `transactionCannotDecodeEmptyTransactionBytes`, `transactionVersionZeroMustBeEncodedWithSignaturesFirst`, `transactionSignatureCountTooHighForTransactionBytes`, `transactionInvalidConfigMaskPriorityFeeBits`, `transactionInvalidNonceAccountIndex`, `transactionInvalidConfigValueKind`, `transactionInstructionHeadersPayloadsMismatch`), and 2 new codec error codes (`codecsInvalidPatternMatchValue`, `codecsInvalidPatternMatchBytes`).
- Capitalize all instruction error messages for consistency.
- Fix BORSH_IO_ERROR: remove stale `$encodedData` interpolation.
- Fix `instructionErrorUnknown` message: was empty, now `'The instruction failed with the error: $errorName'`.
- Update `transactionVersionNumberNotSupported` max supported version from 0 to 1.

#### solana_kit_codecs_data_structures (minor)

- Add `getPatternMatchEncoder`, `getPatternMatchDecoder`, and `getPatternMatchCodec` functions for selecting codecs based on value/byte pattern matching.

#### solana_kit_codecs_core (patch)

- Fix `containsBytes` to avoid unnecessary array slicing/cloning when using negative offsets matching the array length.
- Fix `addDecoderSentinel` to handle negative offsets properly.

#### solana_kit_codecs_strings (patch)

- Fix `getBaseXDecoder` and `getBaseXResliceDecoder` to avoid unnecessary array slicing/cloning when using negative offsets matching the array length.

#### solana_kit_signers (minor)

- Add `partiallySignTransactionWithSigners`, `signTransactionWithSigners`, and `signAndSendTransactionWithSigners` functions that accept a set of signers and a compiled `Transaction` directly, without requiring signers to be embedded in a transaction message.
- Add `assertContainsResolvableTransactionSendingSigner` to validate that a set of signers contains an unambiguously resolvable sending signer.
- The existing transaction message helpers now delegate to these new functions internally.

#### solana_kit_instruction_plans (patch)

- Add `abortReason` and `transactionPlanResult` to the `instructionPlansFailedToExecuteTransactionPlan` error context.

### Features

#### Add additive next-step ergonomics and maintenance tooling without breaking the existing lower-level APIs.

- Add `Rpc.getEpochInfo()` to the typed RPC convenience surface.
- Add polling-based `waitForTransactionConfirmation(...)` and `sendAndConfirmTransaction(...)` helpers for signed transactions.
- Add local benchmark scripts for address validation, transaction wire encoding, and BigInt-aware JSON parsing.
- Add an upstream compatibility metadata check script plus CI coverage.
- Complete Codama PDA rendering by generating `getProgramDerivedAddress(...)` calls instead of `UnimplementedError` placeholders.
- Expand READMEs and docs to explain the new workflows.

#### Improve Android native wallet adapter parity and add CI Android compile verification.

- Replace wallet stub behavior with walletlib-backed scenario/request handling.
- Add Digital Asset Links native bridge and Dart API surface.
- Harden local/remote transport behavior and request routing.
- Add a CI check that compiles a temporary Flutter Android app using the plugin.

#### Add a typed RPC convenience facade for common Solana JSON-RPC calls.

- Add generic `Rpc.request<TResponse>()` support in `solana_kit_rpc_spec`.
- Add `SolanaRpcMethods` extension helpers in `solana_kit_rpc` for common RPC methods.
- Expand docs with reusable markdown templates (`mdt`) and reusable Dart doc templates.

#### Harden transaction lifetime typing and compilation invariants.

- Replace `TransactionLifetimeConstraint` `Object` alias with a sealed hierarchy.
- Remove the internal `_NoLifetime` fallback from `compileTransaction`.
- Enforce lifetime presence during compile and throw explicit `SolanaErrorCode` values for invalid lifetime states.
- Expand transaction compile tests for missing and invalid lifetime paths.

#### Add Phase 4 advanced ergonomics and performance improvements.

- Add typed union helpers (`Union2`/`Union3`) with strongly-typed codec helpers.
- Add optional isolate-backed BigInt JSON decoding via `parseJsonWithBigIntsAsync` and Solana HTTP transport flags.
- Add typed error-domain helpers layered over numeric `SolanaErrorCode` values (`SolanaErrorDomain`, domain classifiers, and extensions).
- Expand README/API docs and shared mdt templates for these features.

### Fixes

- Move renderer Node tooling to a root pnpm workspace, pin workspace pnpm/node versions, and run renderer publish through workspace-aware pnpm commands.
- Update all upstream `@solana/kit` version references from 6.1.0 to 6.5.0 in documentation and README files.
- Improve workspace documentation with richer getting-started guides, stronger docs-site coverage, expanded package library doc comments, and deeper mdt integration for shared README and site content.
- Remove duplicate renderer devDependencies that are already provided by the root workspace, and update renderer scripts to invoke shared tools via `pnpm exec`.
- Replace internal workspace dependency constraints with explicit semver constraints (for example, `^0.2.0`) across workspace packages, and remove the workspace dependency lint enforcement added previously.
- Add comprehensive tests across multiple packages to increase code coverage toward 90%.

#### Add explicit repository and package homepage metadata to package pubspecs, and

consolidate package changelogs into a single root `CHANGELOG.md`.

#### Fix workspace lint analysis scope so CI no longer fails when scanning

non-workspace docs sources and nested example app files.

#### Add fluent extension methods to `TransactionMessage` for Dart-idiomatic

composition without requiring function + `.pipe` style.

- `withFeePayer`
- `withBlockhashLifetime`
- `withDurableNonceLifetime`
- `appendInstruction` / `appendInstructions`
- `prependInstruction` / `prependInstructions`

#### Port `@solana/kit` `v6.1.0` parity updates for predicate codecs and

transaction encoding behavior.

- Add `getPredicateEncoder`, `getPredicateDecoder`, and `getPredicateCodec`.
- Add v1 message-first transaction encoding with fixed-length signatures.
- Add transaction malformed message bytes error parity (`5663023`).

#### Fixes CI regressions in the mobile wallet adapter example and Android compile check.

- Renames the Android example package namespace to satisfy `ktlint` package-name rules.
- Hardens `check-mobile-wallet-adapter-android-compile.sh` to use local workspace `solana_kit_*` dependency overrides during temp-app resolution.

## 0.2.1 (2026-02-28)

### Fixes

#### chore: add ktlint to devenv format/lint and CI lint pipeline

##72 by @ifiokjr

### Summary

Adds Kotlin lint/format support to the repository `devenv` workflows and ensures CI runs those checks.

### What changed

- Added `ktlint` to `packages` in `devenv.nix`.
- Updated `fix:format` to run Kotlin formatting via:
  - `ktlint --relative --format` on tracked `*.kt` and `*.kts` files.
- Added a new `lint:kotlin` script that runs:
  - `ktlint --relative` on tracked Kotlin files.
- Updated `lint:all` to include `lint:kotlin` so Kotlin linting is part of the standard CI lint command.
- Updated CI lint step label to explicitly indicate ktlint is included.

### Why

The repo already linted and formatted Dart/Markdown/JSON/YAML paths, but Kotlin files were not covered by the same developer and CI workflows. This aligns Kotlin quality gates with the rest of the codebase.

### Validation

- `dprint check .github/workflows/ci.yml`
- Structural verification of `devenv.nix` script blocks for:
  - `fix:format`
  - `lint:kotlin`
  - `lint:all`

#### chore: add flutter example app for mobile wallet adapter manual testing

### Summary

Adds a runnable Flutter Android example app under `packages/solana_kit_mobile_wallet_adapter/example/` for manual Mobile Wallet Adapter (MWA) testing on device/emulator.

### What changed

- Scaffolded a full Flutter Android example app for `solana_kit_mobile_wallet_adapter`.
- Added manual-test UI flows for:
  - Wallet endpoint detection
  - `authorize`
  - `getCapabilities`
  - `signMessages`
  - `deauthorize`
- Added `example/README.md` with setup instructions and mock wallet installation guidance based on Solana Mobile docs.
- Updated package README with a dedicated "Manual testing app" section linking to the new example and setup guide.

### Why

The previous example was not a runnable Flutter app for end-to-end manual testing with real/emulated wallets. This adds a practical test harness for validating adapter behavior in development.

### Validation

- `flutter pub get` (example app)
- `flutter analyze` (example app)
- `flutter test` (example app)
- `devenv shell -- docs:check`
