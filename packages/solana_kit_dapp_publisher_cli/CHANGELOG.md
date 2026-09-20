# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## solana_kit_dapp_publisher_cli [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_dapp_publisher_cli/v0.1.0) (2026-09-06)

### 💥 Breaking Change

#### Add the Solana Mobile dApp publisher CLI

A new portal-backed CLI for publishing dApp versions to the Solana Mobile dApp Store, installable globally via `dart pub global activate solana_kit_dapp_publisher_cli`.

The CLI talks to the Solana Mobile Publisher Portal API and handles the full publication workflow: APK upload and ingestion, release NFT minting with local transaction validation, collection verification, attestation, and store submission. It supports publishing new versions, resuming partially completed publications, and cleaning up failed releases.

```bash
dart pub global activate solana_kit_dapp_publisher_cli

dapp-store \
  --apk-file ./build/app/outputs/flutter-apk/app-release.apk \
  --whats-new "Bug fixes" \
  --keypair ~/.config/solana/id.json
```

Key APIs include `runDappStoreCli` for the CLI entry point, `PublicationWorkflow` for programmatic use, `PortalWorkflowClient` for the portal-backed client, and `signPreparedTransaction` for security-critical local transaction validation before signing.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #242](https://github.com/openbudgetfun/solana_kit/pull/242)

## solana_kit_dapp_publisher_cli [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_dapp_publisher_cli/v0.1.1) (2026-09-12)

### Changed

- **No package-specific changes were recorded; `solana_kit_dapp_publisher_cli` was updated to 0.1.1.**

## solana_kit_dapp_publisher_cli [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/solana_kit_dapp_publisher_cli/v0.2.0) (2026-09-21)

### Breaking changes

#### Raise the Dart and Flutter baseline

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

### Fixes

#### Replace stubbed functions with real implementations

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
