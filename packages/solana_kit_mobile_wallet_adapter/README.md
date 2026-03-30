# solana_kit_mobile_wallet_adapter

[![pub package](https://img.shields.io/pub/v/solana_kit_mobile_wallet_adapter.svg)](https://pub.dev/packages/solana_kit_mobile_wallet_adapter)
[![docs](https://img.shields.io/badge/docs-pub.dev-0175C2.svg)](https://pub.dev/documentation/solana_kit_mobile_wallet_adapter/latest/)
[![website](https://img.shields.io/badge/website-solana__kit__docs-0A7EA4.svg)](https://openbudgetfun.github.io/solana_kit/)
[![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml)
[![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg)](https://codecov.io/gh/openbudgetfun/solana_kit)

Flutter plugin for the [Solana Mobile Wallet Adapter](https://github.com/solana-mobile/mobile-wallet-adapter) (MWA) protocol.

This package provides both:

- dApp-side client flows (launch wallet, establish session, request signatures)
- wallet-side server flows (receive authorize/sign requests from dApps)

## Platform support

| Platform | dApp (client) | Wallet (server) |
| -------- | ------------- | --------------- |
| Android  | Supported     | Supported       |
| iOS      | No-op         | No-op           |
| Web      | N/A           | N/A             |

Use `isMwaSupported()` / `assertMwaSupported()` before invoking MWA APIs.

<!-- {=androidOnlyMwaCalloutSection|replace:"__MWA_FALLBACK_GUIDANCE__":"Gate wallet-handoff flows with `isMwaSupported()` / `assertMwaSupported()` and present a clear fallback such as browser-wallet instructions, a manual deep link path, or an explicit unsupported-platform message on iOS."} -->

> **Android-only Mobile Wallet Adapter**
>
> Real wallet handoff is available only on Android today.
>
> On iOS, `solana_kit_mobile_wallet_adapter` remains a safe stub/no-op because
> the current Solana MWA ecosystem does not expose an equivalent iOS
> integration target.
>
> **MWA_FALLBACK_GUIDANCE**

<!-- {/androidOnlyMwaCalloutSection} -->

## What this package includes

### dApp-side APIs

- `transact()` for simple one-call session lifecycle
- `LocalAssociationScenario` for explicit same-device control
- `startRemoteScenario()` for reflector-based cross-device sessions
- `KitMobileWallet` typed wrapper over the protocol wallet interface

### wallet-side APIs

- `WalletScenario` lifecycle and request routing
- `WalletScenarioCallbacks` for authorize/sign/deauthorize handling
- Typed request objects (`AuthorizeDappRequest`, `SignTransactionsRequest`, etc.)
- `MwaDigitalAssetLinksHostApi` for Android package verification

## Installation

```bash
flutter pub add solana_kit_mobile_wallet_adapter
```

Inside this monorepo, workspace dependency resolution is automatic.

## dApp usage

### Simple lifecycle (`transact`)

```dart
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';

final auth = await transact((wallet) async {
  final authorizeResult = await wallet.authorize(
    identity: const AppIdentity(name: 'My dApp'),
    chain: 'solana:mainnet',
  );

  await wallet.signTransactions(
    payloads: [base64EncodedTransaction],
  );

  return authorizeResult;
});
```

### Manual local association

```dart
final scenario = LocalAssociationScenario();

try {
  final rawWallet = await scenario.start();
  final wallet = wrapWithKitApi(rawWallet);

  final auth = await wallet.authorize(
    identity: const AppIdentity(name: 'My dApp'),
    chain: 'solana:devnet',
  );

  final signed = await wallet.signTransactions(
    payloads: ['base64tx1', 'base64tx2'],
  );
} finally {
  await scenario.close();
}
```

### Remote association (cross-device)

`startRemoteScenario` resolves once a real reflector ID has been negotiated and a valid association URI is available.

```dart
final remote = await startRemoteScenario(
  const RemoteWalletAssociationConfig(
    reflectorHost: 'reflector.example.com',
  ),
);

// Display this as QR for wallet scan.
final uriForQr = remote.associationUri;

try {
  final wallet = await remote.wallet;
  await wallet.getCapabilities();
} finally {
  remote.close();
}
```

## wallet usage

### Start a wallet scenario

```dart
class MyWalletCallbacks implements WalletScenarioCallbacks {
  @override
  void onAuthorizeRequest(AuthorizeDappRequest request) {
    request.completeWithAuthorize(
      accounts: [
        AuthorizedAccount(
          address: base64PublicKey,
          label: 'Main Account',
        ),
      ],
      authToken: 'issued-token',
    );
  }

  @override
  void onSignTransactionsRequest(SignTransactionsRequest request) {
    final signed = signPayloads(request.payloads);
    request.completeWithSignedPayloads(signed);
  }

  @override
  void onReauthorizeRequest(ReauthorizeDappRequest request) {
    request.completeWithReauthorize(
      accounts: [AuthorizedAccount(address: base64PublicKey)],
      authToken: 'renewed-token',
    );
  }

  @override
  void onScenarioReady() {}

  @override
  void onScenarioServingClients() {}

  @override
  void onScenarioServingComplete() {}

  @override
  void onScenarioComplete() {}

  @override
  void onScenarioError(Object? error) {}

  @override
  void onScenarioTeardownComplete() {}

  @override
  void onSignMessagesRequest(SignMessagesRequest request) {}

  @override
  void onSignAndSendTransactionsRequest(SignAndSendTransactionsRequest request) {}

  @override
  void onDeauthorizedEvent(DeauthorizedEvent event) {}
}

final scenario = WalletScenario(
  walletName: 'My Wallet',
  config: const MobileWalletAdapterConfig(
    maxTransactionsPerSigningRequest: 10,
    optionalFeatures: ['solana:signTransactions'],
  ),
  callbacks: MyWalletCallbacks(),
);

await scenario.start();
```

### Digital Asset Links verification (wallet-side)

```dart
final dal = MwaDigitalAssetLinksHostApi();

final callingPackage = await dal.getCallingPackage();
final isVerified = await dal.verifyCallingPackage(
  clientIdentityUri: 'https://example.com',
);
```

This is useful when wallet policy requires Android app-origin verification before honoring sensitive requests.

## Native parity and behavior notes

- Android wallet-side implementation is backed by Solana Mobile `walletlib` request/scenario APIs.
- Request lifecycle is explicit:
  - native request -> Dart callback -> `completeWith*` -> native resolve/cancel
- Local/remote transport handling enforces inbound encrypted sequence ordering.
- Remote association supports reflector protocol negotiation (`binary` and `base64`).

## Maintenance and CI

- Android native compile safety is enforced in CI by building a temporary Android Flutter app that depends on this plugin.
- Local equivalent command:

```bash
./scripts/check-mobile-wallet-adapter-android-compile.sh
```

## Architecture

- Dart: protocol/session handling via `solana_kit_mobile_wallet_adapter_protocol`
- Android Kotlin: intent launch + walletlib/DAL host bridges
- iOS Swift: safe no-op plugin for mixed-platform app compatibility

## Manual testing app

A runnable Android-first Flutter example app is available in [`example/`](./example/).

It demonstrates explicit boundaries for platform support gating, wallet session state, message signing, and sign-and-send transaction handoff. On iOS, the example keeps the app shell alive and shows fallback UX instead of pretending wallet handoff is supported.

```bash
cd packages/solana_kit_mobile_wallet_adapter/example
flutter pub get
flutter run
```

For emulator/device wallet setup (including Solana's mock MWA wallet), follow:

- [`example/README.md`](./example/README.md)
- https://docs.solanamobile.com/get-started/development-setup#installation

<!-- {=packageExampleSection|replace:"__PACKAGE__":"solana_kit_mobile_wallet_adapter"|replace:"__EXAMPLE_PATH__":"example/main.dart"|replace:"__IMPORT_PATH__":"package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart"} -->

## Example

Use [`example/main.dart`](./example/main.dart) as a runnable starting point for `solana_kit_mobile_wallet_adapter`.

- Import path: `package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart`
- This section is centrally maintained with `mdt` to keep package guidance aligned.
- After updating shared docs templates, run `docs:update` from the repo root.

## Maintenance

- Validate docs in CI and locally with `docs:check`.
- Keep examples focused on one workflow and reference package README sections for deeper API details.

<!-- {/packageExampleSection} -->
