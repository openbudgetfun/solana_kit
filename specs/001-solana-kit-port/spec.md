# Feature Specification: Solana Kit Dart SDK — Full Port

**Feature Branch**: `001-solana-kit-port`
**Created**: 2026-02-15
**Status**: Draft
**Input**: Port all @solana/kit packages to Dart with full feature parity, tests, and publishing guide

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Build and send a Solana transaction (Priority: P1)

A Dart/Flutter developer wants to construct, sign, and send a Solana transaction
(e.g., transferring SOL or interacting with a program) using a native Dart SDK
that mirrors the ergonomics of the official TypeScript `@solana/kit`.

**Why this priority**: Transaction creation and submission is the fundamental
use case for any Solana SDK. Without this, no meaningful Solana application can
be built.

**Independent Test**: A developer can import the SDK, create a transaction
message, add instructions, sign it with a keypair, and send it to a local test
validator — all in pure Dart with no JavaScript interop.

**Acceptance Scenarios**:

1. **Given** a developer has the SDK as a dependency, **When** they create
   a transfer instruction, compile it into a transaction, sign it, and send it
   via RPC, **Then** the transaction is confirmed on-chain and the balances
   reflect the transfer.
2. **Given** a transaction with an invalid signature, **When** it is sent to the
   RPC, **Then** a typed error is returned with the appropriate error code and
   context.
3. **Given** a transaction that exceeds the size limit, **When** the developer
   attempts to compile it, **Then** a clear error is raised before any network
   call.

---

### User Story 2 - Query Solana state via RPC (Priority: P2)

A Dart/Flutter developer wants to read on-chain state — account data, balances,
token holdings, recent blockhashes — using strongly-typed RPC methods that match
the Solana JSON-RPC specification.

**Why this priority**: Reading chain state is the second most common operation
after sending transactions. Developers need reliable, typed access to all 40+
Solana RPC methods.

**Independent Test**: A developer can create an RPC client pointing at a Solana
cluster and call any standard RPC method (e.g., `getBalance`, `getAccountInfo`,
`getLatestBlockhash`) with correct return types.

**Acceptance Scenarios**:

1. **Given** a valid RPC endpoint, **When** the developer calls `getBalance`
   with a known address, **Then** a typed response containing the lamport balance
   is returned.
2. **Given** a valid RPC endpoint, **When** the developer calls `getAccountInfo`
   with encoding options, **Then** the account data is returned decoded according
   to the specified encoding.
3. **Given** an unreachable RPC endpoint, **When** any RPC call is made, **Then**
   a typed transport error is raised with retry-friendly context.

---

### User Story 3 - Encode and decode Solana data structures (Priority: P2)

A Dart developer working with on-chain programs needs to encode instruction data
and decode account state using a composable codec system that handles all Solana
primitive types (u8–u128, strings, structs, enums, options, etc.).

**Why this priority**: The codec system is the backbone of all program interaction.
Without it, developers cannot parse account data or construct instruction payloads.
Equal priority with RPC since both are needed for meaningful program interaction.

**Independent Test**: A developer can compose codecs to define a program's account
structure and use it to encode/decode bytes matching the on-chain layout.

**Acceptance Scenarios**:

1. **Given** a codec definition for a struct with nested fields, **When** the
   developer encodes a Dart object, **Then** the resulting bytes match the
   expected Solana wire format byte-for-byte.
2. **Given** raw account bytes from the chain, **When** decoded with the
   appropriate codec, **Then** all fields are correctly extracted into typed
   objects.
3. **Given** a codec for a Rust enum with variants, **When** encoding and
   decoding round-trips, **Then** the original data is preserved exactly.

---

### User Story 4 - Subscribe to real-time Solana events (Priority: P3)

A Dart/Flutter developer wants to subscribe to Solana events (account changes,
slot updates, signature confirmations) over WebSocket for real-time reactivity.

**Why this priority**: Real-time subscriptions enable responsive UIs and
transaction confirmation flows. Critical for production applications but builds
on top of the RPC foundation.

**Independent Test**: A developer can open a WebSocket subscription to an account
and receive notifications when the account data changes.

**Acceptance Scenarios**:

1. **Given** a WebSocket-enabled RPC endpoint, **When** the developer subscribes
   to account changes for a known address, **Then** they receive a notification
   stream that emits when the account is modified.
2. **Given** an active subscription, **When** the connection drops, **Then** the
   SDK provides error information and the subscription can be re-established.
3. **Given** a pending transaction signature, **When** the developer uses
   transaction confirmation, **Then** they are notified when the transaction
   reaches the desired commitment level.

---

### User Story 5 - Publish packages to pub.dev (Priority: P4)

The SDK maintainer needs a clear, repeatable process for versioning and publishing
all 37 packages to pub.dev, handling inter-package dependency constraints and
pub.dev-specific requirements.

**Why this priority**: Publishing is the final delivery step. The SDK must be
installable by end users. Lower priority because it's a one-time process setup
that doesn't affect development.

**Independent Test**: Following the publishing guide, the maintainer can
successfully validate all packages with dry-run publish without errors.

**Acceptance Scenarios**:

1. **Given** a set of packages with changesets, **When** the maintainer follows
   the publishing guide, **Then** all packages are published in the correct
   dependency order with consistent version constraints.
2. **Given** a package with pub.dev validation issues (missing description,
   documentation, etc.), **When** running dry-run validation, **Then** all issues
   are flagged before actual publication.
3. **Given** 37 interdependent packages, **When** reviewing the publishing guide,
   **Then** it addresses: dependency ordering, version constraint strategy,
   pre-publish validation, and rollback procedures.

---

### Edge Cases

- What happens when a developer uses a codec with mismatched fixed sizes?
  The SDK raises a typed error with the codec-specific error code at encode
  time, not silently producing corrupt bytes.
- How does the SDK handle RPC responses with unexpected fields or missing
  optional fields? The typed response models handle missing optional fields
  gracefully; unexpected fields are ignored.
- What happens when signing with an incorrect key type? A typed error is raised
  identifying the key type mismatch.
- How does the SDK handle u64/u128 values that exceed standard int range? The
  codec system uses BigInt for large values and provides explicit conversion
  utilities.
- What happens when multiple packages are imported with version conflicts?
  Workspace resolution ensures all packages use compatible versions within the
  monorepo; pub.dev constraints ensure compatibility for external consumers.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: SDK MUST provide 37 packages mirroring the upstream TypeScript SDK
  structure, with the umbrella package re-exporting all public APIs.
- **FR-002**: SDK MUST support creating, signing, and serializing Solana
  transactions (both legacy and versioned/v0 formats).
- **FR-003**: SDK MUST provide typed interfaces for all standard Solana JSON-RPC
  methods (40+ methods including getAccountInfo, getBalance,
  getLatestBlockhash, sendTransaction, simulateTransaction).
- **FR-004**: SDK MUST provide WebSocket subscription support for all standard
  Solana subscription methods (accountSubscribe, slotSubscribe,
  signatureSubscribe, etc.).
- **FR-005**: SDK MUST provide a composable codec system supporting all Solana
  primitive types (u8–u128, i8–i128, f32, f64, bool), strings (utf8, base58,
  base64), and data structures (structs, enums, tuples, arrays, maps, sets,
  options).
- **FR-006**: SDK MUST provide Ed25519 key pair generation, signing, and
  verification.
- **FR-007**: SDK MUST provide base58 address encoding/decoding with validation.
- **FR-008**: SDK MUST provide Program Derived Address (PDA) computation.
- **FR-009**: SDK MUST map all Solana runtime error codes (200+ error codes
  covering addresses, accounts, codecs, crypto, instructions, keys, RPC,
  signers, transactions, and invariant violations) to typed exceptions.
- **FR-010**: SDK MUST provide transaction confirmation utilities that poll or
  subscribe until a transaction reaches a desired commitment level.
- **FR-011**: SDK MUST provide a signer abstraction supporting partial signers,
  modifying signers, and sending signers.
- **FR-012**: SDK MUST include a comprehensive test suite ported from the
  upstream SDK's 300+ test files, covering all public API surfaces.
- **FR-013**: SDK MUST include a publishing guide documenting the process for
  versioning and publishing all 37 packages.
- **FR-014**: SDK MUST use no code generation — all types, codecs, and
  serialization are hand-written.
- **FR-015**: SDK MUST use no `dynamic` types — `Object?` where flexibility is
  needed, with `const` constructors wherever possible.
- **FR-016**: SDK MUST provide offchain message encoding/decoding per the Solana
  offchain message specification.
- **FR-017**: SDK MUST provide instruction plan utilities for constructing,
  planning, and executing multi-instruction transactions.

### Key Entities

- **Address**: A base58-encoded Ed25519 public key (32 bytes) identifying an
  on-chain account.
- **KeyPair**: An Ed25519 private/public key pair used for signing.
- **Transaction Message**: A set of instructions with account addresses, a recent
  blockhash, and a fee payer — the unsigned payload.
- **Transaction**: A signed transaction ready for submission (signatures +
  compiled message).
- **Codec**: A composable encoder/decoder pair that converts between Dart objects
  and byte arrays following Solana wire formats.
- **RPC Client**: A typed HTTP client for making Solana JSON-RPC 2.0 calls.
- **Subscription Client**: A typed WebSocket client for receiving real-time Solana
  notifications.
- **Signer**: An abstraction over different signing strategies (keypair, hardware
  wallet, remote signer).
- **SolanaError**: A typed error with numeric code, message template, and
  contextual data for debugging.
- **Instruction**: A program address, list of account keys with metadata, and
  encoded data bytes.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: All 37 packages pass static analysis with zero warnings or errors.
- **SC-002**: All ported test suites pass with coverage matching or exceeding the
  upstream SDK's test file count (300+ test files).
- **SC-003**: All packages pass dry-run publish validation, confirming readiness
  for package registry publication.
- **SC-004**: A developer can complete a "hello world" transaction (airdrop +
  transfer) in under 50 lines of code using the umbrella package.
- **SC-005**: Encoding/decoding round-trips for all supported data types produce
  byte-identical output compared to the upstream SDK for the same inputs.
- **SC-006**: All 40+ RPC methods return correctly typed responses when called
  against a Solana test validator.
- **SC-007**: The publishing guide is validated by executing a dry-run publish of
  all 37 packages in dependency order without errors.
- **SC-008**: Zero uses of `dynamic` type across the entire codebase (enforced
  by linter rules).
- **SC-009**: All formatting checks pass across the entire codebase.

## Assumptions

- The upstream `@solana/kit` TypeScript SDK (in the reference repo) is the
  canonical reference for API surface, behavior, and test cases.
- The `espresso-cash-public` reference repo serves as a reference for idiomatic
  Dart patterns for Solana operations (crypto, base58, RPC) but the API design
  follows the upstream SDK, not espresso-cash.
- The `cryptography` Dart package is suitable for Ed25519 operations (used
  successfully by espresso-cash in production).
- `http` and `web_socket_channel` are the standard Dart packages for RPC
  transport.
- Dart's native `BigInt` handles u64/u128 values without needing a polyfill
  (unlike JavaScript which required BigInt support).
- TypeScript-specific packages that have no Dart equivalent are excluded from
  the port: React bindings (JS-only), legacy compatibility layer (web3.js),
  GraphQL RPC (out of scope), nominal types (Dart has extension types),
  assertions (folded into errors), promises (Dart has native Futures), and all
  private implementation packages (platform shims replaced by Dart equivalents).
- Packages are not published during this feature — only the publishing guide
  and dry-run validation are delivered.
- All 37 Dart packages are already scaffolded with pubspec.yaml,
  analysis_options.yaml, and barrel export files.
