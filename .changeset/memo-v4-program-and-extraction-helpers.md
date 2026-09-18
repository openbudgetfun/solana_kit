---
"codama-renderers-dart": patch
"solana_kit_address_constants": minor
"solana_kit_memo": minor
---

# Track the memo v4 program and add memo extraction helpers

The workspace now tracks `solana-program/memo` at `js@v0.14.1` (previously `js@v0.13.1`). The `mpl-token-metadata` reference pin also moves to `353d01be4af3`; its IDL is byte-identical, so that package is unaffected.

`solana_kit_address_constants` moves `memoProgramAddress` to the v4 memo program (`Memo4c2pN8afCj432Lb7RMVKi9PbQnnW7ewFFaV3oAH`), matching the upstream IDL `publicKey` as of `js@v0.14.0`. The previous v3 address stays available as the new `memoLegacyProgramAddressV3` constant, and `memoLegacyProgramAddress` (v1) is unchanged. Code that builds new memo instructions picks up the v4 program automatically; code that must keep targeting v3 names the legacy constant explicitly.

`solana_kit_memo` ports the upstream extraction helpers from `js@v0.14.1`:

- `getMemosFromInstructions` scans a list of instructions, matches every deployed Memo program address, and returns the UTF-8 decoded memo text with the raw bytes, source program address, and instruction index.
- `ExtractedMemo` carries one extracted memo.
- `supportedMemoProgramAddresses` lists every deployed Memo program address ordered from oldest (v1) to newest (v4).

The generated layer is regenerated against `js@v0.14.1` with the current renderer: the program page is byte-identical because the program address flows through the well-known constants, and the AddMemo data decoder now validates byte length strictly, throwing `SolanaError` with `codecsInvalidByteLength` on trailing bytes. `solana_kit_errors` moves from a dev dependency to a dependency because the generated decoder references it.

`codama-renderers-dart` maps the v4 address to `memoProgramAddress` and the v3 address to `memoLegacyProgramAddressV3` in its well-known address registry, so regenerated clients re-export the canonical constants instead of hardcoding address strings.

The `token-2022` pin stays at `js@v0.16.1`: `js@v0.17.0` (and the newer `js@v0.18.0`) still requires the handwritten-layer migration before the pin can move.
