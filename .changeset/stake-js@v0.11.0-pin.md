---
"solana_kit_stake": patch
---

# Track `solana-program/stake` `js@v0.11.0`

The reference pin advances to `js@v0.11.0`. The upstream release regenerates the TypeScript client without changing the program's `idl.json` (the one IDL delta is the program version string, proven output-neutral by generating the Dart package at both pins), so no generated Dart code changes. See `docs/agents/upstream-audit-program-pins-2026-10-16.md`.
