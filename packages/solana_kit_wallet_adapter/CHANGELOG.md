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

## wallet [0.1.3](https://github.com/openbudgetfun/solana_kit/releases/tag/wallet/v0.1.3) (2026-09-12)

### Features

#### Use the Mobile Wallet Adapter from mobile browsers

The Mobile Wallet Adapter now works from Chrome (and other Chromium browsers) on Android devices, not just from native apps:

- `isMwaSupported()` returns `true` on web pages in a secure context (HTTPS or localhost), and the association intent is launched through a hidden iframe with page-blur detection mirroring the reference JS implementation; app-link URLs navigate directly.
- `transact` accepts an optional `launchIntent` override replacing the removed `clientApi` parameter.
- The wallet adapter's default web registry registers the Mobile Wallet Adapter wallet alongside browser-registered Wallet Standard wallets when the page runs in a mobile browser on Android, so mobile users keep wallet-app access from the picker.
- The example app gains the web platform so the flow can be tried in Chrome on a device.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #249](https://github.com/openbudgetfun/solana_kit/pull/249)

## wallet [0.2.0](https://github.com/openbudgetfun/solana_kit/releases/tag/wallet/v0.2.0) (2026-09-21)

### Breaking changes

#### Raise the Dart and Flutter baseline

The workspace now builds against Dart 3.13.3 and Flutter 3.47.4, and every package declares that floor instead of the previous Dart 3.12 range. Consumers on older SDKs can no longer resolve these packages, so this release is breaking even though no Dart API changed.

The Flutter floor rises from 3.44 to 3.47 for `solana_kit_mobile_wallet_adapter`, `solana_kit_mobile_wallet_adapter_protocol`, and `solana_kit_wallet_adapter`, matching the floor `solana_kit_wallet_ui` already required. `solana_kit_lints` ships the raised floor to consumers, so it carries the same breaking bump. Every other package raises only the Dart SDK floor.

Raising the language version also switches `dart format` to the tall style, so 83 files across library, test, script, and Codama-generated trees are reflowed. The renderer pipes generated output through `dart format`, so regenerating stays consistent.

Align your own SDK constraint with the workspace:

```yaml
environment:
  sdk: ^3.13.0
  # Omit for pure Dart packages; required for the Flutter packages above.
  flutter: ">=3.47.0"
```

_Owner:_ Ifiok Jr. · _Introduced in:_ [5f5fe01](https://github.com/openbudgetfun/solana_kit/commit/5f5fe01f3e2220ccfee54cc26e82c3face26589d) · _Last updated in:_ [19932db](https://github.com/openbudgetfun/solana_kit/commit/19932dba1979f1190b7501947b87eb8a4d4cc8d5)

### Fixes

- **Refresh analyzer excludes for the Flutter 3.47 toolchain.** The Flutter 3.47 tooling rewrites package `analysis_options.yaml` files during resolution to exclude generated `build/**` output from analysis. This applies the same exclusion to the wallet adapter and mobile wallet adapter packages (and the mobile example), keeping their analysis options stable under the updated FVM pin. No public API or behavior changes. _Owner:_ Ifiok Jr. · _Introduced in:_ [e041e73](https://github.com/openbudgetfun/solana_kit/commit/e041e731bb0291af05c06c16d7042fdbf51166a1)

## wallet [0.3.0](https://github.com/openbudgetfun/solana_kit/releases/tag/wallet/v0.3.0) (2026-10-12)

### Features

#### Verify wallet-returned signatures before accepting them

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #286](https://github.com/openbudgetfun/solana_kit/pull/286)

`MobileWallet` now cryptographically verifies every signature a wallet returns before handing it to the caller. Message signatures, signed transactions, and sign-and-send submission signatures are all checked against the authorized account's Ed25519 public key, and a signed transaction must carry the exact message bytes that were submitted — a wallet that returns a different transaction, a signature for a different transaction, or a well-formed forgery is rejected with `WalletStandardErrorCode.invalidResponse`.

A Sign In With Solana proof must now verify against the account it is attached to, and the MWA spec's rule that the returned sign-in address must belong to one of the authorized accounts is enforced: a proof attributed to an account that never signed in is rejected instead of silently falling back to the first authorized account, and non-`ed25519` signature types are rejected rather than passed through.

```dart
// A wallet that returns this can no longer impersonate the account:
final outputs = await mobileWallet
    .feature<SolanaSignMessageFeature>(SolanaFeatureId.signMessage)!
    .signMessage([SolanaSignMessageInput(account: account, message: data)]);
// Throws WalletStandardException(invalidResponse) unless `signature`
// verifies against `account.publicKey` over `data`.
```

The checks mirror the validate-before-trust pattern this workspace already applies in the dApp publisher CLI, which verifies portal-supplied transaction signatures before signing. Backends that return genuine signatures are unaffected.

#### Verify Wallet Standard signatures before accepting them

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #298](https://github.com/openbudgetfun/solana_kit/pull/298)

`WalletAccountSigner` now cryptographically verifies every signature a Wallet Standard wallet returns before handing it to the caller, closing the same gap the mobile-wallet path already guards against:

- Message signatures must verify against the authorized account's Ed25519 public key over the returned signed bytes.
- A signed transaction must include the account's signature, and that signature must verify over the returned transaction's message bytes.
- A sign-and-send submission signature must be a genuine signature of the **submitted** transaction's message bytes — verified against the authorized account first and every declared signer public key second — so a reported signature for a different transaction is rejected before the caller records it for confirmation tracking.

Anything else fails with `WalletStandardErrorCode.invalidResponse`. A compromised wallet can no longer attach well-formed forgeries as if the account had signed, which matters when wallet signatures are composed with local signers in the same transaction.

```dart
final signer = WalletAccountSigner(wallet: wallet, account: account, chain: chain);
// Throws WalletStandardException(invalidResponse) unless the wallet's
// signature verifies against `account.publicKey`.
final signed = await signer.modifyAndSignTransactions([transaction]);
```

Transaction modification itself remains permitted, as the `TransactionModifyingSigner` contract documents — but any modification must come with a genuine signature by the authorized account over the modified bytes.

### Fixes

- **Monostyle style pass.** Blank-line breathing room around control flow and returns, group splits, and collapsed blank runs, applied by `monostyle fix` and kept where dprint puts them. No behavior change: the renderers' emitted code and every package's API are untouched. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #283](https://github.com/openbudgetfun/solana_kit/pull/283)
