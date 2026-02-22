# solana_kit_rpc_parsed_types

[![pub package](https://img.shields.io/pub/v/solana_kit_rpc_parsed_types.svg)](https://pub.dev/packages/solana_kit_rpc_parsed_types)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_rpc_parsed_types/latest/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Parsed account data types for the Solana Kit Dart SDK.

This is the Dart port of [`@solana/rpc-parsed-types`](https://github.com/anza-xyz/kit/tree/main/packages/rpc-parsed-types) from the Solana TypeScript SDK.

## Installation

Install with:

```bash
dart pub add solana_kit_rpc_parsed_types
```

If you are working within the `solana_kit` monorepo, the package resolves through the Dart workspace. Otherwise, specify a version or path as needed.

## Documentation

- Package page: https://pub.dev/packages/solana_kit_rpc_parsed_types
- API reference: https://pub.dev/documentation/solana_kit_rpc_parsed_types/latest/

## Usage

This package provides type definitions for the parsed account data returned by the Solana RPC when accounts are requested with `jsonParsed` encoding. It covers all native Solana programs.

### Base types

The `RpcParsedType` and `RpcParsedInfo` classes serve as the foundation for all parsed account data.

```dart
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';

// RpcParsedType carries both a type discriminator and an info payload.
// Used for programs with multiple account variants (e.g. Token, Stake).
// RpcParsedType<TType, TInfo>

// RpcParsedInfo carries only an info payload.
// Used for programs with a single account type (e.g. Nonce, Vote).
// RpcParsedInfo<TInfo>
```

### Token program accounts

The `JsonParsedTokenProgramAccount` sealed class represents parsed data from the Token and Token-2022 programs. It has three variants: token accounts, mint accounts, and multisig accounts.

```dart
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

// Token account variant.
final tokenAccount = JsonParsedTokenAccountVariant(
  info: JsonParsedTokenAccount(
    isNative: false,
    mint: Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v'),
    owner: Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
    state: TokenAccountState.initialized,
    tokenAmount: TokenAmount(
      amount: StringifiedBigInt('1000000'),
      decimals: 6,
      uiAmountString: StringifiedNumber('1'),
    ),
  ),
);

print(tokenAccount.type); // 'account'
print(tokenAccount.info.mint); // EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
print(tokenAccount.info.tokenAmount.amount); // '1000000'

// Mint account variant.
final mintAccount = JsonParsedMintAccount(
  info: JsonParsedMintInfo(
    decimals: 6,
    isInitialized: true,
    supply: StringifiedBigInt('1000000000000'),
    mintAuthority: Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
  ),
);

print(mintAccount.type); // 'mint'
print(mintAccount.info.supply); // '1000000000000'
print(mintAccount.info.decimals); // 6

// Multisig account variant.
final multisigAccount = JsonParsedMultisigAccount(
  info: JsonParsedMultisigInfo(
    isInitialized: true,
    numRequiredSigners: 2,
    numValidSigners: 3,
    signers: [
      Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
      Address('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v'),
      Address('11111111111111111111111111111111'),
    ],
  ),
);

// Pattern matching on token program account variants.
void handleTokenProgramAccount(JsonParsedTokenProgramAccount account) {
  switch (account) {
    case JsonParsedTokenAccountVariant(:final info):
      print('Token account for mint: ${info.mint}');
    case JsonParsedMintAccount(:final info):
      print('Mint with supply: ${info.supply}');
    case JsonParsedMultisigAccount(:final info):
      print('Multisig with ${info.numRequiredSigners}/${info.numValidSigners} signers');
  }
}
```

### Stake program accounts

The `JsonParsedStakeProgramAccount` sealed class covers delegated and initialized stake accounts.

```dart
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

final delegatedStake = JsonParsedDelegatedStake(
  info: JsonParsedStakeAccountInfo(
    meta: JsonParsedStakeMeta(
      authorized: JsonParsedStakeAuthorized(
        staker: Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
        withdrawer: Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
      ),
      lockup: JsonParsedStakeLockup(
        custodian: Address('11111111111111111111111111111111'),
        epoch: BigInt.zero,
        unixTimestamp: UnixTimestamp(BigInt.zero),
      ),
      rentExemptReserve: StringifiedBigInt('2282880'),
    ),
    stake: JsonParsedStakeData(
      creditsObserved: BigInt.from(100000),
      delegation: JsonParsedStakeDelegation(
        activationEpoch: StringifiedBigInt('580'),
        deactivationEpoch: StringifiedBigInt('18446744073709551615'),
        stake: StringifiedBigInt('1000000000'),
        voter: Address('Vote111111111111111111111111111111111111111'),
        warmupCooldownRate: 0.25,
      ),
    ),
  ),
);

print(delegatedStake.type); // 'delegated'
print(delegatedStake.info.stake?.delegation.stake); // '1000000000'

// Pattern matching.
void handleStakeAccount(JsonParsedStakeProgramAccount account) {
  switch (account) {
    case JsonParsedDelegatedStake(:final info):
      print('Delegated to: ${info.stake?.delegation.voter}');
    case JsonParsedInitializedStake(:final info):
      print('Initialized, staker: ${info.meta.authorized.staker}');
  }
}
```

### Nonce accounts

```dart
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

final nonceAccount = JsonParsedNonceAccount(
  info: JsonParsedNonceInfo(
    authority: Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
    blockhash: Blockhash('4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY'),
    feeCalculator: JsonParsedNonceFeeCalculator(
      lamportsPerSignature: StringifiedBigInt('5000'),
    ),
  ),
);

print(nonceAccount.info.authority); // 83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK
print(nonceAccount.info.blockhash); // 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY
```

### Vote accounts

```dart
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

final voteInfo = JsonParsedVoteInfo(
  authorizedVoters: [
    JsonParsedAuthorizedVoter(
      authorizedVoter: Address('Vote111111111111111111111111111111111111111'),
      epoch: BigInt.from(580),
    ),
  ],
  authorizedWithdrawer: Address('83astBRguLMdt2h5U1Tbd4hU5SkfAWRkzG2HPM88BREAK'),
  commission: 10,
  epochCredits: [
    JsonParsedEpochCredit(
      credits: StringifiedBigInt('100000'),
      epoch: BigInt.from(580),
      previousCredits: StringifiedBigInt('90000'),
    ),
  ],
  lastTimestamp: JsonParsedLastTimestamp(
    slot: BigInt.from(250000000),
    timestamp: UnixTimestamp(BigInt.from(1700000000)),
  ),
  nodePubkey: Address('Node1111111111111111111111111111111111111111'),
  priorVoters: [],
  votes: [
    JsonParsedVote(
      confirmationCount: 31,
      slot: BigInt.from(250000000),
    ),
  ],
);

print(voteInfo.commission); // 10
print(voteInfo.votes.first.confirmationCount); // 31
```

## API Reference

### Base Classes

- **`RpcParsedType<TType, TInfo>`** -- A parsed account type with a `type` discriminator and `info` payload.
- **`RpcParsedInfo<TInfo>`** -- A parsed account type with only an `info` payload (no type discriminator).

### Token Program

- **`JsonParsedTokenProgramAccount`** -- Sealed class for token program accounts.
- **`JsonParsedTokenAccountVariant`** -- Token account variant (type: `'account'`).
- **`JsonParsedTokenAccount`** -- Token account info (mint, owner, state, tokenAmount, isNative, delegate, delegatedAmount, closeAuthority, extensions, rentExemptReserve).
- **`JsonParsedMintAccount`** -- Mint account variant (type: `'mint'`).
- **`JsonParsedMintInfo`** -- Mint info (decimals, isInitialized, supply, mintAuthority, freezeAuthority, extensions).
- **`JsonParsedMultisigAccount`** -- Multisig account variant (type: `'multisig'`).
- **`JsonParsedMultisigInfo`** -- Multisig info (isInitialized, numRequiredSigners, numValidSigners, signers).
- **`TokenAccountState`** -- Enum: `frozen`, `initialized`, `uninitialized`.

### Stake Program

- **`JsonParsedStakeProgramAccount`** -- Sealed class for stake program accounts.
- **`JsonParsedDelegatedStake`** -- Delegated stake variant (type: `'delegated'`).
- **`JsonParsedInitializedStake`** -- Initialized stake variant (type: `'initialized'`).
- **`JsonParsedStakeAccountInfo`** -- Stake account info (meta, stake).
- **`JsonParsedStakeMeta`** -- Stake metadata (authorized, lockup, rentExemptReserve).
- **`JsonParsedStakeAuthorized`** -- Authorized staker and withdrawer addresses.
- **`JsonParsedStakeLockup`** -- Lockup configuration (custodian, epoch, unixTimestamp).
- **`JsonParsedStakeData`** -- Stake delegation data (creditsObserved, delegation).
- **`JsonParsedStakeDelegation`** -- Delegation details (activationEpoch, deactivationEpoch, stake, voter, warmupCooldownRate).

### Vote Program

- **`JsonParsedVoteAccount`** -- Type alias for `RpcParsedInfo<JsonParsedVoteInfo>`.
- **`JsonParsedVoteInfo`** -- Vote account info (authorizedVoters, authorizedWithdrawer, commission, epochCredits, lastTimestamp, nodePubkey, priorVoters, rootSlot, votes).
- **`JsonParsedAuthorizedVoter`** -- Authorized voter entry (authorizedVoter, epoch).
- **`JsonParsedEpochCredit`** -- Epoch credit entry (credits, epoch, previousCredits).
- **`JsonParsedLastTimestamp`** -- Last timestamp (slot, timestamp).
- **`JsonParsedPriorVoter`** -- Prior voter entry (authorizedPubkey, epochOfLastAuthorizedSwitch, targetEpoch).
- **`JsonParsedVote`** -- Vote entry (confirmationCount, slot).

### Nonce Program

- **`JsonParsedNonceAccount`** -- Type alias for `RpcParsedInfo<JsonParsedNonceInfo>`.
- **`JsonParsedNonceInfo`** -- Nonce account info (authority, blockhash, feeCalculator).
- **`JsonParsedNonceFeeCalculator`** -- Fee calculator (lamportsPerSignature).

### Address Lookup Table

- **`JsonParsedAddressLookupTableAccount`** -- Parsed address lookup table account data.

### BPF Upgradeable Loader

- **`JsonParsedBpfUpgradeableLoaderProgramAccount`** -- Sealed class for BPF loader account variants (program, programData, buffer, uninitialized).

### Config Program

- **`JsonParsedConfigProgramAccount`** -- Parsed config account data.

### Sysvar Program

- **`JsonParsedSysvarAccount`** -- Parsed sysvar account data (clock, rent, stakeHistory, etc.).
