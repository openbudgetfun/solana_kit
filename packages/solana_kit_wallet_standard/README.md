# solana_kit_wallet_standard

[![pub package](https://img.shields.io/pub/v/solana_kit_wallet_standard.svg)](https://pub.dev/packages/solana_kit_wallet_standard) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_wallet_standard)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_wallet_standard)

Pure Dart contracts for [Wallet Standard](https://github.com/wallet-standard/wallet-standard) wallets, accounts, registries, and Solana features. The package contains no Flutter or platform dependencies.

## Installation

```yaml
dependencies:
  solana_kit_wallet_standard: ^0.1.0
```

## Usage

```dart
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

Future<List<WalletAccount>> connect(Wallet wallet) async {
  final feature = wallet.feature<StandardConnectFeature>(
    StandardFeatureId.connect,
  );
  if (feature == null) {
    throw const WalletStandardException(
      WalletStandardErrorCode.unsupportedFeature,
      'Wallet does not support standard:connect',
    );
  }
  return (await feature.connect()).accounts;
}
```

## Key APIs

- `Wallet`, `WalletAccount`, and `WalletIcon`
- `WalletFeature` and type-safe feature lookup
- Standard connect, disconnect, and event contracts
- Solana transaction, message, sign-in, and offchain-message features
- `WalletRegistry` and `WalletRegistryController`
- `WalletStandardException`
