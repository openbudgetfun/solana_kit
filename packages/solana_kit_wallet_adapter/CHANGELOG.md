# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## wallet [0.1.0](https://github.com/openbudgetfun/solana_kit/releases/tag/wallet/v0.1.0) (2026-08-30)

### 💥 Breaking Change

#### Add cross-platform Flutter wallet support

Add Wallet Standard contracts, browser discovery, Android Mobile Wallet Adapter support, Solana Kit signer integration, and responsive Material, Cupertino, and adaptive wallet UI. Applications can use the default interface, customize its theme and builders, or bring entirely custom widgets.

```dart
final registry = createDefaultWalletRegistry(
  appIdentity: const WalletAppIdentity(name: 'My app'),
  chain: SolanaChainId.mainnet,
);
final controller = WalletController(registry);
await controller.initialize();
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #224](https://github.com/openbudgetfun/solana_kit/pull/224)

## wallet [0.1.1](https://github.com/openbudgetfun/solana_kit/releases/tag/wallet/v0.1.1) (2026-08-30)

### Changed

- No package-specific changes were recorded; `solana_kit_wallet_adapter` was updated to 0.1.1 as part of group `wallet`.

## wallet [0.1.2](https://github.com/openbudgetfun/solana_kit/releases/tag/wallet/v0.1.2) (2026-09-06)

### 🚀 Feature

#### List detected wallets in the embedded demo

`createDefaultWalletRegistry` accepts `additionalWallets` that stay available alongside the wallets detected on the platform. The embedded docs demo now composes the deterministic demo wallet with the visitor's installed Wallet Standard wallets, so Phantom, Backpack, Solflare, and any other standard-compatible extension appear in the picker the same way the wallet adapter examples surface them.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #235](https://github.com/openbudgetfun/solana_kit/pull/235)

### 🐛 Fixed

#### Validate mobile wallet request and authorization boundaries

Reject mobile wallet signing batches that mix authorized accounts, transaction chains, or submission options before calling the wallet backend. This prevents later requests from silently using the first account or submission policy and prevents transactions requested for another chain from using the active authorization.

Revoke local mobile wallet authority as soon as disconnect starts, including when backend cleanup fails, and prevent pending or superseded connect and sign-in requests from restoring authorization.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Decode native mobile wallet message signatures correctly

Request one signer for each native Mobile Wallet Adapter message batch and extract the 64-byte signature from each returned signed-message envelope. Reject inconsistent output counts, invalid encodings, incorrect signature lengths, and substituted message bytes before exposing signing results.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Preserve wallet authorization state across asynchronous lifecycle changes

Invalidate pending wallet connections when disconnecting, switching wallets, unregistering, or disposing the controller. Clear the selected account immediately on disconnect, reject stale connection completions, release old wallet listeners, and prevent delayed discovery or signing failures from overwriting a newer connection.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #238](https://github.com/openbudgetfun/solana_kit/pull/238)

#### Fallback logos for popular wallets

Wallets that announce no icon — or an icon that is not a strict base64 data URI — used to be dropped by browser discovery entirely, and icons that failed to render left an empty slot. Browser discovery now substitutes a bundled logo keyed by wallet name (official logos for 36 popular wallets including Phantom, Solflare, MetaMask, and Backpack, sourced from the wallets' own adapter and extension repositories), `WalletAvatar` renders a neutral generic glyph when an icon fails to decode, and `walletLogoFallback` plus `genericWalletLogo` are exported for custom UIs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #237](https://github.com/openbudgetfun/solana_kit/pull/237)
