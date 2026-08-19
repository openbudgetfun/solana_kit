---
"solana_kit_helius": minor
---

# Sync upstream `helius-sdk` v3.1.0

Tracks upstream Helius SDK APIs and behavior through `v3.1.0`:

- Adds `getBalanceAt` / `walletGetBalanceAt` for querying a wallet's balance of a token (or native SOL) at a point in the past — by Unix `time`, `datetime` string, or exact `slot` — with `balance`/`balanceRaw` returned as strings to preserve precision. `asOf` is `null` when the wallet had no matching transaction, meaning the balance is genuinely zero (upstream #334).
- Adds transaction-v1 validation: `validateTransactionV1Message` asserts the message holds no address lookups, since version 1 transactions cannot use address lookup tables (SIMD-0385), and `createTransactionMessage` refuses to build a v1 message with lookups. Adds `v1TransactionSizeLimit` (4096 bytes). `resolvePriorityFee` normalises a `lamportsCap` floor/ceiling into a whole number of lamports (upstream #341).
- Adds `sendBundleWithSender` for submitting up to 5-transaction bundles to Sender Max via `sendBundle`, tracking landing per transaction signature. Sender pricing constants now match upstream: `minTipLamportsMax` is 1,000,000 and `minTipLamportsSwqos` is 5,000. `sendViaSender` / `sendTransactionWithSender` accept `skipPreflight`, defaulting to `true` (upstream #335).
- Adds `PreconfWsClient` / `preconfSubscribe` for subscribing to preconfirmation websocket notifications with `preconfWebsocketUrl` and wire-format helpers `decodePreconfFrame`, `preconfWireVersion`, and `preconfHeadLength` (upstream #335).
