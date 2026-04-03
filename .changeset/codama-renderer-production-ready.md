---
default: patch
---

Make codama-renderers-dart production-ready for real Solana program IDLs.

- Pin upstream SPL Token Codama JSON as acceptance fixture with provenance metadata
- Fix nullable codec type inference by emitting explicit type parameters
- Fix double-`??` on nullable optional instruction parameters
- Fix local variable shadowing in instruction builders and PDA helpers
- Add SPL Token acceptance test with dart analyze gate (28→0 errors)
- Add JS-vs-Dart structural parity tests for the SPL Token fixture
- Expose surfpool in devenv shell for validator-backed testing
