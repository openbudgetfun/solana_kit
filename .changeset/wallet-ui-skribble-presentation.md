---
"solana_kit_wallet_ui": minor
---

# Add a hand-drawn Skribble wallet presentation

The wallet components can now render with [skribble](https://pub.dev/packages/skribble), the hand-drawn Flutter design system. `SkribbleWalletButton` mirrors the Material and Cupertino connect buttons — connect, progress, connected-account, and disconnect states — using a `WiredFilledButton` and a hand-drawn disconnect sheet, and `showSkribbleWalletPicker` opens the picker as a `WiredBottomSheet` on compact viewports or a `WiredDialog` on wide ones, with rough-inked wallet tiles and a doodle-marked empty state over the same `WalletPickerContent` behavior as the other presentations.

`skribbleWalletPalette` maps a `WiredThemeData` onto the framework-neutral `WalletUiPalette` for applications that embed `WalletPickerContent` in their own hand-drawn shell, and `resolveSkribbleWalletTheme` resolves the effective theme (explicit override, then nearest `WiredTheme`, then skribble's default ink). The example app — which is also the embedded docs demo — gained a presentation selector covering Adaptive, Material, Cupertino, and Skribble so the hand-drawn wallet can be compared live.

Skribble is a direct dependency, so the package's Flutter floor rises from 3.44 to 3.47 and the workspace FVM pin moves to 3.47.4 accordingly.

```dart
SkribbleWalletButton(
  controller: walletController,
  theme: WiredThemeData.cuddly(),
);
```
