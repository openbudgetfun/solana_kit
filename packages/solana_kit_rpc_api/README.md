# solana_kit_rpc_api

RPC method type definitions and API composition for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-api`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-api) from the Solana TypeScript SDK.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  solana_kit_rpc_api:
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Usage

### Creating a Solana RPC API

The `createSolanaRpcApi` function creates a `JsonRpcApi` that converts method calls into `RpcPlan` instances with the standard Solana transformers applied (BigInt downcast, integer overflow checking, default commitment).

```dart
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// Create with defaults.
final api = createSolanaRpcApi();

// Create with custom configuration.
final customApi = createSolanaRpcApi(SolanaRpcApiConfig(
  defaultCommitment: Commitment.finalized,
  onIntegerOverflow: (request, keyPath, value) {
    print('Integer overflow in ${request.methodName}: $value');
  },
));
```

### Using with createRpc

To build a full RPC client, wrap the API in an adapter and combine it with a transport:

```dart
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';

final rpc = createRpc(
  RpcConfig(
    api: createSolanaRpcApiAdapter(SolanaRpcApiConfig(
      defaultCommitment: Commitment.confirmed,
    )),
    transport: myTransport,
  ),
);

// Now call any Solana RPC method.
final balance = await rpc.request('getBalance', [
  '83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK',
]).send();
```

### Method parameter builders

Each RPC method has a corresponding config class and a params builder function. These construct the JSON-RPC parameter lists.

```dart
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// getBalance parameters.
final addr = address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK');
final balanceParams = getBalanceParams(addr, GetBalanceConfig(
  commitment: Commitment.finalized,
));
// ['83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK', {'commitment': 'finalized'}]

// getAccountInfo parameters.
final accountParams = getAccountInfoParams(addr, GetAccountInfoConfig(
  encoding: 'base64',
  commitment: Commitment.confirmed,
));
```

### Checking method availability by cluster

Not all RPC methods are available on all clusters. For example, `requestAirdrop` is only available on test clusters (devnet, testnet).

```dart
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';

// Check if a method is available on all clusters (including mainnet).
print(isSolanaRpcMethodForAllClusters('getBalance')); // true
print(isSolanaRpcMethodForAllClusters('requestAirdrop')); // false

// Check if a method is available on test clusters.
print(isSolanaRpcMethodForTestClusters('requestAirdrop')); // true

// Mainnet check (excludes requestAirdrop).
print(isSolanaRpcMethodForMainnet('getBalance')); // true
print(isSolanaRpcMethodForMainnet('requestAirdrop')); // false
```

### Allowed numeric key paths

The `getAllowedNumericKeypaths` function returns a mapping that tells the response transformer which values in RPC responses should remain as `int` rather than being upcast to `BigInt`. This is used internally by the default response transformer.

```dart
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';

final keypaths = getAllowedNumericKeypaths();
// Contains mappings like:
// 'getAccountInfo' -> [[..., 'decimals'], [..., 'uiAmount'], ...]
// 'getBlock' -> [[..., 'programIdIndex'], [..., 'stackHeight'], ...]
```

## API Reference

### Classes

- **`SolanaRpcApiConfig`** -- Configuration for creating a Solana RPC API. Fields:
  - `defaultCommitment` (`Commitment?`) -- Default commitment level.
  - `onIntegerOverflow` (`IntegerOverflowHandler?`) -- Callback for BigInt overflow detection.
- **`GetAccountInfoConfig`** -- Parameters for `getAccountInfo` (commitment, encoding, dataSlice, minContextSlot).
- **`GetBalanceConfig`** -- Parameters for `getBalance` (commitment, minContextSlot).
- **`GetBlockConfig`** -- Parameters for `getBlock`.
- **`GetBlockHeightConfig`** -- Parameters for `getBlockHeight`.
- **`GetLatestBlockhashConfig`** -- Parameters for `getLatestBlockhash`.
- **`GetProgramAccountsConfig`** -- Parameters for `getProgramAccounts`.
- **`GetSignatureStatusesConfig`** -- Parameters for `getSignatureStatuses`.
- **`GetSlotConfig`** -- Parameters for `getSlot`.
- **`GetTokenAccountsByOwnerConfig`** -- Parameters for `getTokenAccountsByOwner`.
- **`GetTransactionConfig`** -- Parameters for `getTransaction`.
- **`SendTransactionConfig`** -- Parameters for `sendTransaction`.
- **`SimulateTransactionConfig`** -- Parameters for `simulateTransaction`.

### Functions

- **`createSolanaRpcApi([SolanaRpcApiConfig? config])`** -- Creates a `JsonRpcApi` with the standard Solana RPC transformers applied.
- **`createSolanaRpcApiAdapter([SolanaRpcApiConfig? config])`** -- Creates an `RpcApi` adapter wrapping a Solana RPC API, for use with `createRpc`.
- **`isSolanaRpcMethodForAllClusters(String methodName)`** -- Returns `true` if the method is available on all clusters.
- **`isSolanaRpcMethodForTestClusters(String methodName)`** -- Returns `true` if the method is available on test clusters (includes `requestAirdrop`).
- **`isSolanaRpcMethodForMainnet(String methodName)`** -- Returns `true` if the method is available on mainnet.
- **`getAllowedNumericKeypaths()`** -- Returns the `AllowedNumericKeypaths` mapping for Solana RPC responses.
- **`getBalanceParams(Address, [GetBalanceConfig?])`** -- Builds JSON-RPC params for `getBalance`.
- **`getAccountInfoParams(Address, [GetAccountInfoConfig?])`** -- Builds JSON-RPC params for `getAccountInfo`.

### Constants

- **`solanaRpcMethodsForAllClusters`** -- `List<String>` of 51 RPC method names available on all clusters.
- **`solanaRpcMethodsForTestClusters`** -- `List<String>` of 52 RPC method names available on test clusters (includes `requestAirdrop`).

### Supported RPC Methods

The package defines parameter types and builders for all 52 Solana JSON-RPC methods:

| Method                              | Description                                                          |
| ----------------------------------- | -------------------------------------------------------------------- |
| `getAccountInfo`                    | Returns account information for a given address                      |
| `getBalance`                        | Returns the balance in lamports for a given address                  |
| `getBlock`                          | Returns identity and transaction information about a confirmed block |
| `getBlockCommitment`                | Returns commitment for a particular block                            |
| `getBlockHeight`                    | Returns the current block height                                     |
| `getBlockProduction`                | Returns recent block production information                          |
| `getBlocks`                         | Returns a list of confirmed blocks between two slots                 |
| `getBlocksWithLimit`                | Returns a list of confirmed blocks starting at a given slot          |
| `getBlockTime`                      | Returns the estimated production time of a block                     |
| `getClusterNodes`                   | Returns information about all nodes in the cluster                   |
| `getEpochInfo`                      | Returns information about the current epoch                          |
| `getEpochSchedule`                  | Returns epoch schedule information                                   |
| `getFeeForMessage`                  | Returns the fee for a given message                                  |
| `getFirstAvailableBlock`            | Returns the slot of the lowest confirmed block                       |
| `getGenesisHash`                    | Returns the genesis hash                                             |
| `getHealth`                         | Returns the current health of the node                               |
| `getHighestSnapshotSlot`            | Returns the highest slot with a snapshot                             |
| `getIdentity`                       | Returns the identity pubkey of the current node                      |
| `getInflationGovernor`              | Returns the current inflation governor                               |
| `getInflationRate`                  | Returns the current inflation rate                                   |
| `getInflationReward`                | Returns the inflation reward for addresses                           |
| `getLargestAccounts`                | Returns the 20 largest accounts by lamport balance                   |
| `getLatestBlockhash`                | Returns the latest blockhash                                         |
| `getLeaderSchedule`                 | Returns the leader schedule                                          |
| `getMaxRetransmitSlot`              | Returns the max slot seen from retransmit stage                      |
| `getMaxShredInsertSlot`             | Returns the max slot seen from shred insert stage                    |
| `getMinimumBalanceForRentExemption` | Returns minimum balance for rent exemption                           |
| `getMultipleAccounts`               | Returns account information for a list of addresses                  |
| `getProgramAccounts`                | Returns all accounts owned by a program                              |
| `getRecentPerformanceSamples`       | Returns recent performance samples                                   |
| `getRecentPrioritizationFees`       | Returns recent prioritization fees                                   |
| `getSignatureStatuses`              | Returns the statuses of a list of signatures                         |
| `getSignaturesForAddress`           | Returns signatures for confirmed transactions involving an address   |
| `getSlot`                           | Returns the current slot                                             |
| `getSlotLeader`                     | Returns the current slot leader                                      |
| `getSlotLeaders`                    | Returns the slot leaders for a given slot range                      |
| `getStakeMinimumDelegation`         | Returns the stake minimum delegation                                 |
| `getSupply`                         | Returns information about the current supply                         |
| `getTokenAccountBalance`            | Returns the token balance of an SPL Token account                    |
| `getTokenAccountsByDelegate`        | Returns all SPL Token accounts by approved delegate                  |
| `getTokenAccountsByOwner`           | Returns all SPL Token accounts by token owner                        |
| `getTokenLargestAccounts`           | Returns the 20 largest token accounts                                |
| `getTokenSupply`                    | Returns the total supply of an SPL Token type                        |
| `getTransaction`                    | Returns transaction details for a confirmed signature                |
| `getTransactionCount`               | Returns the current transaction count                                |
| `getVersion`                        | Returns the current Solana version                                   |
| `getVoteAccounts`                   | Returns the account info and associated stake for all vote accounts  |
| `isBlockhashValid`                  | Returns whether a blockhash is still valid                           |
| `minimumLedgerSlot`                 | Returns the lowest slot that the node has information about          |
| `requestAirdrop`                    | Requests an airdrop of lamports (test clusters only)                 |
| `sendTransaction`                   | Submits a signed transaction                                         |
| `simulateTransaction`               | Simulates sending a transaction                                      |
