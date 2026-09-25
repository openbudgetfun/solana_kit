import 'package:flutter/material.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:solana_kit_wallet_ui/src/core.dart';

/// Opens a responsive Material wallet picker.
Future<Wallet?> showMaterialWalletPicker({
  required BuildContext context,
  required WalletController controller,
  WalletEmptyBuilder? emptyBuilder,
  WalletPickerHeaderBuilder? headerBuilder,
  WalletTileBuilder? tileBuilder,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final palette = _materialPalette(context);
  Future<void> select(BuildContext routeContext, Wallet wallet) async {
    try {
      await controller.connect(wallet);
      if (routeContext.mounted) Navigator.of(routeContext).pop(wallet);
    } on Object {
      // The controller exposes the error and the picker stays open for retry.
    }
  }

  if (width < 640) {
    return showModalBottomSheet<Wallet>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (routeContext) => WalletPickerContent(
        controller: controller,
        emptyBuilder: emptyBuilder,
        headerBuilder: headerBuilder,
        onClose: () => Navigator.of(routeContext).pop(),
        onSelected: (wallet) => select(routeContext, wallet),
        palette: palette,
        tileBuilder: tileBuilder,
      ),
    );
  }
  return showDialog<Wallet>(
    context: context,
    builder: (routeContext) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(32),
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
  );
}

/// Material connect button with connected-account and disconnect states.
class MaterialWalletButton extends StatelessWidget {
  /// Creates a Material wallet button.
  const MaterialWalletButton({
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
              FilledButton.icon(
                onPressed: onPressed,
                icon: busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        state.isConnected
                            ? Icons.account_balance_wallet
                            : Icons.add,
                      ),
                label: Text(_label(context, state)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
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
      await showMaterialWalletPicker(
        context: context,
        controller: controller,
        emptyBuilder: emptyBuilder,
        headerBuilder: headerBuilder,
        tileBuilder: tileBuilder,
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (routeContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ListTile(
            key: WalletUiKeys.disconnectButton,
            minTileHeight: 52,
            leading: const Icon(Icons.logout),
            title: const Text('Disconnect wallet'),
            onTap: () async {
              Navigator.of(routeContext).pop();
              await controller.disconnect();
            },
          ),
        ),
      ),
    );
  }
}

WalletUiPalette _materialPalette(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  return WalletUiPalette(
    accent: colors.primary,
    foreground: colors.onSurface,
    mutedForeground: colors.onSurfaceVariant,
    surface: colors.surface,
    tile: colors.surfaceContainerLow,
    tileBorder: colors.outlineVariant,
  );
}
