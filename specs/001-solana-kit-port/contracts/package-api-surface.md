# API Contracts: Solana Kit Dart SDK

**Branch**: `001-solana-kit-port` | **Date**: 2026-02-15

This document defines the public API surface for each package layer. These are
the exported symbols that consumers depend on. Internal implementation details
are excluded.

## Layer 0: Foundation

### solana_kit_errors (IMPLEMENTED)

```
SolanaError (class)
SolanaErrorCode (abstract final class with static const int codes)
isSolanaError(error) → bool
getSolanaErrorMessage(code, context) → String
getErrorFromJsonRpcError(rpcError) → SolanaError
getTransactionError(error) → SolanaError
getInstructionError(error) → SolanaError
```

### solana_kit_functional

```
pipe(value, ...fns) → result
```

### solana_kit_fast_stable_stringify

```
fastStableStringify(value) → String
```

## Layer 1: Codecs

### solana_kit_codecs_core

```
Codec<TFrom, TTo> (interface)
Encoder<T> (interface)
Decoder<T> (interface)
FixedSizeCodec / VariableSizeCodec
createCodec(encoder, decoder) → Codec
createEncoder(encode, fixedSize?) → Encoder
createDecoder(decode, fixedSize?) → Decoder
transformCodec(codec, map) → Codec
fixCodecSize(codec, size) → FixedSizeCodec
offsetCodec(codec, preOffset, postOffset) → Codec
padCodec(codec, padding) → Codec
reverseCodec(codec) → Codec
containsBytes(bytes, data, offset) → bool
getEncodedSize(value, encoder) → int
```

### solana_kit_codecs_numbers

```
getU8Codec() → Codec<int, int>
getU16Codec(endian?) → Codec<int, int>
getU32Codec(endian?) → Codec<int, int>
getU64Codec(endian?) → Codec<BigInt, BigInt>
getU128Codec(endian?) → Codec<BigInt, BigInt>
getI8Codec() → Codec<int, int>
getI16Codec(endian?) → Codec<int, int>
getI32Codec(endian?) → Codec<int, int>
getI64Codec(endian?) → Codec<BigInt, BigInt>
getI128Codec(endian?) → Codec<BigInt, BigInt>
getF32Codec(endian?) → Codec<double, double>
getF64Codec(endian?) → Codec<double, double>
getShortU16Codec() → Codec<int, int>
```

### solana_kit_codecs_strings

```
getUtf8Codec(config?) → Codec<String, String>
getBase58Codec() → Codec<String, String>
getBase64Codec() → Codec<String, String>
getBase16Codec() → Codec<String, String>
getBase10Codec() → Codec<String, String>
getBaseXCodec(alphabet) → Codec<String, String>
```

### solana_kit_codecs_data_structures

```
getStructCodec(fields) → Codec<Map, Map>
getArrayCodec(item, config?) → Codec<List, List>
getTupleCodec(items) → Codec<List, List>
getMapCodec(key, value, config?) → Codec<Map, Map>
getSetCodec(item, config?) → Codec<Set, Set>
getEnumCodec(variants) → Codec
getDiscriminatedUnionCodec(variants) → Codec
getBoolCodec() → Codec<bool, bool>
getNullableCodec(item) → Codec
getConstantCodec(bytes) → Codec
getBitArrayCodec(size) → Codec
getUnitCodec() → Codec
getHiddenPrefixCodec(codec, prefixes) → Codec
getHiddenSuffixCodec(codec, suffixes) → Codec
```

### solana_kit_options

```
Option<T> (sealed class)
Some<T> (subclass)
None (subclass)
isSome(option) → bool
isNone(option) → bool
unwrapOption(option) → T?
getOptionCodec(itemCodec) → Codec<Option<T>>
getZeroableOptionCodec(itemCodec) → Codec<Option<T>>
```

### solana_kit_codecs (umbrella)

Re-exports all of: codecs_core, codecs_numbers, codecs_strings,
codecs_data_structures, options.

## Layer 2: Addresses & Keys

### solana_kit_addresses

```
Address (extension type on String)
address(base58String) → Address
getAddressCodec() → Codec<Address, Address>
getAddressFromPublicKey(publicKey) → Address
isAddress(value) → bool
assertIsAddress(value) → void
getProgramDerivedAddress(programAddress, seeds) → (Address, int)
findProgramDerivedAddress(programAddress, seeds) → Future<(Address, int)>
createAddressWithSeed(base, seed, programAddress) → Address
isOnCurve(address) → bool
```

### solana_kit_keys

```
CryptoKeyPair (type)
generateKeyPair() → Future<CryptoKeyPair>
createKeyPairFromBytes(bytes) → Future<CryptoKeyPair>
createKeyPairFromPrivateKeyBytes(bytes) → Future<CryptoKeyPair>
getPublicKeyFromPrivateKey(privateKey) → Future<CryptoKey>
signBytes(privateKey, data) → Future<Signature>
verifySignature(publicKey, signature, data) → Future<bool>
Signature (extension type on Uint8List)
getSignatureCodec() → Codec<Signature>
```

## Layer 3: RPC Foundation

### solana_kit_rpc_spec_types

```
RpcRequest (type)
RpcResponse (type)
RpcPlan (type)
RpcApiMethods (interface)
```

### solana_kit_rpc_types

```
Commitment (enum: processed, confirmed, finalized)
Lamports (extension type on BigInt)
UnixTimestamp (extension type on BigInt)
Blockhash (extension type on String)
TransactionVersion (enum: legacy, v0)
TokenAmount (type)
AccountInfoBase (type)
SimulatedTransactionAccountInfo (type)
```

### solana_kit_rpc_spec

```
createJsonRpcApi(methods) → RpcApi
Rpc<TApi> (type)
RpcTransport (interface)
```

### solana_kit_rpc_transformers

```
getDefaultRequestTransformerForSolanaRpc(config) → RequestTransformer
getDefaultResponseTransformerForSolanaRpc(config) → ResponseTransformer
```

### solana_kit_rpc_transport_http

```
createHttpTransport(config) → RpcTransport
createHttpTransportForSolanaRpc(config) → RpcTransport
```

## Layer 4–6: Instructions, Transactions, Signers

### solana_kit_instructions

```
IInstruction (interface)
IAccountMeta (interface)
AccountRole (enum)
```

### solana_kit_transaction_messages

```
TransactionMessage (type)
createTransactionMessage(config) → TransactionMessage
setTransactionMessageFeePayer(feePayer) → TransformFn
setTransactionMessageLifetimeUsingBlockhash(blockhash) → TransformFn
setTransactionMessageLifetimeUsingDurableNonce(nonce) → TransformFn
appendTransactionMessageInstruction(instruction) → TransformFn
prependTransactionMessageInstruction(instruction) → TransformFn
compileTransactionMessage(message) → CompiledTransactionMessage
decompileTransactionMessage(compiled) → TransactionMessage
```

### solana_kit_transactions

```
Transaction (type)
compileTransaction(message) → Transaction
getSignatureFromTransaction(tx) → Signature
signTransaction(signers, tx) → Future<Transaction>
getTransactionCodec() → Codec<Transaction>
getBase64EncodedWireTransaction(tx) → String
assertTransactionIsFullySigned(tx) → void
getTransactionSize(message) → int
```

### solana_kit_signers

```
TransactionSigner (interface)
MessageSigner (interface)
TransactionPartialSigner (interface)
TransactionModifyingSigner (interface)
TransactionSendingSigner (interface)
KeyPairSigner (class)
NoopSigner (class)
createKeyPairSignerFromKeyPair(keyPair) → Future<KeyPairSigner>
createSignerFromKeyPair(keyPair) → Future<TransactionSigner>
isTransactionSigner(value) → bool
assertIsTransactionSigner(value) → void
```

## Layer 7: RPC Complete

### solana_kit_rpc_api

All 40+ Solana JSON-RPC methods typed, including:

```
getAccountInfo, getBalance, getBlock, getBlockCommitment, getBlockHeight,
getBlockProduction, getBlocks, getBlocksWithLimit, getBlockTime,
getClusterNodes, getEpochInfo, getEpochSchedule, getFeeForMessage,
getFirstAvailableBlock, getGenesisHash, getHealth, getHighestSnapshotSlot,
getIdentity, getInflationGovernor, getInflationRate, getInflationReward,
getLargestAccounts, getLatestBlockhash, getLeaderSchedule, getMaxRetransmitSlot,
getMaxShredInsertSlot, getMinimumBalanceForRentExemption,
getMultipleAccounts, getProgramAccounts, getRecentPerformanceSamples,
getRecentPrioritizationFees, getSignaturesForAddress, getSignatureStatuses,
getSlot, getSlotLeader, getSlotLeaders, getStakeActivation,
getStakeMinimumDelegation, getSupply, getTokenAccountBalance,
getTokenAccountsByDelegate, getTokenAccountsByOwner, getTokenLargestAccounts,
getTokenSupply, getTransaction, getTransactionCount, getVersion,
getVoteAccounts, isBlockhashValid, minimumLedgerSlot, requestAirdrop,
sendTransaction, simulateTransaction
```

### solana_kit_rpc

```
createSolanaRpc(endpoint, config?) → SolanaRpc
createSolanaRpcFromTransport(transport) → SolanaRpc
RpcCluster (devnet, testnet, mainnet URLs)
```

### solana_kit_rpc_subscriptions

```
createSolanaRpcSubscriptions(endpoint, config?) → SolanaRpcSubscriptions
accountNotifications, blockNotifications, logsNotifications,
programNotifications, rootNotifications, signatureNotifications,
slotNotifications, slotsUpdatesNotifications, voteNotifications
```

## Layer 8: High-Level

### solana_kit_accounts

```
Account<T> (type)
MaybeAccount<T> (type: Account | MissingAccount)
EncodedAccount (type)
fetchEncodedAccount(rpc, address) → MaybeAccount
fetchEncodedAccounts(rpc, addresses) → List<MaybeAccount>
decodeAccount(account, codec) → Account<T>
parseAccount(account) → Account<ParsedData>
assertAccountExists(account) → Account
assertAccountsExist(accounts) → List<Account>
```

### solana_kit_transaction_confirmation

```
waitForConfirmation(rpc, signature, config?) → Future<void>
createBlockHeightExceedencePromise(rpc, config) → Future<void>
createSignatureConfirmationPromise(subscriptions, signature) → Future<void>
getTimeoutPromise(duration) → Future<void>
```
