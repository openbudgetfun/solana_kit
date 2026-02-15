# Data Model: Solana Kit Dart SDK

**Branch**: `001-solana-kit-port` | **Date**: 2026-02-15

## Core Entities

### Address

A Solana account identifier — a base58-encoded Ed25519 public key.

- **Representation**: Extension type wrapping `String` (32 bytes decoded)
- **Validation**: Must decode to exactly 32 bytes via base58
- **Uniqueness**: Globally unique on-chain identifier
- **Related to**: KeyPair (derived from public key), Instruction (account meta)

### KeyPair

An Ed25519 private/public key pair for signing operations.

- **Private key**: 32 bytes (seed) or 64 bytes (expanded)
- **Public key**: 32 bytes
- **Operations**: sign(bytes) → Signature, verify(signature, bytes) → bool
- **Generation**: Random generation or from seed bytes
- **Related to**: Address (public key = address), Signer (wraps KeyPair)

### Signature

An Ed25519 digital signature.

- **Representation**: Extension type wrapping `Uint8List` (64 bytes)
- **Validation**: Must be exactly 64 bytes
- **Display**: Base58-encoded string (transaction ID on Solana)
- **Related to**: Transaction (contains signatures), KeyPair (produces signatures)

### Codec<TFrom, TTo>

A composable encoder/decoder pair for Solana wire formats.

- **Encoder<TFrom>**: encode(value) → Uint8List
- **Decoder<TTo>**: decode(bytes, offset) → (value, bytesRead)
- **Codec<TFrom, TTo>**: combines Encoder and Decoder
- **Fixed vs Variable size**: fixedSize (known at compile time) vs variableSize
- **Composition**: struct, array, tuple, map, set, enum, option, nullable
- **Primitives**: u8, u16, u32, u64, u128, i8–i128, f32, f64, bool
- **Strings**: utf8, base58, base64, base10, base16

### Instruction

A single instruction to a Solana program.

- **programAddress**: Address of the program to invoke
- **accounts**: List of AccountMeta (address + isSigner + isWritable)
- **data**: Uint8List of encoded instruction arguments
- **Related to**: TransactionMessage (contains instructions)

### AccountMeta

Metadata about an account referenced in an instruction.

- **address**: Account Address
- **role**: AccountRole enum (writable+signer, writable, readonly+signer, readonly)

### TransactionMessage

An unsigned transaction payload — instructions + metadata.

- **version**: Legacy or V0
- **feePayer**: Address paying transaction fees
- **instructions**: List of Instruction
- **lifetimeConstraint**: Blockhash (recent) or DurableNonce
- **addressLookupTables**: List (V0 only) for address compression
- **State transitions**: empty → instructions added → fee payer set →
  lifetime set → compilable

### Transaction

A signed (or partially signed) transaction ready for submission.

- **signatures**: Map<Address, Signature> (fee payer first)
- **compiledMessage**: CompiledMessage (binary wire format)
- **Wire format**: signatures count + signatures + compiled message bytes
- **Size limit**: 1232 bytes maximum
- **Related to**: TransactionMessage (compiled from), RPC (sent via)

### CompiledMessage

The binary representation of a transaction message.

- **header**: (numSigners, numReadonlySigners, numReadonlyNonSigners)
- **staticAccounts**: List of Address (ordered: signers first, then non-signers)
- **recentBlockhash**: Blockhash (32 bytes)
- **instructions**: List of CompiledInstruction (account indices, not addresses)
- **addressTableLookups**: List (V0 only)

### RpcClient

A typed HTTP client for Solana JSON-RPC 2.0 calls.

- **transport**: HTTP transport (url, headers, timeout)
- **methods**: 40+ typed RPC methods (getBalance, getAccountInfo, etc.)
- **commitment**: Default commitment level (processed/confirmed/finalized)
- **Related to**: RpcTransport, RpcApi

### SubscriptionClient

A typed WebSocket client for real-time Solana notifications.

- **channel**: WebSocket channel (url, reconnect policy)
- **subscriptions**: accountSubscribe, slotSubscribe, signatureSubscribe, etc.
- **autopinger**: Keeps connection alive
- **Related to**: RpcSubscriptionsApi, WebSocketChannel

### Signer (Sealed Class Hierarchy)

An abstraction over signing strategies.

- **TransactionSigner**: Signs compiled transactions
- **MessageSigner**: Signs arbitrary messages
- **KeyPairSigner**: Signs using an Ed25519 KeyPair
- **NoopSigner**: Placeholder that produces empty signatures (for testing)
- **TransactionPartialSigner**: Signs some accounts in a transaction
- **TransactionModifyingSigner**: May modify the transaction during signing
- **TransactionSendingSigner**: Signs and sends in one operation

### SolanaError

A typed error with numeric code and contextual data.

- **code**: int (from SolanaErrorCode constants)
- **message**: Formatted string with interpolated context
- **context**: Map<String, Object?> of error-specific data
- **Categories**: address, account, codec, crypto, instruction, key, RPC,
  signer, transaction, invariant errors
- **Already implemented**: packages/solana_kit_errors/

### Option<T>

A Rust-like Option type for Solana's optional fields.

- **Some(value)**: Contains a value
- **None**: No value
- **Codec**: Encodes as 1-byte prefix (0=None, 1=Some) + value bytes
- **Related to**: Codec system (optionCodec)

## Enumerations

### Commitment

```
processed | confirmed | finalized
```

### AccountRole

```
writable + signer | writable | readonly + signer | readonly
```

### TransactionVersion

```
legacy | v0
```
