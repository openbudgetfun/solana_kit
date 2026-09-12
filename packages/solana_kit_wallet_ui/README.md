# solana_kit_wallet_ui

[![pub package](https://img.shields.io/pub/v/solana_kit_wallet_ui.svg)](https://pub.dev/packages/solana_kit_wallet_ui) [![CI](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/openbudgetfun/solana_kit/actions/workflows/ci.yml) [![coverage](https://codecov.io/gh/openbudgetfun/solana_kit/branch/main/graph/badge.svg?flag=solana_kit_wallet_ui)](https://codecov.io/gh/openbudgetfun/solana_kit?flag=solana_kit_wallet_ui)

Responsive Material, Cupertino, adaptive, and hand-drawn wallet UI for Solana Kit. The defaults are production-ready, but every visible layer can be replaced without forking the package.

## Installation

Requires Flutter 3.47 or newer (the [skribble](https://pub.dev/packages/skribble) floor).

```yaml
dependencies:
  solana_kit_wallet_ui: ^0.1.0
```

## Adaptive defaults

```dart
import 'package:flutter/widgets.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_ui/adaptive.dart';

Widget buildWalletButton(WalletController walletController) =>
    AdaptiveWalletButton(controller: walletController);
```

The adaptive entrypoint uses Cupertino presentation on iOS and macOS, and Material presentation elsewhere. Pass `style` when an application deliberately uses one design language on every platform.

## Material and Cupertino entrypoints

```dart
import 'package:flutter/widgets.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_ui/material.dart';

Widget buildWalletButton(WalletController walletController) =>
    MaterialWalletButton(controller: walletController);
```

```dart
import 'package:flutter/widgets.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_ui/cupertino.dart';

Widget buildWalletButton(WalletController walletController) =>
    CupertinoWalletButton(controller: walletController);
```

Compact viewports use a bottom sheet or Cupertino popup. Large viewports use a constrained dialog and a two-column wallet grid. All interactive defaults have at least a 44 logical-pixel target.

## Skribble hand-drawn presentation

The same connect flow can render with [skribble](https://pub.dev/packages/skribble), the hand-drawn design system: a `WiredFilledButton` connect button, rough-inked wallet tiles, and a `WiredBottomSheet` or `WiredDialog` picker shell.

```yaml
dependencies:
  skribble: ^0.1.1 # optional; only needed to pass an explicit theme
```

```dart
import 'package:flutter/material.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_ui/skribble.dart';
import 'package:skribble/skribble.dart';

Widget buildWalletButton(WalletController walletController) =>
    SkribbleWalletButton(
      controller: walletController,
      // Optional. Without it the nearest WiredTheme wins, falling back to
      // skribble's default ink when the app provides none.
      theme: WiredThemeData.cuddly(),
    );
```

`showSkribbleWalletPicker` opens the picker standalone with the same compact-sheet and wide-dialog split as the other presentations. `skribbleWalletPalette` maps a `WiredThemeData` onto the framework-neutral `WalletUiPalette` when you embed `WalletPickerContent` in your own hand-drawn shell.

## Customize or bring your own widgets

Use `WalletUiTheme` for copy and geometry, or replace individual pieces with `builder`, `headerBuilder`, `tileBuilder`, and `emptyBuilder`. For complete visual ownership, observe `WalletController` directly and build any widget tree you prefer. `WalletPickerContent` is also public for embedding the responsive discovery surface in an application-specific shell.

## Key APIs

- `AdaptiveWalletButton` and `showAdaptiveWalletPicker`
- `MaterialWalletButton` and `showMaterialWalletPicker`
- `CupertinoWalletButton` and `showCupertinoWalletPicker`
- `SkribbleWalletButton` and `showSkribbleWalletPicker`
- `WalletPickerContent` and `WalletAvatar`
- `WalletUiTheme`, `WalletUiThemeData`, and `WalletUiPalette`
- `WalletUiKeys` for stable integration-test selectors
