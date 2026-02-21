# Changelog

All notable changes to this package will be documented in this file.

## 0.0.2 (2026-02-21)

### Features

#### Add Mobile Wallet Adapter packages for Solana.

**solana_kit_mobile_wallet_adapter_protocol**: Pure Dart MWA v2.0 protocol with P-256 ECDH/ECDSA, AES-128-GCM encryption, HKDF-SHA256, HELLO handshake, JSON-RPC messaging, association URIs, SIWS, and JWS.

**solana_kit_mobile_wallet_adapter**: Flutter plugin for Android MWA with `transact()`, local/remote association scenarios, wallet-side callbacks, Kit-integrated typed APIs, and platform method channels.

Adds 20 MWA-specific error codes (8400000-8400105) to `solana_kit_errors`.
