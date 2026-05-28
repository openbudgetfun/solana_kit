# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/solana_kit/releases/tag/v0.4.0) (2026-05-28)

### 📝 Changed

#### Restructure release groups

Move program-specific and domain-specific packages out of the main release group into standalone release schedules with independent versioning. Core SDK packages remain synchronized in the main group.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`fccec7f`](https://github.com/openbudgetfun/solana_kit/commit/fccec7f2c1aba7d58766e43cd9a5201ff2b9621a)

### 🐛 Fixed

#### Add per-package coverage badges

Add codecov flags and per-package coverage badges to all package READMEs.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`bed1b1f`](https://github.com/openbudgetfun/solana_kit/commit/bed1b1f1241fa99e2f6c71e7ad5024c1fa42e910)

#### Improve handwritten test coverage across RPC, token, websocket, and sysvar packages.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`68fa2e3`](https://github.com/openbudgetfun/solana_kit/commit/68fa2e39683da95e11b79ec3d45e03624948cbe9) · _Last updated in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)

#### SEC-04: Restrict allowInsecureWs to debug mode only.

- In release/profile mode, `ws://` URLs are now always rejected regardless of the `allowInsecureWs` flag
- Prevents accidental use of insecure WebSocket connections in production
- Updated documentation to reflect the debug-only behavior

_Owner:_ Ifiok Jr. · _Introduced in:_ [`f462724`](https://github.com/openbudgetfun/solana_kit/commit/f46272452cbc81021286b10e0e739b27b40c5b5b)

#### SEC-05: Add SSRF protection for WebSocket URLs.

- Block connections to private/internal hosts by default (localhost, 10.x, 172.16-31.x, 192.168.x, 169.254.x, fc/fd::)
- Added `allowPrivateHosts` option to `WebSocketChannelConfig` for local development
- 5 new SSRF protection tests

_Owner:_ Ifiok Jr. · _Introduced in:_ [`e77206e`](https://github.com/openbudgetfun/solana_kit/commit/e77206e37c0f793e9dc2b6b1632131b20ef9b959)

#### Add abortable websocket connection behavior and tests so subscription channels can be cancelled consistently with upstream promise abort helpers.

_Owner:_ Ifiok Jr. · _Introduced in:_ [`9ee2e44`](https://github.com/openbudgetfun/solana_kit/commit/9ee2e442b5831d9abe1a7b1494955c1728063b6b)
