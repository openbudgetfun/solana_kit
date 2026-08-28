import 'package:flutter/cupertino.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:solana_kit_wallet_ui/src/core.dart';

/// Opens a responsive Cupertino wallet picker.
Future<Wallet?> showCupertinoWalletPicker({
  required BuildContext context,
  required WalletController controller,
  WalletEmptyBuilder? emptyBuilder,
  WalletPickerHeaderBuilder? headerBuilder,
  WalletTileBuilder? tileBuilder,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final palette = _cupertinoPalette(context);
  Future<void> select(BuildContext routeContext, Wallet wallet) async {
    try {
      await controller.connect(wallet);
      if (routeContext.mounted) Navigator.of(routeContext).pop(wallet);
    } on Object {
      // The controller exposes the error and the picker stays open for retry.
    }
  }

  if (width < 640) {
    return showCupertinoModalPopup<Wallet>(
      context: context,
      builder: (routeContext) => Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: WalletPickerContent(
            controller: controller,
            emptyBuilder: emptyBuilder,
            headerBuilder: headerBuilder,
            onClose: () => Navigator.of(routeContext).pop(),
            onSelected: (wallet) => select(routeContext, wallet),
            palette: palette,
            tileBuilder: tileBuilder,
          ),
        ),
      ),
    );
  }
  return showCupertinoDialog<Wallet>(
    context: context,
    builder: (routeContext) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 680),
            child: WalletPickerContent(
              controller: controller,
              emptyBuilder: emptyBuilder,
              headerBuilder: headerBuilder,
              onClose: () => Navigator.of(routeContext).pop(),
              onSelected: (wallet) => select(routeContext, wallet),
              palette: palette,
              tileBuilder: tileBuilder,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Cupertino connect button with connected-account and disconnect states.
class CupertinoWalletButton extends StatelessWidget {
  /// Creates a Cupertino wallet button.
  const CupertinoWalletButton({
    required this.controller,
    this.builder,
    this.emptyBuilder,
    this.headerBuilder,
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

  /// Optional picker wallet-tile replacement.
  final WalletTileBuilder? tileBuilder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final state = controller.state;
        final busy =
            state.connectionStatus == WalletConnectionStatus.connecting ||
            state.connectionStatus == WalletConnectionStatus.disconnecting;
        final onPressed = busy ? null : () => _pressed(context, state);
        return KeyedSubtree(
          key: WalletUiKeys.connectButton,
          child:
              builder?.call(context, state, onPressed) ??
              CupertinoButton.filled(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                onPressed: onPressed,
                child: Text(_label(context, state)),
              ),
        );
      },
    );
  }

  String _label(BuildContext context, WalletAdapterState state) {
    final account = state.selectedAccount;
    return account == null
        ? WalletUiTheme.of(context).connectLabel
        : account.label ?? compactWalletAddress(account.address);
  }

  Future<void> _pressed(
    BuildContext context,
    WalletAdapterState state,
  ) async {
    if (!state.isConnected) {
      await showCupertinoWalletPicker(
        context: context,
        controller: controller,
        emptyBuilder: emptyBuilder,
        headerBuilder: headerBuilder,
        tileBuilder: tileBuilder,
      );
      return;
    }
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (routeContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            key: WalletUiKeys.disconnectButton,
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(routeContext).pop();
              await controller.disconnect();
            },
            child: const Text('Disconnect wallet'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(routeContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

WalletUiPalette _cupertinoPalette(BuildContext context) {
  final brightness = CupertinoTheme.brightnessOf(context);
  final dark = brightness == Brightness.dark;
  return WalletUiPalette(
    accent: CupertinoTheme.of(context).primaryColor,
    foreground: CupertinoColors.label.resolveFrom(context),
    mutedForeground: CupertinoColors.secondaryLabel.resolveFrom(context),
    surface: CupertinoColors.systemBackground.resolveFrom(context),
    tile: dark
        ? CupertinoColors.secondarySystemBackground.darkColor
        : CupertinoColors.secondarySystemBackground.color,
    tileBorder: CupertinoColors.separator.resolveFrom(context),
  );
}
