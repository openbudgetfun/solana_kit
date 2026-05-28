# Security and Code Quality Improvements Plan

## Status: In Progress

Created: 2026-05-28

## Issues

### Security - Critical

- [x] **SEC-01**: API Key Exposure in URLs
  - Package: `solana_kit_helius`
  - Problem: `HeliusConfig` exposes API keys in plain URL strings
  - Fix: Add `toString()` override that redacts the API key, use `SensitiveString` wrapper
  - PR: [#158](https://github.com/openbudgetfun/solana_kit/pull/158)

- [ ] **SEC-02**: Private Key Memory Exposure
  - Package: `solana_kit_keys`
  - Problem: `KeyPair` stores private keys in `Uint8List` with no zeroing
  - Fix: Add `Finalizer` to attempt zeroing when KeyPair is GC'd
  - PR: TBD

- [ ] **SEC-03**: Constant-Time Comparison for All Secrets
  - Package: `solana_kit_keys`, `solana_kit_helius`
  - Problem: Other secret comparisons use standard `==` instead of `constantTimeEqual`
  - Fix: Use `constantTimeEqual` for all secret comparisons
  - PR: TBD

### Security - Medium

- [ ] **SEC-04**: Insecure WebSocket Option
  - Package: `solana_kit_rpc_subscriptions_channel_websocket`
  - Problem: `allowInsecureWs` could be misused in production
  - Fix: Add environment check, only allow in debug mode, log warning
  - PR: TBD

- [ ] **SEC-05**: URL Validation for SSRF Protection
  - Package: `solana_kit_rpc_subscriptions_channel_websocket`
  - Problem: No SSRF protection for WebSocket/HTTP URLs
  - Fix: Validate URL schemes, block private IP ranges
  - PR: TBD

- [ ] **SEC-06**: Error Message Sanitization
  - Package: `solana_kit_errors`
  - Problem: Error messages may leak internal state
  - Fix: Sanitize error context before including in messages
  - PR: TBD

- [ ] **SEC-07**: Request Timeout Defaults
  - Package: `solana_kit_rpc_transport_http`, `solana_kit_rpc_subscriptions_channel_websocket`
  - Problem: No default timeouts configured
  - Fix: Add default timeouts (30s HTTP, 60s WebSocket)
  - PR: TBD

### Security - Low

- [ ] **SEC-08**: File Permission Handling on Windows
  - Package: `solana_kit_keys`
  - Problem: On Windows, key files have no permission restriction
  - Fix: Document limitation, consider alternative
  - PR: TBD

- [ ] **SEC-09**: Input Length Validation
  - Package: `solana_kit_codecs_core`
  - Problem: No max length validation on decoded strings/arrays
  - Fix: Add configurable max length limits to decoders
  - PR: TBD

- [ ] **SEC-10**: Debug Information in Production
  - Package: Multiple
  - Problem: Asserts are stripped in release mode
  - Fix: Use explicit throws for validation
  - PR: TBD

### Code Quality

- [ ] **QUAL-01**: Extract Shared Validation Helpers
  - Package: New `solana_kit_validation` or add to existing
  - Problem: Repetitive assert/throw patterns across packages
  - Fix: Create `assertInRange`, `assertLength`, etc.
  - PR: TBD

- [ ] **QUAL-02**: Create Signer Assertion Utilities
  - Package: `solana_kit_signers`
  - Problem: Repetitive signer validation patterns
  - Fix: Extract `assertIsKeyPairSigner`, `assertIsMessageSigner`
  - PR: TBD

- [ ] **QUAL-03**: Add mapMaybeAccount Combinator
  - Package: `solana_kit_accounts`
  - Problem: Repetitive maybe-account switch patterns
  - Fix: Create `mapMaybeAccount<T, R>` combinator
  - PR: TBD

## Progress

| Issue   | Branch | PR | Status      |
| ------- | ------ | -- | ----------- |
| SEC-01  | -      | -  | Not started |
| SEC-02  | -      | -  | Not started |
| SEC-03  | -      | -  | Not started |
| SEC-04  | -      | -  | Not started |
| SEC-05  | -      | -  | Not started |
| SEC-06  | -      | -  | Not started |
| SEC-07  | -      | -  | Not started |
| SEC-08  | -      | -  | Not started |
| SEC-09  | -      | -  | Not started |
| SEC-10  | -      | -  | Not started |
| QUAL-01 | -      | -  | Not started |
| QUAL-02 | -      | -  | Not started |
| QUAL-03 | -      | -  | Not started |
