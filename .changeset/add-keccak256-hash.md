---
solana_kit_codecs_core: minor
---

# Add Keccak-256 hash function

Adds a pure-Dart Keccak-256 implementation (`keccak256()`) to `solana_kit_codecs_core`. This is the hash function used by the Bubblegum compressed NFT program (not to be confused with SHA3-256, which uses different padding).

Note: Keccak-256 round constants exceed 2^53, so `ignore_for_file: avoid_js_rounded_ints` is applied to the implementation file. This is acceptable because the Solana SDK targets native platforms where `int` is 64-bit.
