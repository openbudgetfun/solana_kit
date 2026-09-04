---
"codama-renderers-dart": patch
---

# Harden renderer input boundaries

Prevent path traversal and generated Dart code injection from IDL names, documentation, and string values. Pass formatter directories without shell evaluation and preserve existing output when rendering or import resolution fails.

Validate numeric IDL metadata, preserve codec prefix endianness and offset strategies, encode wide PDA constants as BigInt, and reject malformed byte seeds. Allow generated instruction builders to select non-signer roles for accounts declared with `isSigner: "either"`, with collision-free parameter names.

Reject duplicate and barrel-reserved generated paths instead of silently replacing nodes that share output names.
