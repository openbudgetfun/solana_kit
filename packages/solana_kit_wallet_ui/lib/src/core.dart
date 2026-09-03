import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';

/// Stable keys for wallet UI automation and accessibility testing.
abstract final class WalletUiKeys {
  /// The close button in a wallet picker.
  static const closePicker = Key('wallet_ui.close_picker');

  /// The primary connect or account button.
  static const connectButton = Key('wallet_ui.connect_button');

  /// The disconnect action for an active wallet.
  static const disconnectButton = Key('wallet_ui.disconnect_button');

  /// The picker empty state.
  static const emptyState = Key('wallet_ui.empty_state');

  /// The wallet picker surface.
  static const picker = Key('wallet_ui.picker');

  /// The picker progress indicator.
  static const progress = Key('wallet_ui.progress');

  /// Key for the tile at [index].
  static Key walletTile(int index) => Key('wallet_ui.wallet_tile.$index');
}

/// Colors shared by the unopinionated picker content.
@immutable
class WalletUiPalette {
  /// Creates a wallet UI color palette.
  const WalletUiPalette({
    required this.accent,
    required this.foreground,
    required this.mutedForeground,
    required this.surface,
    required this.tile,
    required this.tileBorder,
  });

  /// Emphasis and focus color.
  final Color accent;

  /// Primary text color.
  final Color foreground;

  /// Secondary text color.
  final Color mutedForeground;

  /// Picker background color.
  final Color surface;

  /// Wallet tile background color.
  final Color tile;

  /// Wallet tile outline color.
  final Color tileBorder;
}

/// Configurable geometry and copy shared by all wallet widgets.
@immutable
class WalletUiThemeData {
  /// Creates wallet UI configuration.
  const WalletUiThemeData({
    this.borderRadius = 20,
    this.compactBreakpoint = 560,
    this.connectLabel = 'Connect wallet',
    this.emptyDescription = 'Install a compatible wallet, then try again.',
    this.emptyTitle = 'No wallets found',
    this.maxPickerWidth = 720,
    this.pickerTitle = 'Choose a wallet',
  });

  /// Corner radius used by picker surfaces and tiles.
  final double borderRadius;

  /// Width below which the picker uses a single-column list.
  final double compactBreakpoint;

  /// Default disconnected button label.
  final String connectLabel;

  /// Empty-state supporting copy.
  final String emptyDescription;

  /// Empty-state heading.
  final String emptyTitle;

  /// Maximum width for large-screen picker surfaces.
  final double maxPickerWidth;

  /// Default picker heading.
  final String pickerTitle;

  /// Creates a copy with selected values replaced.
  WalletUiThemeData copyWith({
    double? borderRadius,
    double? compactBreakpoint,
    String? connectLabel,
    String? emptyDescription,
    String? emptyTitle,
    double? maxPickerWidth,
    String? pickerTitle,
  }) => WalletUiThemeData(
    borderRadius: borderRadius ?? this.borderRadius,
    compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
    connectLabel: connectLabel ?? this.connectLabel,
    emptyDescription: emptyDescription ?? this.emptyDescription,
    emptyTitle: emptyTitle ?? this.emptyTitle,
    maxPickerWidth: maxPickerWidth ?? this.maxPickerWidth,
    pickerTitle: pickerTitle ?? this.pickerTitle,
  );
}

/// Supplies wallet-specific design tokens below this widget.
class WalletUiTheme extends InheritedTheme {
  /// Creates a wallet UI theme.
  const WalletUiTheme({required this.data, required super.child, super.key});

  /// Wallet design tokens.
  final WalletUiThemeData data;

  /// Finds the nearest wallet UI theme or returns sane defaults.
  static WalletUiThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WalletUiTheme>()?.data ??
      const WalletUiThemeData();

  @override
  bool updateShouldNotify(WalletUiTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      WalletUiTheme(data: data, child: child);
}

/// Builds an application-specific wallet row.
typedef WalletTileBuilder =
    Widget Function(
      BuildContext context,
      Wallet wallet,
      int index,
      VoidCallback onTap,
    );

/// Builds application-specific picker header content.
typedef WalletPickerHeaderBuilder =
    Widget Function(BuildContext context, String title, VoidCallback? onClose);

/// Builds an application-specific empty state.
typedef WalletEmptyBuilder = Widget Function(BuildContext context);

/// Builds a complete connect or account button.
typedef WalletButtonBuilder =
    Widget Function(
      BuildContext context,
      WalletAdapterState state,
      VoidCallback? onPressed,
    );

/// Renders Wallet Standard SVG and raster data URI icons.
class WalletAvatar extends StatelessWidget {
  /// Creates a wallet avatar.
  const WalletAvatar({
    required this.icon,
    this.semanticLabel,
    this.size = 44,
    super.key,
  });

  /// Wallet icon data.
  final WalletIcon icon;

  /// Accessible label for the image.
  final String? semanticLabel;

  /// Square image extent.
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = icon.mimeSubtype == 'svg+xml'
        ? SvgPicture.memory(
            icon.bytes,
            excludeFromSemantics: semanticLabel == null,
            semanticsLabel: semanticLabel,
          )
        : Image.memory(
            Uint8List.fromList(icon.bytes),
            excludeFromSemantics: semanticLabel == null,
            semanticLabel: semanticLabel,
          );
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.27),
        child: image,
      ),
    );
  }
}

/// Framework-neutral, responsive wallet picker body.
class WalletPickerContent extends StatelessWidget {
  /// Creates picker content which may also be embedded in custom UI.
  const WalletPickerContent({
    required this.controller,
    required this.onSelected,
    required this.palette,
    this.emptyBuilder,
    this.headerBuilder,
    this.onClose,
    this.tileBuilder,
    super.key,
  });

  /// Wallet controller to observe.
  final WalletController controller;

  /// Called when the user chooses a wallet.
  final ValueChanged<Wallet> onSelected;

  /// Colors for the framework-neutral content.
  final WalletUiPalette palette;

  /// Optional complete replacement for the empty state.
  final WalletEmptyBuilder? emptyBuilder;

  /// Optional complete replacement for the picker header.
  final WalletPickerHeaderBuilder? headerBuilder;

  /// Optional close affordance callback.
  final VoidCallback? onClose;

  /// Optional complete replacement for each wallet tile.
  final WalletTileBuilder? tileBuilder;

  @override
  Widget build(BuildContext context) {
    final tokens = WalletUiTheme.of(context);
    // Cupertino pickers have no Material ancestor, so without an explicit
    // default the ambient fallback style leaks its yellow double underline
    // under every label.
    return DefaultTextStyle(
      style: TextStyle(
        inherit: false,
        color: palette.foreground,
        fontSize: 16,
        decoration: TextDecoration.none,
      ),
      child: ColoredBox(
        key: WalletUiKeys.picker,
        color: palette.surface,
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxPickerWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  final state = controller.state;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      (headerBuilder ?? _header)(
                        context,
                        tokens.pickerTitle,
                        onClose,
                      ),
                      const SizedBox(height: 18),
                      if (state.connectionStatus ==
                          WalletConnectionStatus.discovering)
                        Center(
                          key: WalletUiKeys.progress,
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: RepaintBoundary(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(
                                  palette.accent,
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (state.wallets.isEmpty)
                        (emptyBuilder ?? _empty)(context)
                      else
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, constraints) =>
                                _wallets(context, constraints, state.wallets),
                          ),
                        ),
                      if (state.error != null) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            state.error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wallets(
    BuildContext context,
    BoxConstraints constraints,
    List<Wallet> wallets,
  ) {
    final tokens = WalletUiTheme.of(context);
    final columns = constraints.maxWidth >= tokens.compactBreakpoint ? 2 : 1;
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: columns == 1 ? 4.8 : 3.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return KeyedSubtree(
          key: WalletUiKeys.walletTile(index),
          child: (tileBuilder ?? _tile)(
            context,
            wallet,
            index,
            () => onSelected(wallet),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, String title, VoidCallback? onClose) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(
                color: palette.foreground,
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
              child: const SizedBox.square(
                dimension: 48,
                child: Center(child: Text('×', style: TextStyle(fontSize: 28))),
              ),
            ),
          ),
      ],
    );
  }

  Widget _empty(BuildContext context) {
    final tokens = WalletUiTheme.of(context);
    return Semantics(
      key: WalletUiKeys.emptyState,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: palette.tileBorder),
                borderRadius: BorderRadius.circular(18),
                color: palette.tile,
              ),
              alignment: Alignment.center,
              child: Text(
                '◇',
                style: TextStyle(color: palette.accent, fontSize: 25),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tokens.emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.foreground,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tokens.emptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.mutedForeground, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    Wallet wallet,
    int index,
    VoidCallback onTap,
  ) {
    final tokens = WalletUiTheme.of(context);
    return Semantics(
      button: true,
      label: 'Connect ${wallet.name}',
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.tile,
              border: Border.all(color: palette.tileBorder),
              borderRadius: BorderRadius.circular(tokens.borderRadius),
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
                      style: TextStyle(
                        color: palette.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '›',
                    style: TextStyle(color: palette.accent, fontSize: 26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shortens [address] without assuming a particular alphabet.
String compactWalletAddress(String address, {int edgeLength = 4}) {
  if (address.length <= edgeLength * 2 + 1) return address;
  return '${address.substring(0, edgeLength)}…'
      '${address.substring(address.length - edgeLength)}';
}
