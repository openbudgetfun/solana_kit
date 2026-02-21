# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Initial scaffold for 17 higher-level packages including the full RPC stack,

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

#### Implement sysvars package ported from `@solana/sysvars`.

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
