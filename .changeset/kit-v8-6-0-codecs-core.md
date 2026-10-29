---
"solana_kit_codecs_core": patch
---

# Reject sentinels found across the encoded-bytes/sentinel boundary

Ports the encoder hardening from `@solana/codecs-core` v8.6.0: `addCodecSentinel` now checks for the sentinel within the concatenation of the encoded bytes and the appended sentinel, so a value ending with the sentinel's own prefix (e.g. encoded bytes ending `6c` with sentinel `6c6c`) is rejected — the decoder would otherwise stop at that straddling occurrence instead of the real sentinel.
