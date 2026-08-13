---
"codama-renderers-dart": patch
---

# Render matching collection size-prefix codecs

Generate collection size prefixes with direction-specific number codecs: encoder manifests now use the matching number encoder and decoder manifests use the matching decoder. This fixes generated arrays, maps, and sets that use wide `BigInt` prefixes such as `u64`.
