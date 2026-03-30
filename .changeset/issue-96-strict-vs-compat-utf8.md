---
default: patch
---

Add strict and explicit UTF-8 null-character decoding controls to `solana_kit_codecs_strings`, while preserving the default `@solana/kit` compatibility behavior that strips decoded null characters.
