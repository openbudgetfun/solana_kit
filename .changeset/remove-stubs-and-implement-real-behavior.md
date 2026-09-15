---
"solana_kit": minor
"solana_kit_transaction_messages": minor
"solana_kit_rpc": minor
"solana_kit_addresses": minor
"solana_kit_helius": minor
"solana_kit_dapp_publisher_cli": patch
---

# Replace stubbed functions with real implementations

Several public functions promised behavior they did not deliver. Each is now implemented, with the missing API surface added alongside it.

## `estimateResourceLimitsFactory` now simulates

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

## `solana_kit_functional` removed

The package is gone. Its only utility, the `pipe` extension, has lived in `solana_kit_transaction_messages` since the previous breaking release and is re-exported by `solana_kit`, so the package duplicated what the SDK already provided and existed only as an empty placeholder pending retirement. Anyone still importing it should switch to `solana_kit_transaction_messages` (or the `solana_kit` umbrella), which is a one-line import change.

## `solana_kit_addresses` gains the PDA guards

`isProgramDerivedAddress` and `assertIsProgramDerivedAddress` were absent, leaving `addressesMalformedPda` and `addressesPdaBumpSeedOutOfRange` defined but unreachable. Both are now implemented: they validate that a value is an `(Address, int)` record, that the bump seed is in `[0, 255]`, and that the address is well formed.

## `solana_kit_helius` builds real smart transactions

`createSmartTransaction` returned a bare blockhash while documenting that it would estimate compute units and priority fees. It now performs the full sequence: validate, estimate compute units through `simulateTransaction`, sample the priority fee by account key, resolve the fee in both microLamports-per-unit and total lamports, and refresh the blockhash. It returns a `SmartTransaction` carrying the limits, fee, lifetime, instructions, fee payer, and account keys; signing stays with the caller because the client holds signer addresses rather than keys.

Two related silent defaults were removed:

- `getComputeUnits` returned `200000` when the node omitted `unitsConsumed`. It now throws, because inventing a number sizes the transaction for work the simulation never confirmed. It also reports a failed simulation instead of returning the units of one that did not succeed, and it serializes real `Instruction` objects, which previously failed at JSON encoding.
- `broadcastTransaction`, `sendTransactionWithSender`, and `sendSmartTransaction` accepted a `senderUrl` parameter they never used. The parameter is gone; the REST client already targets the sender base URL.

## Version 1 durable nonce transactions are recognized

`getTransactionLifetimeConstraintFromCompiledTransactionMessage` only inspected the legacy instruction list, which a version 1 compiled message leaves empty in favour of separate instruction headers and payloads. Every version 1 durable nonce transaction therefore decompiled as a blockhash transaction, so a caller could not tell that its lifetime depended on a nonce. The version 1 branch now reads the headers and payloads, throws `transactionInvalidNonceAccountIndex` for an out-of-range nonce account index, and returns the blockhash lifetime only when the first instruction is genuinely not an advance-nonce instruction.

## Priority fee lamports API

`getTransactionMessagePriorityFeeLamports` and `setTransactionMessagePriorityFeeLamports` add the missing read/write surface for the total-lamport priority fee that only version 1 messages carry. The setter removes the fee on `null`, drops an emptied config, and is a no-op when the value already matches.

## Wallets can now express and check version 1 support

`SolanaTransactionVersion` gains `version1` plus `wireValue` and `fromWireValue`, so the values a wallet advertises (`legacy`, `0`, `1`) round-trip instead of being collapsed. A `supportsVersion1` extension makes the check usable. Two related corrections:

- The browser registry used to map any advertised entry other than `legacy` onto version 0, so a wallet advertising `1` was reported as version 0 and a caller could build a transaction the wallet cannot sign. Unrecognized entries are now dropped rather than mislabelled.
- The MWA-backed mobile wallet advertises an explicit `legacy`-and-version-0 list instead of `SolanaTransactionVersion.values`, which would have silently started claiming version 1 support as the enum grew. This matches upstream's `wallet-standard-mobile`.

## Error codes that were defined but unreachable

Three codes had no throw site. `signerWalletAccountCannotSignTransaction` is now thrown when a `WalletAccountSigner` is created for an account advertising neither transaction feature, matching upstream's `createSignerFromWalletAccount`. `heliusApiKeyRequired` is thrown by `HeliusConfig` for a blank key, which previously produced a request that could only fail with a 401. `heliusTransactionSimulationFailed` replaces a bare `StateError` when a compute-unit simulation reports a transaction failure.

The remaining defined-but-unthrown codes were checked against upstream and are parity-faithful: upstream defines them without throwing them anywhere either (`addressesInvalidBase58EncodedAddress`, the four `wallet*` codes, `subscribableRetryNotSupported`, `transactionInvalidNonceTransactionFirstInstructionMustBeAdvanceNonce`), or they belong to abstractions this port intentionally does not have (the React hook path behind `signerWalletMultisignUnimplemented`, the fs-impl package behind `fsUnsupportedEnvironment`, the named-channel pubsub plan behind `invariantViolationDataPublisherChannelUnimplemented`).

## `solana_kit_dapp_publisher_cli` reports unreadable balances

`parseLamportsValue` returned `0` for a balance response it could not parse. A malformed response therefore looked like an empty wallet. It now throws a `FormatException`, so a transport or schema change is reported as itself rather than as insufficient funds.
