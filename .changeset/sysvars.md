---
solana_kit_sysvars: minor
---

Implement sysvars package ported from `@solana/sysvars`.

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
