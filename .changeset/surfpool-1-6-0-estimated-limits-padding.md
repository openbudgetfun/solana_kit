---
"solana_kit_integration_tests": patch
---

# Pad estimated loaded-accounts limits for SurfPool 1.6.0 execution

SurfPool 1.6.0 updated its embedded LiteSVM to enforce full v1 transaction semantics, so its runtime now charges Agave-style loaded-accounts accounting — a 165-byte base size plus data length for every loaded account. Its `simulateTransaction` response, however, still computes `loadedAccountsDataSize` as a bare sum of account data bytes. A version 1 transaction that submits the estimator's `loadedAccountsDataSizeLimit` verbatim is therefore always rejected with `MaxLoadedAccountsDataSizeExceeded`, even though the estimator mirrors upstream `@solana/kit` (which reports the value verbatim and executes as-is against real Agave nodes, where the simulation report is runtime-consistent).

The on-chain estimator tests now pad the estimated loaded accounts data size limit by the per-account base sizes before submitting, while the estimated compute unit limit is still submitted verbatim — preserving the end-to-end proof that estimated compute budgets execute. The estimator itself is unchanged.
