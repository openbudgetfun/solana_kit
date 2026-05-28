---
"codama-renderers-dart": patch
---

# Add comprehensive Codama IDL acceptance fixtures for SPL…

Add comprehensive Codama IDL acceptance fixtures for SPL Token, Token-2022, and System programs.

Three new Codama JSON IDL fixtures are added under `test/fixtures/`:

- **`spl_token.json`** + `spl_token.meta.json` — Full SPL Token program IDL (shank origin, 34 extensions, ATA program, associated types, errors)
- **`token_2022.json`** + `token_2022.meta.json` — Full Token-2022 program IDL (js@v0.9.0, 35 extensions including confidential transfers, metadata pointer, token groups, pausable config, scaled UI amounts)
- **`system.json`** + `system.meta.json` — Full System Program IDL (js@v0.12.0, 13 instructions, Nonce account types, 9 error codes)

Each fixture includes a `.meta.json` provenance file recording the source repository, git commit, tag, file path, and SHA-256 hash for traceability.

These fixtures expand the renderer's acceptance test surface from a single SPL Token fixture to three real-world Solana programs covering diverse IDL features: nested enum variants with size-prefixed structs, zeroable option types, map types with prefixed counts, multiple additional programs, PDA definitions with seed derivation, and error code catalogs. The expanded coverage catches rendering edge cases that simpler IDLs do not exercise.
