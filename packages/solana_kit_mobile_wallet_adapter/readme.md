# solana_kit_mobile_wallet_adapter

Flutter plugin for the [Solana Mobile Wallet Adapter](https://github.com/solana-mobile/mobile-wallet-adapter) (MWA) protocol. Enables dApps and wallet apps to communicate for transaction signing on Android.

**Android-only.** MWA is not supported on iOS. This plugin compiles and runs on iOS without crashing (no-op), so mixed-platform Flutter apps work without conditional compilation.

## Features

### dApp side (client)

- **`transact()`** - One-call session lifecycle: launch wallet, handshake, execute callback, clean up
- **`LocalAssociationScenario`** - Full control over local WebSocket sessions with retry logic
- **`RemoteAssociationScenario`** - Remote sessions via WebSocket reflector (cross-device)
- **`KitMobileWallet`** - Typed API working with base64 payloads and Solana Kit types
- **Platform check** - `isMwaSupported()` / `assertMwaSupported()`

### Wallet side (server)

- **`WalletScenario`** - Manages incoming dApp connections via native Android bridge
- **`WalletScenarioCallbacks`** - Interface for handling authorize, sign, and deauthorize requests
- **Typed request/response** - `AuthorizeDappRequest`, `SignTransactionsRequest`, etc. with `completeWith*` methods
- **`MobileWalletAdapterConfig`** - Wallet capabilities (max payloads, features, transaction versions)

## Usage

### dApp: Simple session

```dart
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

final authResult = await transact((wallet) async {
  // Authorize with the wallet.
  final auth = await wallet.authorize(
    identity: const AppIdentity(name: 'My dApp'),
    chain: 'solana:mainnet',
  );

  // Sign transactions.
  final signed = await wallet.signTransactions(
    payloads: [base64EncodedTransaction],
  );

  return auth;
});
```

### dApp: Manual session control

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

### Wallet: Handling requests

```dart
class MyWalletCallbacks implements WalletScenarioCallbacks {
  @override
  void onAuthorizeRequest(AuthorizeDappRequest request) {
    // Show UI to approve/decline.
    request.completeWithAuthorize(
      accounts: [
        AuthorizedAccount(address: base64PublicKey, label: 'Main Account'),
      ],
      authToken: 'issued-token',
    );
  }

  @override
  void onSignTransactionsRequest(SignTransactionsRequest request) {
    // Sign the payloads.
    final signed = signPayloads(request.payloads);
    request.completeWithSignedPayloads(signed);
  }

  // ... implement other callbacks
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

## Platform support

| Platform | dApp (client) | Wallet (server) |
| -------- | ------------- | --------------- |
| Android  | Supported     | Supported       |
| iOS      | No-op         | No-op           |
| Web      | N/A           | N/A             |

Use `isMwaSupported()` to check at runtime before calling MWA APIs.

## Architecture

This plugin uses a hybrid Dart + native approach:

- **Dart**: All WebSocket handling, P-256 cryptography, session handshake, JSON-RPC messaging, and protocol logic (via `solana_kit_mobile_wallet_adapter_protocol`)
- **Android Kotlin**: Intent launching (`solana-wallet://` scheme) and wallet scenario bridge (MethodChannel)
- **iOS Swift**: Empty no-op plugin that compiles cleanly

This maximizes code sharing, testability, and reuse of the pure Dart protocol package.
