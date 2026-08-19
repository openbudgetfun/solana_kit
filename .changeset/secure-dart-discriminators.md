---
"codama-renderers-dart": patch
---

# Enforce Dart discriminator and optional-account invariants

Hide omitted defaults from generated builder inputs, force their declared wire values during encoding, validate account and instruction discriminators during decoding, require exact instruction input consumption, reject truncated account data while preserving legitimate trailing account capacity unless a size discriminator requires an exact length, and preserve optional account positions with readonly program-address placeholders.
