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

- Dart does not provide deterministic secure memory wiping for ordinary heap objects, so private key material may remain in memory until garbage collection. Key generation, signing, and public-key derivation zero their expanded-key intermediates in `finally` blocks; the residual risk covers objects Dart's runtime copies opaquely.
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

## Implemented Safeguards

- Dependency auditing runs in CI: OSV-Scanner checks every pull request and weekly against the Dart and pnpm lockfiles (`.github/workflows/dependency-audit.yml`), and `zizmor` lints the workflow files.
- Signatures returned by Mobile Wallet Adapter wallets are cryptographically verified against the authorized account's public key before callers receive them, including Sign In With Solana proofs. SIWS proofs are additionally bound to the request that triggered them: every field the application supplied (domain, nonce, statement, timestamps, resources, …) must appear verbatim in the signed message, which names the account it is attached to, mirroring `verifySignIn` from `@solana/wallet-standard-util`.
- Signature-confirmation strategies ignore received-notifications, so a node's receipt of a transaction can never be mistaken for its execution.
- Insecure `http://` and `ws://` endpoints are rejected in release (product) builds regardless of the opt-in flags, across the core HTTP and WebSocket transports, the Jupiter client, and Helius Sender regional endpoints (only `SenderRegion.defaultRegion` serves HTTPS and is allowed in release builds).
- Blockhash and durable-nonce lifetime tokens must be base58 strings that decode to exactly 32 bytes; a malformed value from a compromised RPC fails loudly instead of being silently truncated or zero-extended on the wire.
- The BigInt-aware JSON parser bounds the number of digits a single integer literal can materialize, on both the plain and exponent paths.
- Helius REST path segments built from API-returned identifiers are URL-encoded, so a compromised endpoint cannot reshape a subsequent request's path.
- Surfnet passes a fork's upstream RPC URL to the Surfpool CLI through the `SURFPOOL_DATASOURCE_RPC_URL` environment variable rather than a process argument, keeping API keys out of `ps`/`/proc` listings.
