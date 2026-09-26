---
"solana_kit_stake": patch
---

# Track `solana-program/stake` `js@v0.10.0`

The reference pin moves from `js@v0.9.1` to `js@v0.10.0`. This is the one program release in this sync whose `idl.json` blob changed, and the change is confined to its version headers: the Codama format version moves `1.8.0` → `1.9.2` and the program version `4.4.0` → `5.0.0`. The rest of the IDL is identical, and the Dart renderer emits no program version, so **the generated Dart is unchanged**.

Upstream also rebased the interface crate onto `solana-instruction` 4.0 and split `InstructionError` into its own `solana-instruction-error` crate, and regenerated the TypeScript client with the wider `InstructionSignerInput` family. Neither affects this port, which consumes the IDL and keeps its own error mapping. Verified by regenerating against the old and new pins: byte-identical output.
