---
title: Wallet UI
description: A wallet connect surface that feels at home in any Flutter app — Material, Cupertino, adaptive, or hand-drawn Skribble — with a live demo.
---

## What Wallet UI Does

`solana_kit_wallet_ui` is the connect surface of the Solana Kit wallet stack. Discovery, authorization, and message signing live in `solana_kit_wallet_adapter` and `solana_kit_wallet_standard`; the UI package turns that state into Flutter widgets:

- one **adaptive connect button** that picks Material or Cupertino per platform,
- a **hand-drawn Skribble presentation** that renders the same flow with the [skribble](https://pub.dev/packages/skribble) design system,
- a **framework-neutral picker** (`WalletPickerContent`) you can embed in any surface you already own,
- an SVG/data-URI **avatar** (`WalletAvatar`) for any Wallet Standard icon format,
- a small token vocabulary (`WalletUiTheme`, `WalletUiPalette`) instead of a foreign design system.

Nothing here assumes it owns the screen. Every widget takes builders you can replace to bend the flow to your app.

## Live Demo

The frame below runs the real package — the example app built for web. It detects the Wallet Standard wallets you have installed in the browser the same way the wallet adapter examples do, and always keeps a deterministic demo wallet available so the picker is never empty. Connecting to a detected wallet uses your real wallet; every demo-wallet interaction stays local: no keys, no network, no setup.

<WalletDemo height="720"></WalletDemo>

What to try:

1. Pick a presentation at the top of the action panel — Adaptive, Material, Cupertino, or **Skribble**. Skribble swaps the whole connect flow to hand-drawn ink: a rough-filled connect button, sketchy wallet tiles, and a doodle-marked empty state, so the frame below shows exactly how a wallet app looks with Skribble built in.
2. Press the connect button. The picker lists every Wallet Standard wallet detected in your browser — Phantom, Backpack, Solflare, and any other standard-compatible extension — plus the built-in demo wallet.
3. After connecting, use **Sign message** to exercise the `solana_signMessage` feature end to end.
4. **Check Surfpool** pings a local [surfpool](https://github.com/txtx/surfpool) node — in the hosted demo it reports unavailable unless you run one on `localhost:8899`.

> [!TIP]
> The demo source lives in [`packages/solana_kit_wallet_ui/example`](https://github.com/openbudgetfun/solana_kit/tree/main/packages/solana_kit_wallet_ui/example). Run it locally with `fvm flutter run -d chrome --dart-define=DEMO_WALLET=true`.

## Quickstart

```dart
final registry = createDefaultWalletRegistry(
  appIdentity: const WalletAppIdentity(name: 'My app'),
  chain: SolanaChainId.mainnet,
);
final controller = WalletController(registry, chain: SolanaChainId.mainnet);
await controller.initialize();

const AdaptiveWalletButton(controller: controller);
```

That is the whole connect experience: the controller watches the registry, the button renders connect / progress / connected states, and the picker appears on tap.

## One Button, Three Platforms

`AdaptiveWalletButton` resolves per platform at runtime. Pin a style explicitly whenever you need it:

```dart
// Follows the platform (Material elsewhere, Cupertino on Apple).
const AdaptiveWalletButton(controller: controller);

// Explicit variants:
MaterialWalletButton(controller: controller);
CupertinoWalletButton(controller: controller);
```

`WalletUiStyle.material` and `WalletUiStyle.cupertino` are pure Flutter surfaces — they do not pull platform channels — so both render identically in tests and on web.

## A Hand-Drawn Wallet with Skribble

[Skribble](https://pub.dev/packages/skribble) is a design system of sketchy, hand-drawn widgets that keeps familiar Material-style APIs. Wallet UI ships a first-class presentation on top of it, so the entire connect flow — button, picker, tiles, disconnect sheet — can be drawn in ink:

```dart
import 'package:flutter/material.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_ui/skribble.dart';
import 'package:skribble/skribble.dart';

final controller = WalletController(registry, chain: SolanaChainId.mainnet);

SkribbleWalletButton(
  controller: controller,
  // Optional. Without it the nearest WiredTheme wins, falling back to
  // skribble's default ink when the app provides none.
  theme: WiredThemeData.cuddly(),
);

// The picker is also available standalone:
await showSkribbleWalletPicker(context: context, controller: controller);
```

Compact viewports get a hand-drawn bottom sheet, large viewports a hand-drawn dialog, and the wallet tiles are roughened per index so no two wobble alike. The discovery, error, and empty states — including the doodle-marked empty state — reuse `WalletPickerContent`, so behavior matches the Material and Cupertino pickers exactly. When you embed `WalletPickerContent` in your own hand-drawn shell, `skribbleWalletPalette` maps a `WiredThemeData` onto the neutral `WalletUiPalette` for you.

Skribble is a direct dependency of `solana_kit_wallet_ui`, so adopting the package now requires Flutter 3.47 or newer — the skribble floor.

## Make It Yours

Two extension points go deeper than colors:

```dart
WalletUiTheme(
  data: const WalletUiThemeData(
    borderRadius: 16,
    connectLabel: 'Link a wallet',
    pickerTitle: 'Pick your signer',
  ),
  child: AdaptiveWalletButton(controller: controller),
);
```

`WalletUiThemeData` carries the shared copy and geometry; `WalletUiPalette` colors the picker tiles when you render `WalletPickerContent` inside your own dialogs. For total control, every widget accepts builder overrides — `builder`, `tileBuilder`, `headerBuilder`, `emptyBuilder` — so the flow can be restyled without forking the wiring:

```dart
AdaptiveWalletButton(
  controller: controller,
  builder: (context, state, onPressed) => MyConnectChip(state, onTap: onPressed),
);
```

## Test Like a Product

`WalletUiKeys` exposes stable keys for every interactive element, and the example app ships Patrol end-to-end tests that drive connect → sign → disconnect against the deterministic demo wallet. The hosted demo above is the same app those tests exercise.
