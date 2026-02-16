---
solana_kit_transaction_confirmation: minor
---

Implement transaction confirmation package ported from `@solana/transaction-confirmation`.

**solana_kit_transaction_confirmation** (60 tests):

- `createRecentSignatureConfirmationPromiseFactory` with dual-pronged subscription + one-shot query
- `createBlockHeightExceedencePromiseFactory` monitoring slot notifications for block height tracking
- `createNonceInvalidationPromiseFactory` detecting durable nonce advancement
- `getTimeoutPromise` with commitment-based timeouts (30s processed, 60s confirmed/finalized)
- `raceStrategies` core strategy racing with safe future handling
- `waitForRecentTransactionConfirmation` high-level blockhash-based confirmation
- `waitForDurableNonceTransactionConfirmation` high-level nonce-based confirmation
- `waitForRecentTransactionConfirmationUntilTimeout` (deprecated) timeout-based fallback
- Dependency injection pattern for RPC functions to keep dependencies minimal
