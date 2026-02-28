---
solana_kit_codecs_data_structures: minor
solana_kit_errors: minor
solana_kit_rpc_spec_types: minor
solana_kit_rpc_transport_http: minor
---

Add Phase 4 advanced ergonomics and performance improvements.

- Add typed union helpers (`Union2`/`Union3`) with strongly-typed codec helpers.
- Add optional isolate-backed BigInt JSON decoding via
  `parseJsonWithBigIntsAsync` and Solana HTTP transport flags.
- Add typed error-domain helpers layered over numeric `SolanaErrorCode`
  values (`SolanaErrorDomain`, domain classifiers, and extensions).
- Expand README/API docs and shared mdt templates for these features.
