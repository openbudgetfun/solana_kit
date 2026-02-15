---
solana_kit_errors: minor
---

Initial release of the error handling foundation package. Implements the complete
Solana error system ported from `@solana/errors` in the TypeScript SDK:

- `SolanaError` class with numeric error codes and typed context maps
- `SolanaErrorCode` with 200+ categorized error constants covering addresses,
  accounts, codecs, crypto, instructions, keys, RPC, signers, transactions,
  and invariant violations
- Error message templates with `$variable` interpolation for all error codes
- JSON-RPC error conversion with preflight failure unwrapping
- Instruction error mapping for all 54 Solana runtime instruction errors
- Transaction error mapping for all 37 Solana runtime transaction errors
- Simulation error unwrapping for preflight and compute limit estimation
- Context encoding/decoding via base64 URL-safe serialization
- Comprehensive test suite with 7 test files covering all conversion paths
