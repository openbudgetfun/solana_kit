import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:solana_kit_wallet_ui/src/core.dart';

/// Resolves the [WiredThemeData] for skribble wallet widgets.
///
/// An explicit theme wins; otherwise the nearest `WiredTheme` ancestor is
/// retained, and skribble's default ink applies when neither exists.
WiredThemeData resolveSkribbleWalletTheme(
  BuildContext context,
  WiredThemeData? theme,
) => theme ?? WiredTheme.of(context);

/// Maps a hand-drawn theme onto the framework-neutral picker palette.
WalletUiPalette skribbleWalletPalette(WiredThemeData theme) => WalletUiPalette(
  accent: theme.borderColor,
  foreground: theme.textColor,
  mutedForeground: theme.disabledTextColor,
  surface: theme.fillColor,
  tile: theme.fillColor,
  tileBorder: theme.borderColor,
);

TextStyle _skribbleText(
  WiredThemeData theme, {
  double fontSize = 16,
  FontWeight fontWeight = FontWeight.w400,
  double? letterSpacing,
  double? height,
}) => TextStyle(
  inherit: false,
  color: theme.textColor,
  fontFamily: theme.fontFamily,
  package: theme.fontPackage,
  fontSize: fontSize,
  fontWeight: fontWeight,
  letterSpacing: letterSpacing,
  decoration: TextDecoration.none,
  height: height,
);

/// Opens a responsive hand-drawn wallet picker built with skribble widgets.
///
/// Compact viewports get a hand-drawn bottom sheet; large viewports get a
/// hand-drawn dialog with the responsive two-column wallet grid. The picker
/// body reuses [WalletPickerContent], so discovery, error, and empty states
/// behave exactly like the Material and Cupertino pickers.
Future<Wallet?> showSkribbleWalletPicker({
  required BuildContext context,
  required WalletController controller,
  WiredThemeData? theme,
  WalletEmptyBuilder? emptyBuilder,
  WalletPickerHeaderBuilder? headerBuilder,
  WalletTileBuilder? tileBuilder,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final wired = resolveSkribbleWalletTheme(context, theme);
  final palette = skribbleWalletPalette(wired);

  Future<void> select(BuildContext routeContext, Wallet wallet) async {
    try {
      await controller.connect(wallet);
      if (routeContext.mounted) Navigator.of(routeContext).pop(wallet);
    } on Object {
      // The controller exposes the error and the picker stays open for retry.
    }
  }

  Widget content(BuildContext routeContext) => WiredTheme(
    data: wired,
    child: WalletPickerContent(
      controller: controller,
      emptyBuilder: emptyBuilder ?? _skribbleEmpty,
      headerBuilder: headerBuilder ?? _skribbleHeader,
      onClose: () => Navigator.of(routeContext).pop(),
      onSelected: (wallet) => select(routeContext, wallet),
      palette: palette,
      tileBuilder: tileBuilder ?? _skribbleTile,
    ),
  );

  if (width < 640) {
    // WiredBottomSheet draws its own ink border and handle, but the modal
    // route background stays in the ambient Material scheme, so it is set
    // explicitly to the hand-drawn paper.
    return showModalBottomSheet<Wallet>(
      context: context,
      backgroundColor: wired.fillColor,
      builder: (routeContext) => WiredBottomSheet(child: content(routeContext)),
    );
  }
  return showDialog<Wallet>(
    context: context,
    builder: (routeContext) => WiredTheme(
      data: wired,
      child: Dialog(
        backgroundColor: wired.fillColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 680),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(wired.inkExtent / 2),
                  child: WiredCanvas(
                    painter: WiredRoundedRectangleBase(
                      borderRadius: BorderRadius.circular(18),
                      borderColor: wired.borderColor,
                      fillColor: wired.fillColor,
                      strokeWidth: wired.strokeWidth,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: content(routeContext),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Hand-drawn connect button built with skribble widgets.
///
/// The state machine matches `MaterialWalletButton` and
/// `CupertinoWalletButton`: disconnected taps open the skribble picker,
/// connected taps offer disconnect, and connecting or disconnecting disables
/// the button. It reads the hand-drawn palette from the nearest `WiredTheme`,
/// or from [theme] when provided.
class SkribbleWalletButton extends StatelessWidget {
  /// Creates a skribble wallet button.
  const SkribbleWalletButton({
    required this.controller,
    this.theme,
    this.builder,
    this.emptyBuilder,
    this.headerBuilder,
    this.tileBuilder,
    super.key,
  });

  /// Wallet controller to observe.
  final WalletController controller;

  /// Hand-drawn theme override; the nearest `WiredTheme` wins when null.
  final WiredThemeData? theme;

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
    final wired = resolveSkribbleWalletTheme(context, theme);
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
              WiredTheme(
                data: wired,
                child: WiredFilledButton(
                  onPressed: onPressed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (busy)
                        const SizedBox.square(
                          dimension: 18,
                          child: WiredLoadingIndicator(),
                        )
                      else
                        WiredIcon(
                          icon: state.isConnected
                              ? Icons.account_balance_wallet
                              : Icons.add,
                          size: 18,
                          color: _contrastInk(wired.borderColor),
                        ),
                      const SizedBox(width: 8),
                      Text(_label(context, state)),
                    ],
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
      await showSkribbleWalletPicker(
        context: context,
        controller: controller,
        theme: theme,
        emptyBuilder: emptyBuilder,
        headerBuilder: headerBuilder,
        tileBuilder: tileBuilder,
      );
      return;
    }
    await showWiredBottomSheet<void>(
      context: context,
      builder: (routeContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: WiredButton(
            key: WalletUiKeys.disconnectButton,
            onPressed: () async {
              Navigator.of(routeContext).pop();
              await controller.disconnect();
            },
            child: const Text('Disconnect wallet'),
          ),
        ),
      ),
    );
  }
}

Color _contrastInk(Color fill) =>
    fill.computeLuminance() > 0.179 ? Colors.black : Colors.white;

Widget _skribbleHeader(
  BuildContext context,
  String title,
  VoidCallback? onClose,
) {
  final wired = WiredTheme.of(context);
  return Row(
    children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: _skribbleText(
              wired,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      if (onClose != null)
        Semantics(
          button: true,
          label: 'Close wallet picker',
          child: GestureDetector(
            key: WalletUiKeys.closePicker,
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: SizedBox.square(
              dimension: 48,
              child: Center(
                child: Text('×', style: _skribbleText(wired, fontSize: 28)),
              ),
            ),
          ),
        ),
    ],
  );
}

Widget _skribbleTile(
  BuildContext context,
  Wallet wallet,
  int index,
  VoidCallback onTap,
) {
  final wired = WiredTheme.of(context);
  final tokens = WalletUiTheme.of(context);
  return Semantics(
    button: true,
    label: 'Connect ${wallet.name}',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.roundedRectangle,
          borderRadius: BorderRadius.circular(tokens.borderRadius),
          drawConfig: wired.drawConfig,
          borderStyle: RoughDrawingStyle(
            width: wired.strokeWidth,
            color: wired.borderColor,
          ),
          seed: index + 1,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              WalletAvatar(
                icon: wallet.icon,
                semanticLabel: '${wallet.name} icon',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _skribbleText(wired, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text('›', style: _skribbleText(wired, fontSize: 26)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _skribbleEmpty(BuildContext context) {
  final wired = WiredTheme.of(context);
  final tokens = WalletUiTheme.of(context);
  return Semantics(
    key: WalletUiKeys.emptyState,
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      child: Column(
        children: [
          const WiredDoodle(
            kind: WiredDoodleKind.scribble,
            size: 52,
            seed: 4,
          ),
          const SizedBox(height: 16),
          Text(
            tokens.emptyTitle,
            textAlign: TextAlign.center,
            style: _skribbleText(
              wired,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tokens.emptyDescription,
            textAlign: TextAlign.center,
            style: _skribbleText(wired, height: 1.4),
          ),
        ],
      ),
    ),
  );
}
