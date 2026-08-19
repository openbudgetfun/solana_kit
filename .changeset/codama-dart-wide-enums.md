---
"codama-renderers-dart": patch
---

# Fix Wide Scalar Enum Codecs

Generate type-correct Dart codecs for scalar enums with `u64` discriminators. The encoder now converts enum indices to `BigInt`, while the decoder validates the decoded discriminator before converting it to a Dart enum index.
