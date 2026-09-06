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

- No package-specific changes were recorded; `solana_kit_wallet_standard` was updated to 0.1.1 as part of group `wallet`.

## wallet [0.1.2](https://github.com/openbudgetfun/solana_kit/releases/tag/wallet/v0.1.2) (2026-09-06)

### 🚀 Feature

#### Fallback logos for popular wallets

Wallets that announce no icon — or an icon that is not a strict base64 data URI — used to be dropped by browser discovery entirely, and icons that failed to render left an empty slot. Browser discovery now substitutes a bundled logo keyed by wallet name (official logos for 36 popular wallets including Phantom, Solflare, MetaMask, and Backpack, sourced from the wallets' own adapter and extension repositories), `WalletAvatar` renders a neutral generic glyph when an icon fails to decode, and `walletLogoFallback` plus `genericWalletLogo` are exported for custom UIs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #237](https://github.com/openbudgetfun/solana_kit/pull/237)

### 🐛 Fixed

#### Deduplicate detected wallets and clean up picker text

The registry now ignores wallets whose name is already registered, so extensions that announce themselves more than once (additional content-script worlds, reloads) no longer produce duplicate picker tiles. Wallet picker content carries an explicit default text style, which removes the framework fallback's yellow double underline that leaked under every label in Cupertino presentations.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #236](https://github.com/openbudgetfun/solana_kit/pull/236)
