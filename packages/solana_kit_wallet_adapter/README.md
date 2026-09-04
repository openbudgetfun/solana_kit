# solana_kit_wallet_adapter

[![pub package](https://img.shields.io/pub/v/solana_kit_wallet_adapter.svg)](https://pub.dev/packages/solana_kit_wallet_adapter) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_wallet_adapter)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_wallet_adapter)

Flutter wallet discovery, connection state, and Solana Kit signer integration. Browser builds discover installed Wallet Standard wallets; Android builds expose locally installed wallets through Mobile Wallet Adapter.

## Installation

```yaml
dependencies:
  solana_kit_wallet_adapter: ^0.1.0
```

## Usage

```dart
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

Future<WalletAccountSigner> connectFirstWallet() async {
  final registry = createDefaultWalletRegistry(
    appIdentity: const WalletAppIdentity(name: 'My app'),
    chain: SolanaChainId.devnet,
  );
  final wallets = WalletController(registry, chain: SolanaChainId.devnet);

  await wallets.initialize();
  await wallets.connect(wallets.state.wallets.first);

  return wallets.createSigner();
}
```

`WalletController` is a `ChangeNotifier`, so it works with Flutter's built-in `ListenableBuilder` and any state-management package. The adapter has no dependency on the optional widget package.

Pending authorization is invalidated when you disconnect, switch wallets, remove a wallet from the registry, or dispose the controller. A superseded `connect` future rejects with `WalletStandardErrorCode.disconnected`; its completion cannot restore an old selected account. Disconnect clears the selected account immediately, before the backend finishes. Create a fresh signer after each connection or account change.

## Platform behavior

- **Web:** implements the Wallet Standard `wallet-standard:register-wallet` and `wallet-standard:app-ready` event handshake, including wallets registered after application startup.
- **Android:** uses the Solana Mobile Wallet Adapter protocol to authorize, sign, send, disconnect, and complete Sign In With Solana.
- **Other native platforms:** returns an empty registry. Applications can supply their own `WalletRegistry` implementation or use a browser-based flow.

Mobile wallet signing batches must use one authorized account. Transaction chains must match the chain used to authorize the mobile wallet, and every sign-and-send input in a batch must use equivalent submission options. Submit requests with different accounts or policies separately; mismatched batches are rejected before any backend signing or submission. Disconnect immediately revokes local accounts even if backend cleanup fails. Pending or superseded connect/sign-in operations cannot restore authority.

Native message signing validates the returned message envelope and exposes the extracted 64-byte signature; malformed envelopes and changed message bytes are rejected.

## Key APIs

- `WalletController` and immutable `WalletAdapterState`
- `createDefaultWalletRegistry`
- `WalletAccountSigner`
- `MobileWallet`, `MobileWalletRegistry`, and `MobileWalletBackend`
- `WalletAppIdentity`
