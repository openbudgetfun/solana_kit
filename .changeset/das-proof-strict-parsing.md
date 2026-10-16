---
"solana_kit_mpl_bubblegum": patch
---

# Reject DAS responses with missing proof and compression fields

`HeliusDasClient` silently defaulted missing DAS fields — a proof without `node_index` decoded as index zero, a missing `tree_id` as an empty tree address, a missing `leaf_id` as nonce zero — and those values flow directly into the leaf hash, nonce, and index of Bubblegum transfer and mint instructions, producing plausible on-chain garbage. The asset and proof parsers now throw `FormatException` naming the missing field for `id`, `ownership.owner`, `ownership.frozen`, every core `compression` field (`compressed`, `data_hash`, `creator_hash`, `asset_hash`, `tree`, `seq`, `leaf_id`), every `getAssetProof` field (`root`, `proof`, `node_index`, `leaf`, `tree_id`), and each creator's `address`/`share`/`verified`. Genuinely optional DAS companions (delegate, `non_transferable`, royalty and raw leaf fields, `collection_hash`, `asset_data_hash`, `flags`, content) still parse leniently.
