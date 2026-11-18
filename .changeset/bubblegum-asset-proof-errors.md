---
"solana_kit_mpl_bubblegum": patch
---

# Surface the original DAS error from `getAssetWithProof`

`getAssetWithProof` still fetches the asset and its proof concurrently. When either request fails, it throws that failure directly (`FormatException` for a malformed payload, or the client's exception for an HTTP or RPC failure). Previously the concurrent join wrapped the failure in `ParallelWaitError`, so callers could not match the underlying error.
