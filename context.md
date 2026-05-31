The deduplication task is complete. Here's a quick summary:

**All 13 packages updated** to use canonical address constants from `solana_kit_addresses`:

- ✅ `solana_kit_compute_budget` — re-exported `computeBudgetProgramAddress`
- ✅ `solana_kit_transaction_messages` — removed 3 local consts; added `recentBlockhashesSysvarAddress` backward-compat alias
- ✅ `solana_kit_transactions` — replaced `_systemProgramAddress` with `systemProgramAddress`
- ✅ `solana_kit_loader` — re-exported 2 program addresses; aliased 3 sysvar addresses
- ✅ `solana_kit_config` — aliased `solanaConfigProgramAddress` → `configProgramAddress`
- ✅ `solana_kit_memo` — re-exported memo addresses (corrected swapped values)
- ✅ `solana_kit_stake` — aliased `solanaStakeInterfaceProgramAddress`; removed local `stakeConfigAddress`; replaced inline `Address('1111...')`
- ✅ `solana_kit_token` — re-exported `tokenProgramAddress`
- ✅ `solana_kit_token_2022` — re-exported `token2022ProgramAddress`
- ✅ `solana_kit_address_lookup_table` — re-exported `addressLookupTableProgramAddress`; replaced inline system program address
- ✅ `solana_kit_sysvars` — re-exported all sysvar addresses; added `recentBlockhashesSysvarAddress` alias
- ✅ `solana_kit_associated_token_account` — re-exported `associatedTokenProgramAddress` (corrected address value); aliased `ataProgramAddress`
- ✅ `solana_kit_spl_account_compression` — changed `String` constants to `Address` type re-exports

**Address value corrections**: ATA program, memo program addresses, and `stakeConfigAddress` now use canonical correct values.

**All tests pass** across 15 packages. `dart analyze` reports 0 errors (only 4 pre-existing info-level issues).
