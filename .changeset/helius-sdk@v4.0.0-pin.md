---
"solana_kit_helius": minor
---

# Track `helius-labs/helius-sdk` `v4.0.0`

The reference pin advances to `v4.0.0`. Upstream's major bump is driven by a behavioral break that the Dart package adopts (breaking while on 0.x, hence the minor bump):

- **Breaking: signup no longer creates an API key** (#408). `authSignup` and `signupAndPay` return the project's first existing key, with `apiKey` and `endpoints` now nullable on `AlreadySubscribedResult`, `SignupAndPayCompletedResult`, and `SignupAndPayAlreadySubscribedResult` — a project can have zero keys even on a paid plan. Call the auth client's `createApiKey` when a key is needed. Code that unconditionally reads `result.endpoints.mainnet` must handle the null case.
- **Beta fixes that also change Dart types:** ZK Compression responses match the indexer's wire form (#397) — `getCompressedAccount` returns a `GetCompressedAccountResponse` envelope with a nullable `value`, `CompressedAccount.address`/`data` are nullable, and `getValidityProof` returns the documented `GetValidityProofResponse` whose Groth16 components `a`/`b`/`c` are integer byte arrays (not base64); `wallet.getBatchIdentity` returns a list of `BatchIdentityResult` in request order, where an unresolvable domain is an `UnresolvedBatchIdentity` (`unresolved: true`, `address` null, no name) instead of failing the batch (#402); `getAssetBatch` returns `List<HeliusAsset?>` with one entry per requested id and null for ids that were not found (#410); `getTokenAccountsByOwnerV2` gains a `withContext` request flag and parses all documented response shapes including `context.slot` and `totalResults` (#409).
- **Double-send hazard fix** (#407): `pollTransactionConfirmation` and `broadcastTransaction` read the status before checking the deadline, so a transaction that landed during the last wait is reported as confirmed instead of timed out — resending after the old timeout could execute it twice.

Each upstream change is mapped to its Dart counterpart in `docs/agents/upstream-audit-solana_kit_helius-v4.0.0.md`.
