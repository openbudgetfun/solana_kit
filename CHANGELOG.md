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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

##### Implement options package and codecs umbrella re-export.

**solana_kit_options** (90 tests):

- Rust-like `Option<T>` sealed class with `Some<T>` and `None<T>` subclasses
- Option codec with 6 encoding modes: prefix-based, zeroes, custom none value,
  combined prefix+zeroes, combined prefix+custom, and absence-based detection
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

- Sealed class hierarchy: `Encoder<T>`, `Decoder<T>`, `Codec<TFrom, TTo>` with
  fixed-size and variable-size variants
- Composition utilities: `combineCodec`, `transformCodec`, `fixCodecSize`,
  `reverseCodec`, `addCodecSentinel`, `addCodecSizePrefix`, `offsetCodec`,
  `padCodec`, `resizeCodec`
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

- Sealed class hierarchy: `Encoder<T>`, `Decoder<T>`, `Codec<TFrom, TTo>` with
  fixed-size and variable-size variants
- Composition utilities: `combineCodec`, `transformCodec`, `fixCodecSize`,
  `reverseCodec`, `addCodecSentinel`, `addCodecSizePrefix`, `offsetCodec`,
  `padCodec`, `resizeCodec`
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
- `SolanaErrorCode` with 200+ categorized error constants covering addresses,
  accounts, codecs, crypto, instructions, keys, RPC, signers, transactions,
  and invariant violations
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

##### Implement foundation utility packages ported from the `@solana/functional` and

`@solana/fast-stable-stringify` TypeScript packages.

**solana_kit_functional**: Adds the `Pipe` extension which provides a `.pipe()`
method on any value for composable functional pipelines. This is the idiomatic
Dart equivalent of the TS `pipe()` function, used extensively for building
transaction messages. Includes 28 tests covering single/multiple transforms,
type changes, object mutation, combining, nested pipes, and error propagation.

**solana_kit_fast_stable_stringify**: Adds `fastStableStringify()` for
deterministic JSON serialization with sorted object keys. Handles all Dart
primitives, BigInt (serialized as `<value>n`), nested maps, lists, and objects
implementing `ToJsonable`. Includes 15 tests matching the upstream SDK's
`json-stable-stringify` reference output.

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

##### Implement foundation utility packages ported from the `@solana/functional` and

`@solana/fast-stable-stringify` TypeScript packages.

**solana_kit_functional**: Adds the `Pipe` extension which provides a `.pipe()`
method on any value for composable functional pipelines. This is the idiomatic
Dart equivalent of the TS `pipe()` function, used extensively for building
transaction messages. Includes 28 tests covering single/multiple transforms,
type changes, object mutation, combining, nested pipes, and error propagation.

**solana_kit_fast_stable_stringify**: Adds `fastStableStringify()` for
deterministic JSON serialization with sorted object keys. Handles all Dart
primitives, BigInt (serialized as `<value>n`), nested maps, lists, and objects
implementing `ToJsonable`. Includes 15 tests matching the upstream SDK's
`json-stable-stringify` reference output.

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

`lint:all` to ensure internal package dependencies use `workspace: true` in
`pubspec.yaml` files.

### 0.1.0 (2026-02-21)

#### Notes

- First 0.1.0 release of this package.

### 0.0.2 (2026-02-21)

#### Features

##### Initial release of shared lint configuration package. Extends `very_good_analysis`

with project-specific overrides: disables `public_member_api_docs` (docs will be
added incrementally) and `lines_longer_than_80_chars` (allows longer lines for
readability in codec/RPC code). All 37 packages in the workspace depend on this
package via `dev_dependencies` for consistent static analysis.

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

##### Implement options package and codecs umbrella re-export.

**solana_kit_options** (90 tests):

- Rust-like `Option<T>` sealed class with `Some<T>` and `None<T>` subclasses
- Option codec with 6 encoding modes: prefix-based, zeroes, custom none value,
  combined prefix+zeroes, combined prefix+custom, and absence-based detection
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

program interaction layers, and the umbrella package. Each package has its
pubspec.yaml with correct workspace dependencies, shared analysis_options.yaml,
and an empty barrel export file ready for implementation.

Package groups scaffolded:

- **RPC Stack**: rpc_types (base types), rpc_spec_types, rpc_spec (specification),
  rpc_api (method definitions), rpc_parsed_types, rpc_transformers (response
  processing), rpc_transport_http (HTTP transport), rpc (primary client)
- **RPC Subscriptions**: rpc_subscriptions_api, rpc_subscriptions_channel_websocket,
  rpc_subscriptions (WebSocket subscription client)
- **Programs & Accounts**: accounts (fetching/decoding), programs (utilities),
  program_client_core (base client), sysvars (system variables)
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

casts and bare `as` casts in all `fromJson` factories with explicit typed
accessors. Parse errors now surface at construction time via a descriptive
`FormatException` that includes the field name, rather than deferring until
element access. All ten type files (`das_types`, `enhanced_types`, `zk_types`,
`wallet_types`, `webhook_types`, `rpc_v2_types`, `auth_types`, `staking_types`,
`priority_fee_types`, `smart_transaction_types`) have been migrated. The public
API is unchanged.

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

Implements issue #114. All config, request, and response classes in the RPC
layer, as well as core instruction and transaction-message value types, now
support structural equality. This enables correct use in `Set`s, as `Map` keys,
and in test assertions.

All affected classes are also annotated with `@immutable` to satisfy the
`avoid_equals_and_hash_code_on_mutable_classes` lint rule, since every field
is already `final`.

Packages that did not previously depend on `meta` now declare `meta: any`
explicitly (`solana_kit_rpc_api`, `solana_kit_transaction_confirmation`,
`solana_kit_rpc_spec_types`, `solana_kit_rpc_parsed_types`).

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
- Enforce lifetime presence during compile and throw explicit `SolanaErrorCode`
  values for invalid lifetime states.
- Expand transaction compile tests for missing and invalid lifetime paths.

#### Add Phase 4 advanced ergonomics and performance improvements.

- Add typed union helpers (`Union2`/`Union3`) with strongly-typed codec helpers.
- Add optional isolate-backed BigInt JSON decoding via
  `parseJsonWithBigIntsAsync` and Solana HTTP transport flags.
- Add typed error-domain helpers layered over numeric `SolanaErrorCode`
  values (`SolanaErrorDomain`, domain classifiers, and extensions).
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
