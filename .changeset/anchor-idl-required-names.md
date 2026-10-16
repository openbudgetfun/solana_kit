---
"solana_kit_anchor": patch
---

# Require Anchor IDL names and error codes, and attribute encode failures

`parseAnchorIdl` silently turned an IDL instruction, error, or defined type with a missing name into the empty string — every such node then collided under the `''` key in the instruction, error, and type maps — and an error entry without a numeric `code` became code zero, silently mis-keying program error decoding. Both now throw `ArgumentError` naming the offending entry.

`AnchorCoder`'s encode helpers no longer drop the field context they are given: a value that fails to encode inside an instruction argument or account field now surfaces as an `ArgumentError` naming that field instead of a bare codec error.
