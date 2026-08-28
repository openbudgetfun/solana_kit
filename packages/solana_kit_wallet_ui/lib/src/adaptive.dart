import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:solana_kit_wallet_ui/src/core.dart';
import 'package:solana_kit_wallet_ui/src/cupertino.dart';
import 'package:solana_kit_wallet_ui/src/material.dart';

/// Explicit style override for adaptive wallet widgets.
enum WalletUiStyle {
  /// Material presentation.
  material,

  /// Cupertino presentation.
  cupertino,
}

/// Returns the platform's conventional wallet UI style.
WalletUiStyle defaultWalletUiStyle(TargetPlatform platform) =>
    switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => WalletUiStyle.cupertino,
      _ => WalletUiStyle.material,
    };

/// Opens the Material or Cupertino picker for [style] or the current platform.
Future<Wallet?> showAdaptiveWalletPicker({
  required BuildContext context,
  required WalletController controller,
  WalletEmptyBuilder? emptyBuilder,
  WalletPickerHeaderBuilder? headerBuilder,
  WalletUiStyle? style,
  WalletTileBuilder? tileBuilder,
}) {
  final resolved = style ?? defaultWalletUiStyle(defaultTargetPlatform);
  return switch (resolved) {
    WalletUiStyle.material => showMaterialWalletPicker(
      context: context,
      controller: controller,
      emptyBuilder: emptyBuilder,
      headerBuilder: headerBuilder,
      tileBuilder: tileBuilder,
    ),
    WalletUiStyle.cupertino => showCupertinoWalletPicker(
      context: context,
      controller: controller,
      emptyBuilder: emptyBuilder,
      headerBuilder: headerBuilder,
      tileBuilder: tileBuilder,
    ),
  };
}

/// Platform-adaptive connect button.
class AdaptiveWalletButton extends StatelessWidget {
  /// Creates an adaptive wallet button.
  const AdaptiveWalletButton({
    required this.controller,
    this.builder,
    this.emptyBuilder,
    this.headerBuilder,
    this.style,
    this.tileBuilder,
    super.key,
  });

  /// Wallet controller to observe.
  final WalletController controller;

  /// Optional complete replacement for the button.
  final WalletButtonBuilder? builder;

  /// Optional picker empty-state replacement.
  final WalletEmptyBuilder? emptyBuilder;

  /// Optional picker header replacement.
  final WalletPickerHeaderBuilder? headerBuilder;

  /// Optional explicit style override.
  final WalletUiStyle? style;

  /// Optional picker wallet-tile replacement.
  final WalletTileBuilder? tileBuilder;

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? defaultWalletUiStyle(defaultTargetPlatform);
    return switch (resolved) {
      WalletUiStyle.material => MaterialWalletButton(
        controller: controller,
        builder: builder,
        emptyBuilder: emptyBuilder,
        headerBuilder: headerBuilder,
        tileBuilder: tileBuilder,
      ),
      WalletUiStyle.cupertino => CupertinoWalletButton(
        controller: controller,
        builder: builder,
        emptyBuilder: emptyBuilder,
        headerBuilder: headerBuilder,
        tileBuilder: tileBuilder,
      ),
    };
  }
}
