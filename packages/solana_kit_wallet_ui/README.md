# solana_kit_wallet_ui

[![pub package](https://img.shields.io/pub/v/solana_kit_wallet_ui.svg)](https://pub.dev/packages/solana_kit_wallet_ui) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_wallet_ui)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_wallet_ui)

Responsive Material, Cupertino, and adaptive wallet UI for Solana Kit. The defaults are production-ready, but every visible layer can be replaced without forking the package.

## Installation

```yaml
dependencies:
  solana_kit_wallet_ui: ^0.1.0
```

## Adaptive defaults

```dart
import 'package:solana_kit_wallet_ui/adaptive.dart';

AdaptiveWalletButton(controller: walletController)
```

The adaptive entrypoint uses Cupertino presentation on iOS and macOS, and Material presentation elsewhere. Pass `style` when an application deliberately uses one design language on every platform.

## Material and Cupertino entrypoints

```dart
import 'package:solana_kit_wallet_ui/material.dart';

MaterialWalletButton(controller: walletController)
```

```dart
import 'package:solana_kit_wallet_ui/cupertino.dart';

CupertinoWalletButton(controller: walletController)
```

Compact viewports use a bottom sheet or Cupertino popup. Large viewports use a constrained dialog and a two-column wallet grid. All interactive defaults have at least a 44 logical-pixel target.

## Customize or bring your own widgets

Use `WalletUiTheme` for copy and geometry, or replace individual pieces with `builder`, `headerBuilder`, `tileBuilder`, and `emptyBuilder`. For complete visual ownership, observe `WalletController` directly and build any widget tree you prefer. `WalletPickerContent` is also public for embedding the responsive discovery surface in an application-specific shell.

## Key APIs

- `AdaptiveWalletButton` and `showAdaptiveWalletPicker`
- `MaterialWalletButton` and `showMaterialWalletPicker`
- `CupertinoWalletButton` and `showCupertinoWalletPicker`
- `WalletPickerContent` and `WalletAvatar`
- `WalletUiTheme`, `WalletUiThemeData`, and `WalletUiPalette`
- `WalletUiKeys` for stable integration-test selectors
