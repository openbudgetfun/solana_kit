---
"solana_kit_rpc_transport_http": patch
---

# Correct the release-mode lockdown wording in transport docs

The HTTP transport's insecure-scheme guard uses `dart.vm.product`, which is true in release builds but not in Flutter profile builds; the code comment claimed "release/profile mode". The comment (and the matching WebSocket one) now says release (product) builds, matching the enforced behavior and `SECURITY.md`.
