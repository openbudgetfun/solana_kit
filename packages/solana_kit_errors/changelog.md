# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Initial release of the error handling foundation package. Implements the complete

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

### Fixes

#### Add `solana_kit_helius` package — a Dart port of the Helius TypeScript SDK.

Provides 12 sub-clients: DAS API, Priority Fees, RPC V2, Enhanced Transactions, Webhooks, ZK Compression, Smart Transactions, Staking, Wallet API, WebSockets, and Auth. Includes 150 unit tests across 80 test files.

Adds 6 Helius-specific error codes (8600000–8600005) to `solana_kit_errors`.

#### Add Mobile Wallet Adapter packages for Solana.

**solana_kit_mobile_wallet_adapter_protocol**: Pure Dart MWA v2.0 protocol with P-256 ECDH/ECDSA, AES-128-GCM encryption, HKDF-SHA256, HELLO handshake, JSON-RPC messaging, association URIs, SIWS, and JWS.

**solana_kit_mobile_wallet_adapter**: Flutter plugin for Android MWA with `transact()`, local/remote association scenarios, wallet-side callbacks, Kit-integrated typed APIs, and platform method channels.

Adds 20 MWA-specific error codes (8400000-8400105) to `solana_kit_errors`.
