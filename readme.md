# Solana Kit Dart SDK

<p align="center">
  <img src="./assets/solana-kit-icon.svg" alt="Solana Kit logo" width="140" />
</p>

[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)

A Dart port of the [Solana TypeScript SDK](https://github.com/anza-xyz/kit) (`@solana/kit`). This monorepo mirrors the upstream TS package structure, built with modern Dart 3.10+ features including sealed classes, extension types, records, and patterns.

Documentation website: https://openbudgetfun.github.io/solana_kit/

## Upstream Compatibility

<!-- {=upstreamSupportSection|replace:"__SOLANA_KIT_VERSION__":"6.1.0"} -->

## Upstream Compatibility

- Latest supported `@solana/kit` version: `6.1.0`
- This Dart port tracks upstream APIs and behavior through `v6.1.0`.

<!-- {/upstreamSupportSection} -->

## Quick Start

```dart
import 'package:solana_kit/solana_kit.dart';

// Create an RPC client
final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');

// Generate a key pair
final keyPair = await generateKeyPair();

// Create and send a transaction
final message = createTransactionMessage()
  .pipe(setTransactionMessageFeePayer(keyPair.address))
  .pipe(setTransactionMessageLifetimeUsingBlockhash(blockhash))
  .pipe(appendTransactionMessageInstruction(instruction));
```

<!-- {=typedRpcMethodsSection|replace:"__RPC_IMPORT_PATH__":"package:solana_kit/solana_kit.dart"|replace:"__RPC_URL__":"https://api.mainnet-beta.solana.com"} -->

### Typed RPC methods

When working with an `Rpc`, prefer typed convenience helpers over stringly method calls:

```dart
import 'package:solana_kit/solana_kit.dart';

final rpc = createSolanaRpc(url: 'https://api.mainnet-beta.solana.com');
final slot = await rpc.getSlot().send();
final blockHeight = await rpc.getBlockHeight().send();
```

These helpers forward to canonical params builders in `solana_kit_rpc_api` and return lazy `PendingRpcRequest<T>` values.

<!-- {/typedRpcMethodsSection} -->

## Getting Started

### Prerequisites

- [devenv](https://devenv.sh/) for the development environment
- [direnv](https://direnv.net/) for automatic environment loading

### Setup

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/solana_kit.git
cd solana_kit

# Allow direnv (loads devenv automatically)
direnv allow

# Install binary dependencies
install:all

# Resolve Dart dependencies
dart pub get

# Clone reference repositories
clone:repos
```

### Development

```bash
# Run all lint checks
lint:all

# Run all tests
test:all

# Generate merged test coverage across all packages
test:coverage

# Validate documentation templates and generated workspace docs
docs:check

# Regenerate documentation template consumers and workspace docs
docs:update

# Serve the Jaspr docs site locally
docs:site:serve

# Build static docs output (for GitHub Pages)
docs:site:build

# Run docs build + HTTP smoke checks
docs:site:smoke

# Check tracked upstream compatibility metadata
upstream:check

# Run local benchmark scripts across benchmark-enabled packages
bench:all

# Fix formatting and lint issues
fix:all
```

The merged LCOV report is written to `coverage/lcov.info`.

## Packages

<!-- workspace-summary:start -->

This monorepo contains **40 packages** under `packages/`: **38 publishable** and **2 internal** (`solana_kit_lints`, `solana_kit_test_matchers`).

<!-- workspace-summary:end -->

Most users only need the umbrella package `solana_kit`, but each sub-package can be imported independently for smaller dependency footprints.

### Umbrella Packages

| Package                                   | Description                                                                   |
| ----------------------------------------- | ----------------------------------------------------------------------------- |
| [`solana_kit`](#solana_kit)               | Single import for the entire SDK. Re-exports all public packages.             |
| [`solana_kit_codecs`](#solana_kit_codecs) | Single import for all codec functionality. Re-exports all codec sub-packages. |

### Error Handling

| Package                                   | Description                                                                                                               |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| [`solana_kit_errors`](#solana_kit_errors) | Foundation package. Defines `SolanaError`, numeric error codes, and structured error context used by every other package. |

### Addresses & Keys

| Package                                         | Description                                                                                                          |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| [`solana_kit_addresses`](#solana_kit_addresses) | Base58-encoded Solana addresses, validation, program-derived addresses (PDAs), and address comparison.               |
| [`solana_kit_keys`](#solana_kit_keys)           | Ed25519 key pair generation, private/public key types, and signature creation.                                       |
| [`solana_kit_signers`](#solana_kit_signers)     | Signer interfaces: message signers, transaction signers, fee payer signers, modifying signers, and key pair signers. |

### Codecs (Binary Serialization)

| Package                                                                   | Description                                                                                                                          |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| [`solana_kit_codecs_core`](#solana_kit_codecs_core)                       | Core `Codec<T>`, `Encoder<T>`, and `Decoder<T>` interfaces with composition utilities (size prefixing, padding, sentinels, offsets). |
| [`solana_kit_codecs_numbers`](#solana_kit_codecs_numbers)                 | Numeric codecs: `u8`–`u128`, `i8`–`i128`, `f32`, `f64`, and `shortU16` in little-endian format.                                      |
| [`solana_kit_codecs_strings`](#solana_kit_codecs_strings)                 | String codecs: `base10`, `base16`, `base58`, `base64`, `utf8`, and generic `baseX` encoding.                                         |
| [`solana_kit_codecs_data_structures`](#solana_kit_codecs_data_structures) | Composite codecs: `struct`, `array`, `tuple`, `union`, `map`, `set`, `boolean`, `nullable`, `bytes`, and `bitArray`.                 |
| [`solana_kit_options`](#solana_kit_options)                               | Rust-style `Option<T>` type with `Some`/`None` variants and a dedicated codec for on-chain optional fields.                          |

### Instructions & Transactions

| Package                                                               | Description                                                                                                                          |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| [`solana_kit_instructions`](#solana_kit_instructions)                 | Core `Instruction` and `AccountMeta` types with account role definitions (signer, writable, readonly).                               |
| [`solana_kit_transaction_messages`](#solana_kit_transaction_messages) | Build and compile transaction messages with support for v0 messages, address table lookups, blockhash lifetimes, and durable nonces. |
| [`solana_kit_transactions`](#solana_kit_transactions)                 | Transaction compilation, signature collection, wire-format encoding, and size calculation.                                           |
| [`solana_kit_offchain_messages`](#solana_kit_offchain_messages)       | Off-chain message signing with envelope formatting, domain specifications, and signatory tracking.                                   |
| [`solana_kit_instruction_plans`](#solana_kit_instruction_plans)       | Plan multi-step operations as sequential or parallel instruction trees, then execute them as batched transactions.                   |

### RPC Client

| Package                                                           | Description                                                                                                                                |
| ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [`solana_kit_rpc`](#solana_kit_rpc)                               | High-level RPC client factory with request coalescing, deduplication, and default configuration. The main entry point for RPC calls.       |
| [`solana_kit_rpc_api`](#solana_kit_rpc_api)                       | Type-safe definitions for all ~60 Solana JSON-RPC methods (`getAccountInfo`, `getBalance`, `sendTransaction`, etc.).                       |
| [`solana_kit_rpc_types`](#solana_kit_rpc_types)                   | Shared types: `AccountInfo`, `Commitment`, `Lamports`, `TokenAmount`, `ClusterUrl`, `RpcResponse<T>`, and encoding helpers.                |
| [`solana_kit_rpc_spec`](#solana_kit_rpc_spec)                     | Core JSON-RPC 2.0 protocol: `Rpc`, `RpcApi`, and `RpcTransport` interfaces.                                                                |
| [`solana_kit_rpc_spec_types`](#solana_kit_rpc_spec_types)         | Low-level RPC protocol types: `RpcRequest`, `RpcResponse<T>`, `RpcMessage`, and `JsonBigInt`.                                              |
| [`solana_kit_rpc_parsed_types`](#solana_kit_rpc_parsed_types)     | Typed representations of parsed account data for token, stake, vote, config, nonce, and other native program accounts.                     |
| [`solana_kit_rpc_transformers`](#solana_kit_rpc_transformers)     | Request/response transformation middleware: default commitment injection, BigInt handling, integer overflow detection, and error throwing. |
| [`solana_kit_rpc_transport_http`](#solana_kit_rpc_transport_http) | HTTP transport implementation for RPC communication using the `http` package.                                                              |

### RPC Subscriptions

| Package                                                                                             | Description                                                                                                                         |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| [`solana_kit_rpc_subscriptions`](#solana_kit_rpc_subscriptions)                                     | High-level subscription client factory with connection pooling, auto-ping, and subscription coalescing.                             |
| [`solana_kit_rpc_subscriptions_api`](#solana_kit_rpc_subscriptions_api)                             | Type-safe definitions for all Solana subscription methods (`accountNotifications`, `slotNotifications`, `logsNotifications`, etc.). |
| [`solana_kit_rpc_subscriptions_channel_websocket`](#solana_kit_rpc_subscriptions_channel_websocket) | WebSocket transport for RPC subscriptions using `web_socket_channel`.                                                               |
| [`solana_kit_subscribable`](#solana_kit_subscribable)                                               | Observable data publisher pattern with conversions to Dart `Stream` and async iterables.                                            |

### Accounts & Programs

| Package                                                             | Description                                                                                                        |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [`solana_kit_accounts`](#solana_kit_accounts)                       | Fetch, decode, and parse on-chain account data with typed `Account<T>` and `MaybeAccount<T>` wrappers.             |
| [`solana_kit_programs`](#solana_kit_programs)                       | Program error handling utilities: `ProgramError` representation and program-specific error detection.              |
| [`solana_kit_program_client_core`](#solana_kit_program_client_core) | Core utilities for building typed program clients: instruction input resolution and self-fetching account helpers. |
| [`solana_kit_sysvars`](#solana_kit_sysvars)                         | Type-safe access to Solana sysvars: `Clock`, `Rent`, `EpochSchedule`, `SlotHashes`, `StakeHistory`, and more.      |

### Transaction Confirmation

| Package                                                                       | Description                                                                                                                   |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| [`solana_kit_transaction_confirmation`](#solana_kit_transaction_confirmation) | Multiple confirmation strategies: block height polling, nonce invalidation, signature watching, timeout, and strategy racing. |

### Utilities

| Package                                                                 | Description                                                                                                                |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| [`solana_kit_functional`](#solana_kit_functional)                       | Adds a `.pipe()` extension for functional pipeline composition, used throughout the SDK for building transaction messages. |
| [`solana_kit_fast_stable_stringify`](#solana_kit_fast_stable_stringify) | Deterministic JSON serialization with sorted keys, used for request deduplication and hashing.                             |

### Mobile Wallet Adapter

| Package                                                                                   | Description                                                                                                                            |
| ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| [`solana_kit_mobile_wallet_adapter_protocol`](#solana_kit_mobile_wallet_adapter_protocol) | Pure Dart MWA v2.0 protocol: P-256 cryptography, AES-128-GCM encryption, HELLO handshake, JSON-RPC messaging, association URIs.        |
| [`solana_kit_mobile_wallet_adapter`](#solana_kit_mobile_wallet_adapter)                   | Flutter plugin for MWA on Android. dApp-side session management, wallet-side scenario callbacks, Kit-integrated typed APIs. iOS no-op. |

### Internal (Not Published)

| Package                                                 | Description                                                                               |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [`solana_kit_lints`](#solana_kit_lints)                 | Shared lint rules based on `very_good_analysis` used across the monorepo.                 |
| [`solana_kit_test_matchers`](#solana_kit_test_matchers) | Custom test matchers for addresses, byte arrays, error codes, and transaction assertions. |

## Package Details

### solana_kit

The umbrella package. Import this one package to get access to the entire SDK:

```dart
import 'package:solana_kit/solana_kit.dart';
```

Re-exports all public sub-packages with namespace conflict resolution. Ideal for applications that use multiple SDK features. Use individual sub-packages instead when you want to minimize transitive dependencies.

### solana_kit_errors

The foundation of the SDK's error handling. Every other package depends on this. Provides:

- `SolanaError` — a structured error class carrying a numeric code and contextual data
- `SolanaErrorCode` — an abstract final class with `static const int` codes covering addresses, codecs, keys, RPC, instructions, transactions, signers, and more
- `isSolanaError()` — a type guard for checking error codes

Exists because: Solana operations fail in many specific ways (invalid addresses, encoding mismatches, RPC errors, signing failures). Structured error codes let calling code handle failures precisely rather than parsing error message strings.

### solana_kit_addresses

Handles Solana's base58-encoded 32-byte addresses:

- `Address` — a zero-overhead extension type wrapping a validated base58 string
- `address()` — factory that validates and creates addresses
- `ProgramDerivedAddress` — PDA generation from seeds and program IDs
- `AddressCodec` — base58 encoding/decoding for wire formats

Exists because: Addresses are the most fundamental Solana primitive. Encoding them as an extension type catches invalid addresses at construction time with zero runtime cost, and PDA derivation is needed for interacting with most Solana programs.

### solana_kit_keys

Ed25519 key pair operations:

- `KeyPair` — holds a 32-byte private key and public key
- `generateKeyPair()` — cryptographically secure random key generation
- `createKeyPairFromBytes()` — reconstruct from a 64-byte seed
- Signature creation and verification

Exists because: Every transaction on Solana requires Ed25519 signatures. This package wraps the `ed25519_edwards` library with Solana-specific key formats and validation.

### solana_kit_signers

Defines a hierarchy of signer interfaces:

- `MessagePartialSigner` / `TransactionPartialSigner` — sign without needing all signatures
- `TransactionSendingSigner` — signs and submits in one step
- `MessageModifyingSigner` / `TransactionModifyingSigner` — can alter content before signing (for wallets that add metadata)
- `KeyPairSigner` — concrete signer backed by a `KeyPair`
- `NoopSigner` — placeholder for addresses that will be signed externally

Exists because: Solana transactions can require multiple signers with different capabilities. A hardware wallet signs differently from an in-memory key pair, and a custodial service may need to modify the transaction before signing. The interface hierarchy captures these real-world signing patterns.

### solana_kit_codecs_core

The codec framework's foundation:

- `Codec<T>` — generic encoder + decoder pair
- `FixedSizeCodec<T>` / `VariableSizeCodec<T>` — size-aware variants
- Composition: `addCodecSizePrefix()`, `addCodecSentinel()`, `offsetCodec()`, `fixCodecSize()`, `padCodec()`, `reverseCodec()`, `transformCodec()`

Exists because: Solana's on-chain data is binary. A composable codec system lets you describe complex layouts declaratively (e.g., "a u32 length prefix followed by N structs") rather than hand-writing byte manipulation.

### solana_kit_codecs_numbers

Numeric codecs for all integer and float widths:

- Unsigned: `u8`, `u16`, `u32`, `u64`, `u128`
- Signed: `i8`, `i16`, `i32`, `i64`, `i128`
- Floats: `f32`, `f64`
- `shortU16` — Solana's compact u16 encoding used in transaction headers

All use little-endian byte order, matching Solana's on-chain format.

Exists because: On-chain data uses fixed-width integers at specific byte offsets. These codecs handle endianness, overflow detection, and BigInt support for values exceeding 64 bits.

### solana_kit_codecs_strings

String and base encoding codecs:

- `base58` — Solana addresses and transaction signatures
- `base64` — account data in RPC responses
- `base16` — hex encoding
- `base10` — decimal string encoding
- `utf8` — UTF-8 text encoding
- `baseX()` / `baseXReslice()` — generic base-N encoding

Exists because: Solana uses multiple string encodings across its APIs. Base58 for addresses, base64 for account data, hex for debugging. Having them as composable codecs means they integrate with the rest of the codec system.

### solana_kit_codecs_data_structures

High-level composite codecs:

- `struct()` — named fields, like a C struct
- `array()` — fixed or variable-length arrays
- `tuple()` — ordered unnamed fields
- `union()` / `discriminatedUnion()` — tagged variants (Rust enums)
- `map()` / `set()` — collection types
- `boolean`, `nullable()`, `bytes`, `bitArray()`, `unit`, `constant()`

Exists because: On-chain program data is structured as structs, enums, and arrays. These codecs let you describe Solana account layouts and instruction data as composable type-safe definitions.

### solana_kit_options

Rust-style `Option<T>` type with codec support:

- `Option<T>` — sealed class with `Some<T>` and `None` variants
- `OptionCodec<T>` — encodes as a discriminator byte (0/1) followed by the value
- `unwrapOption()` / `unwrapOptionRecursively()` — extraction helpers

Exists because: Solana programs written in Rust serialize `Option<T>` as a 1-byte discriminator followed by the value. This codec faithfully represents that layout so Dart code can read and write optional on-chain fields correctly.

### solana_kit_codecs

Umbrella package that re-exports:

- `solana_kit_codecs_core`
- `solana_kit_codecs_numbers`
- `solana_kit_codecs_strings`
- `solana_kit_codecs_data_structures`
- `solana_kit_options`

Exists because: Codec work typically requires types from multiple sub-packages. This single import avoids managing five separate imports.

### solana_kit_instructions

Core instruction types:

- `Instruction` — a program ID, list of account metas, and binary data
- `AccountMeta` — an account's address, signer status, and writability
- Account roles: `isSigner`, `isWritable`, and their combinations

Exists because: Instructions are the atomic unit of Solana computation. Every interaction with a program — transferring SOL, creating accounts, invoking DeFi protocols — is an instruction. This package defines the types that all higher-level packages build upon.

### solana_kit_transaction_messages

Transaction message construction:

- `createTransactionMessage()` — start a new message
- `setTransactionMessageFeePayer()` — set who pays
- `setTransactionMessageLifetimeUsingBlockhash()` — set expiry
- `appendTransactionMessageInstruction()` — add instructions
- `compileTransactionMessage()` — compile to wire format
- Support for v0 messages with address table lookups and durable nonce lifetimes

Exists because: Building a Solana transaction requires assembling a fee payer, lifetime, and instructions into a specific binary format. This package provides a pipeline-friendly API that catches errors (missing fee payer, duplicate accounts) at compile time.

### solana_kit_transactions

Transaction compilation and encoding:

- `compileTransaction()` — produce a `Transaction` from a compiled message
- `TransactionCodec` — wire-format serialization
- `transactionSize()` — calculate byte size (important for Solana's 1232-byte limit)
- Signature slot management

Exists because: Compiled transactions need signatures attached and must be serialized to a specific wire format for submission. Size calculation is critical since Solana rejects oversized transactions.

### solana_kit_offchain_messages

Off-chain message signing:

- `Envelope` — wraps a message with domain and signatory metadata
- `compileEnvelope()` — compile into signable bytes
- Domain specifications for application and signing contexts

Exists because: Solana's off-chain message signing standard lets wallets sign arbitrary messages for authentication, proof-of-ownership, and other non-transaction use cases without risking accidental transaction submission.

### solana_kit_instruction_plans

Multi-step transaction planning:

- `InstructionPlan` — tree of sequential and parallel instruction groups
- `TransactionPlanner` — splits plans into optimally-batched transactions
- `TransactionPlanExecutor` — executes plans with signing and submission

Exists because: Complex operations (e.g., initializing a DeFi position) may require dozens of instructions that exceed a single transaction's size limit. Instruction plans let you describe the full operation and automatically batch it into multiple transactions.

### solana_kit_rpc

The primary RPC client:

- `createSolanaRpc()` — factory with sensible defaults
- Request coalescing — deduplicates identical in-flight requests
- Configurable transport and transformers

Exists because: This is the main entry point for talking to Solana validators. It wires together transport, transformers, and the API layer into a ready-to-use client.

### solana_kit_rpc_api

Type-safe definitions for all Solana RPC methods:

- Account queries: `getAccountInfo`, `getBalance`, `getProgramAccounts`, `getTokenAccountsByOwner`
- Block queries: `getBlock`, `getBlockHeight`, `getBlockTime`, `getBlocks`
- Transaction methods: `sendTransaction`, `simulateTransaction`, `getTransaction`, `getSignatureStatuses`
- Cluster info: `getClusterNodes`, `getEpochInfo`, `getHealth`, `getVersion`
- And ~50 more methods

Exists because: Each RPC method has specific parameter shapes and return types. Type-safe definitions catch misuse at compile time and provide IDE autocompletion for all method parameters.

### solana_kit_rpc_types

Shared types across RPC packages:

- `Commitment` — `processed`, `confirmed`, `finalized`
- `Lamports` — SOL amount (u64)
- `AccountInfo<T>` — generic account data wrapper
- `TokenAmount` / `TokenBalance` — SPL token amounts
- `ClusterUrl` — mainnet, devnet, testnet, localnet URLs
- `RpcResponse<T>` — standard response wrapper with context

Exists because: RPC methods share many types (commitments, lamports, account info shapes). Centralizing them avoids duplication and ensures consistency across the API and subscription layers.

### solana_kit_rpc_spec

Core JSON-RPC 2.0 protocol implementation:

- `Rpc` — sends requests through a transport and returns typed responses
- `RpcApi` — defines available methods
- `RpcTransport` — pluggable transport interface

Exists because: The RPC protocol layer is transport-agnostic. Separating it from HTTP allows testing with mock transports and potentially supporting other transports in the future.

### solana_kit_rpc_spec_types

Low-level protocol types:

- `RpcRequest` — method name + params
- `RpcResponse<T>` — result or error
- `JsonBigInt` — BigInt JSON handling

Exists because: These types define the JSON-RPC 2.0 wire format independently of any Solana-specific methods, keeping the protocol layer clean.

### solana_kit_rpc_parsed_types

Typed parsed account data:

- Token accounts, stake accounts, vote accounts
- Config accounts, nonce accounts
- Address lookup table accounts, BPF upgradeable loader accounts
- Sysvar accounts

Exists because: Solana's `jsonParsed` encoding returns structured data for native program accounts. These types provide compile-time safety when working with parsed account data.

### solana_kit_rpc_transformers

Request/response middleware:

- `defaultCommitment` — injects commitment level if not specified
- `bigintDowncast` / `bigintUpcast` — converts between BigInt and int
- `integerOverflow` — detects values that exceed safe integer range
- `throwSolanaError` — converts RPC error responses into `SolanaError`
- `treeTraversal` — recursive transformation of nested response structures

Exists because: Raw RPC responses need post-processing (BigInt conversion, error mapping, default injection). Middleware keeps this logic composable and out of the main client code.

### solana_kit_rpc_transport_http

HTTP transport for RPC:

- `createHttpTransport()` — generic HTTP transport
- `createHttpTransportForSolanaRpc()` — Solana-specific defaults
- Custom header support and request validation

Exists because: HTTP is the standard transport for Solana RPC. Separating it from the protocol layer allows swapping transports and customizing HTTP behavior (headers, timeouts).

### solana_kit_rpc_subscriptions

High-level subscription client:

- `createSolanaRpcSubscriptions()` — factory with defaults
- Connection pooling — reuses WebSocket connections
- Auto-ping — keeps connections alive
- Subscription coalescing — deduplicates identical subscriptions

Exists because: Real-time updates (account changes, new slots, transaction confirmations) require WebSocket subscriptions. This client handles the connection lifecycle complexity.

### solana_kit_rpc_subscriptions_api

Type-safe subscription method definitions:

- `accountNotifications` — account data changes
- `programNotifications` — program account changes
- `logsNotifications` — transaction log output
- `signatureNotifications` — transaction confirmation
- `slotNotifications` / `rootNotifications` — chain progress

Exists because: Like the RPC API package, this provides compile-time safety for subscription parameters and notification shapes.

### solana_kit_rpc_subscriptions_channel_websocket

WebSocket transport for subscriptions:

- `createWebSocketChannel()` — create a managed WebSocket connection
- Configuration for URL, protocols, and reconnection

Exists because: WebSocket is the transport for Solana's subscription API. This package wraps `web_socket_channel` with Solana-specific connection management.

### solana_kit_subscribable

Observable data publisher pattern:

- `DataPublisher<T>` — publish/subscribe event system
- `createStreamFromDataPublisher()` — bridge to Dart `Stream`
- `demultiplexDataPublisher()` — route events by channel

Exists because: The subscription system needs an event distribution mechanism that supports both the RPC subscription protocol and Dart's native `Stream` API.

### solana_kit_accounts

Account data access:

- `fetchAccount<T>()` — fetch and decode an account in one call
- `decodeAccount<T>()` — decode raw account bytes using a codec
- `Account<T>` / `MaybeAccount<T>` — typed wrappers with existence checking

Exists because: Reading on-chain data is the most common RPC operation. This package combines fetching and decoding into a type-safe workflow.

### solana_kit_programs

Program error utilities:

- `ProgramError` — represents errors from on-chain programs
- `isProgramError()` — check if an error came from a specific program

Exists because: On-chain programs return custom error codes. This package provides a standard way to represent and identify program-specific errors.

### solana_kit_program_client_core

Building blocks for typed program clients:

- Instruction input resolution
- Self-fetching account helpers

Exists because: Code-generated program clients (e.g., for SPL Token or custom Anchor programs) share common patterns for resolving instruction inputs and fetching accounts. This package provides those shared utilities.

### solana_kit_sysvars

Type-safe sysvar access:

- `Clock` — current slot, epoch, and Unix timestamp
- `Rent` — rent exemption calculation
- `EpochSchedule` — epoch timing parameters
- `SlotHashes`, `SlotHistory`, `RecentBlockhashes` — recent chain state
- `StakeHistory` — staking metrics per epoch

Exists because: Sysvars are special Solana accounts containing cluster state. Typed access eliminates manual byte parsing and provides meaningful field names.

### solana_kit_transaction_confirmation

Transaction confirmation strategies:

- `ConfirmationStrategyBlockheight` — wait until block height exceeds transaction's last valid block height
- `ConfirmationStrategyRecentSignature` — subscribe to signature status updates
- `ConfirmationStrategyNonce` — watch for nonce advancement (durable transactions)
- `ConfirmationStrategyTimeout` — simple time-based timeout
- `ConfirmationStrategyRacer` — race multiple strategies, first to resolve wins
- `waitForTransactionConfirmation()` — polling-based confirmation helper using transaction lifetime metadata
- `sendAndConfirmTransaction()` — send a fully signed transaction, then wait for confirmation

Exists because: Transaction confirmation on Solana is nuanced. A transaction might be confirmed, finalized, expired, or dropped. Multiple strategies handle different scenarios (recent transactions vs. durable nonce transactions), while the additive happy-path helpers reduce boilerplate for common app flows.

### solana_kit_functional

Functional composition:

- `.pipe()` — chain transformations: `value.pipe(fn1).pipe(fn2).pipe(fn3)`

Exists because: The SDK uses a functional pipeline pattern for building transaction messages. `.pipe()` makes this read naturally in Dart without deeply nested function calls.

### solana_kit_fast_stable_stringify

Deterministic JSON serialization:

- `fastStableStringify()` — JSON output with alphabetically sorted keys

Exists because: Request coalescing and deduplication need to compare JSON payloads. Standard JSON serialization doesn't guarantee key order, so identical objects could produce different strings. Stable stringification solves this.

### solana_kit_lints

Shared lint configuration using `very_good_analysis`. Not published — internal to the monorepo.

### solana_kit_test_matchers

Custom test matchers:

- `addressMatchers` — validate address format and equality
- `bytesMatchers` — compare byte arrays
- `solanaErrorMatchers` — assert specific error codes and context
- `transactionMatchers` — verify signatures and transaction structure

Not published — internal to the monorepo.

### solana_kit_mobile_wallet_adapter_protocol

Pure Dart implementation of the [Solana Mobile Wallet Adapter](https://github.com/solana-mobile/mobile-wallet-adapter) v2.0 protocol. Zero Flutter dependency — usable in server-side Dart, CLI tools, or any Dart environment.

- **P-256 ECDSA/ECDH cryptography** via `pointycastle` (pure Dart, cross-platform)
- **AES-128-GCM encryption** with sequence number AAD for replay attack prevention
- **HKDF-SHA256** key derivation with association public key as salt
- **HELLO_REQ / HELLO_RSP** handshake for session establishment
- **JSON-RPC 2.0** message encryption/decryption
- **Association URI** building and parsing (local + remote)
- **Wallet proxy** with v1/legacy backwards compatibility
- **Sign In With Solana (SIWS)** message builder following EIP-4361
- **JWS ES256** compact serialization for attestation

Exists because: The MWA protocol requires complex cryptographic operations (P-256 ECDH key exchange, HKDF derivation, AES-GCM encrypted messaging) that need to be available in pure Dart for maximum portability. Separating the protocol from the Flutter plugin enables testing without a Flutter environment and reuse in non-Flutter Dart applications.

### solana_kit_mobile_wallet_adapter

Flutter plugin for the [Solana Mobile Wallet Adapter](https://github.com/solana-mobile/mobile-wallet-adapter) protocol on Android. Provides both dApp-side (client) and wallet-side (server) APIs.

- **`transact()`** — one-call session lifecycle: launch wallet, handshake, execute callback, clean up
- **`LocalAssociationScenario`** — full control over local WebSocket sessions with retry logic
- **`RemoteAssociationScenario`** — remote sessions via WebSocket reflector (cross-device)
- **`KitMobileWallet`** — typed API working with base64 payloads and Solana Kit types
- **`WalletScenario`** — manages incoming dApp connections via native Android bridge
- **`WalletScenarioCallbacks`** — interface for handling authorize, sign, and deauthorize requests
- **Platform check** — `isMwaSupported()` / `assertMwaSupported()` (Android-only, iOS no-op)

Exists because: MWA requires platform-specific transport (Android Intents for wallet launching, WebSocket for session communication) that must be bridged from native code. This plugin uses a hybrid architecture: all WebSocket handling, P-256 cryptography, and JSON-RPC messaging happen in pure Dart (via the protocol package), while only Android Intent launching and wallet scenario bridging use native MethodChannels.

## Architecture

### Package Dependency Graph

Generated from package `pubspec.yaml` files with `scripts/workspace-doc-drift.sh --write`.

<!-- workspace-dependency-graph:start -->

```text
solana_kit -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_functional, solana_kit_instruction_plans, solana_kit_instructions, solana_kit_keys, solana_kit_offchain_messages, solana_kit_options, solana_kit_program_client_core, solana_kit_programs, solana_kit_rpc, solana_kit_rpc_parsed_types, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions, solana_kit_rpc_transport_http, solana_kit_rpc_types, solana_kit_signers, solana_kit_subscribable, solana_kit_sysvars, solana_kit_transaction_confirmation, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_accounts -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_addresses -> solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_codecs -> solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_options
solana_kit_codecs_core -> solana_kit_errors
solana_kit_codecs_data_structures -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_codecs_numbers -> solana_kit_codecs_core, solana_kit_errors
solana_kit_codecs_strings -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_errors -> (none)
solana_kit_fast_stable_stringify -> (none)
solana_kit_functional -> (none)
solana_kit_helius -> solana_kit_errors
solana_kit_instruction_plans -> solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_instructions -> solana_kit_addresses, solana_kit_errors
solana_kit_keys -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_strings, solana_kit_errors
solana_kit_lints -> (none)
solana_kit_mobile_wallet_adapter -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_mobile_wallet_adapter_protocol, solana_kit_transactions
solana_kit_mobile_wallet_adapter_protocol -> solana_kit_codecs_strings, solana_kit_errors
solana_kit_offchain_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_keys
solana_kit_options -> solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_errors
solana_kit_program_client_core -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_rpc_spec, solana_kit_rpc_types, solana_kit_signers
solana_kit_programs -> solana_kit_addresses, solana_kit_errors
solana_kit_rpc -> solana_kit_addresses, solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_keys, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_transport_http, solana_kit_rpc_types
solana_kit_rpc_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_parsed_types, solana_kit_rpc_spec, solana_kit_rpc_spec_types, solana_kit_rpc_transformers, solana_kit_rpc_types, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_rpc_parsed_types -> solana_kit_addresses, solana_kit_errors, solana_kit_rpc_types
solana_kit_rpc_spec -> solana_kit_errors, solana_kit_rpc_spec_types
solana_kit_rpc_spec_types -> solana_kit_errors
solana_kit_rpc_subscriptions -> solana_kit_errors, solana_kit_fast_stable_stringify, solana_kit_rpc_spec_types, solana_kit_rpc_subscriptions_api, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable
solana_kit_rpc_subscriptions_api -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc_types
solana_kit_rpc_subscriptions_channel_websocket -> solana_kit_errors, solana_kit_subscribable
solana_kit_rpc_transformers -> solana_kit_errors, solana_kit_rpc_spec_types, solana_kit_rpc_types
solana_kit_rpc_transport_http -> solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_spec_types
solana_kit_rpc_types -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors
solana_kit_signers -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages, solana_kit_transactions
solana_kit_subscribable -> solana_kit_errors
solana_kit_sysvars -> solana_kit_accounts, solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_errors, solana_kit_rpc_spec, solana_kit_rpc_types
solana_kit_test_matchers -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_transactions
solana_kit_transaction_confirmation -> solana_kit_addresses, solana_kit_errors, solana_kit_keys, solana_kit_rpc, solana_kit_rpc_api, solana_kit_rpc_spec, solana_kit_rpc_subscriptions_channel_websocket, solana_kit_rpc_types, solana_kit_subscribable, solana_kit_transactions
solana_kit_transaction_messages -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_functional, solana_kit_instructions
solana_kit_transactions -> solana_kit_addresses, solana_kit_codecs_core, solana_kit_codecs_data_structures, solana_kit_codecs_numbers, solana_kit_codecs_strings, solana_kit_errors, solana_kit_instructions, solana_kit_keys, solana_kit_transaction_messages
```

<!-- workspace-dependency-graph:end -->

### Design Principles

- **Mirror the TypeScript SDK** — package boundaries, APIs, and naming follow [anza-xyz/kit](https://github.com/anza-xyz/kit) so developers familiar with the TS SDK can transfer their knowledge
- **Tree-shakeable** — import only the packages you need; the umbrella package is optional
- **Zero code generation** — no freezed, no build_runner; everything is hand-written using Dart 3.10+ language features
- **Extension types for zero-cost abstractions** — `Address`, `Lamports`, and other wrapper types compile away to their underlying representation
- **Composable codecs** — describe on-chain data layouts declaratively rather than writing manual serialization

## License

MIT
