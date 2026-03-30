# Security Policy

## Scope

This repository ships low-level Solana primitives, signing utilities, transports, RPC clients, and Mobile Wallet Adapter integrations for Dart and Flutter.

Security-sensitive areas include:

- private key and signer handling
- transaction/message signing
- HTTP and WebSocket transports
- Mobile Wallet Adapter session establishment and encrypted messaging
- compatibility behaviors inherited from upstream `@solana/kit`

## Reporting a Vulnerability

Please do not open a public GitHub issue for a suspected security vulnerability.

Instead, report it privately via GitHub Security Advisories or by contacting the maintainers through the repository security contact once configured.

When reporting, include:

- affected package(s)
- impacted versions
- reproduction steps or proof of concept
- severity assessment and likely attack preconditions
- whether the issue is Dart-only, Flutter-only, Android-only, or cross-platform

## Current Security Posture

The workspace already enforces secure defaults in several places:

- HTTP transport rejects insecure `http://` endpoints by default.
- WebSocket transport rejects insecure `ws://` endpoints by default.
- Address, signature, and other encoded Solana primitives are validated explicitly.
- Some key comparisons use constant-time byte comparison.

Known constraints and active hardening areas:

- Dart does not provide deterministic secure memory wiping for ordinary heap objects, so private key material may remain in memory until garbage collection.
- Some compatibility behaviors intentionally mirror upstream `@solana/kit`, even when stricter Dart-specific behavior may be preferable.
- Mobile Wallet Adapter support is Android-only at the ecosystem level today; iOS support in this repo is a safe stub/no-op for mixed-platform Flutter apps.

## Secure Usage Guidance

### Keys and signers

- Avoid persisting raw private keys longer than necessary.
- Prefer wallet-driven signing flows when available.
- Treat `Uint8List` key material as sensitive application data.
- Do not log private keys, auth tokens, encrypted session payloads, or full signer state.

### Transports

- Keep `allowInsecureHttp` and `allowInsecureWs` disabled outside local development and controlled tests.
- Prefer provider URLs you control or trust.
- Validate production RPC endpoint configuration explicitly.

### Mobile Wallet Adapter

- Gate MWA flows with `isMwaSupported()` / `assertMwaSupported()`.
- Provide alternate UX for unsupported platforms, especially iOS.
- Test wallet handoff and session cleanup on real Android hardware.

## Maintenance Expectations

Security work should include, where relevant:

- regression tests for the vulnerable behavior
- documentation updates for user-facing risk or platform constraints
- review of parity impact versus `@solana/kit`
- follow-up checks for related packages and transports
- rerunning `audit:deps` or the dependency-audit workflow after dependency changes

## Planned Improvements

The active roadmap includes:

- adding dependency audit checks to CI
- documenting strict-vs-compatibility behavior for risky decoding paths
- strengthening transport hardening and shared WebSocket behavior
- improving security guidance around Flutter and Android-only MWA support
