import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:solana_kit_wallet_ui/solana_kit_wallet_ui.dart';

void main() {
  const palette = WalletUiPalette(
    accent: Color(0xff00aa77),
    foreground: Color(0xff101010),
    mutedForeground: Color(0xff555555),
    surface: Color(0xffffffff),
    tile: Color(0xfff5f5f5),
    tileBorder: Color(0xffcccccc),
  );

  group('core UI', () {
    testWidgets('renders raster and SVG wallet avatars', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              WalletAvatar(icon: WalletIcon(_pngIcon), semanticLabel: 'PNG'),
              WalletAvatar(icon: WalletIcon(_svgIcon)),
            ],
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(WalletAvatar), findsNWidgets(2));
      expect(
        tester.getSize(find.byType(WalletAvatar).first),
        const Size(44, 44),
      );
    });

    testWidgets('applies theme defaults, copies, and wraps', (tester) async {
      const base = WalletUiThemeData();
      final copied = base.copyWith(
        borderRadius: 12,
        compactBreakpoint: 400,
        connectLabel: 'Link',
        emptyDescription: 'Install one',
        emptyTitle: 'Empty',
        maxPickerWidth: 600,
        pickerTitle: 'Wallets',
      );
      expect(copied.borderRadius, 12);
      expect(copied.compactBreakpoint, 400);
      expect(copied.connectLabel, 'Link');
      expect(copied.emptyDescription, 'Install one');
      expect(copied.emptyTitle, 'Empty');
      expect(copied.maxPickerWidth, 600);
      expect(copied.pickerTitle, 'Wallets');
      expect(base.copyWith().pickerTitle, base.pickerTitle);
      late WalletUiThemeData resolved;
      const theme = WalletUiTheme(data: base, child: SizedBox());
      expect(theme.updateShouldNotify(theme), isFalse);
      await tester.pumpWidget(
        WalletUiTheme(
          data: copied,
          child: Builder(
            builder: (context) {
              resolved = WalletUiTheme.of(context);
              return theme.wrap(context, const SizedBox());
            },
          ),
        ),
      );
      expect(resolved, copied);
      expect(compactWalletAddress('1234567890'), '1234…7890');
      expect(compactWalletAddress('short'), 'short');
      expect(compactWalletAddress('123456', edgeLength: 2), '12…56');
    });

    testWidgets('shows discovery, empty, and custom picker states', (
      tester,
    ) async {
      final pending = _PendingRegistry();
      final controller = WalletController(
        pending,
        chain: SolanaChainId.localnet,
      );
      unawaited(controller.initialize());
      await _pumpCore(tester, controller, palette: palette);
      expect(find.byKey(WalletUiKeys.progress), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(WalletUiKeys.emptyState), findsOneWidget);

      var closed = false;
      await _pumpCore(
        tester,
        controller,
        palette: palette,
        emptyBuilder: (_) => const Text('Custom empty'),
        headerBuilder: (_, title, onClose) => GestureDetector(
          onTap: onClose,
          child: Text('Custom $title'),
        ),
        onClose: () => closed = true,
      );
      await tester.tap(find.text('Custom Choose a wallet'));
      expect(closed, isTrue);
      expect(find.text('Custom empty'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders the generic glyph when the icon fails to decode', (
      tester,
    ) async {
      // Valid base64, but not a renderable SVG.
      final brokenIcon = WalletIcon(
        'data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIj8+PG5vdC1hLXN2Zz4=',
      );
      await tester.binding.setSurfaceSize(const Size(100, 100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: WalletAvatar(icon: brokenIcon, semanticLabel: 'Broken'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('wallet_ui.fallback_logo')), findsOneWidget);
    });

    testWidgets(
      'renders the generic glyph when a raster icon fails to decode',
      (
        tester,
      ) async {
        // Valid base64, but not a renderable raster image.
        final brokenIcon = WalletIcon('data:image/png;base64,AAAA');
        await tester.binding.setSurfaceSize(const Size(100, 100));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: WalletAvatar(icon: brokenIcon, semanticLabel: 'Broken'),
            ),
          ),
        );
        // Raster decoding completes asynchronously on the engine, so let the
        // pending codec work finish before flushing the frame.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();

        expect(
          find.byKey(const Key('wallet_ui.fallback_logo')),
          findsOneWidget,
        );
      },
    );

    testWidgets('picker content neutralizes the fallback text style', (
      tester,
    ) async {
      final controller = await _controller(wallets: [_Wallet('Test wallet')]);
      await tester.binding.setSurfaceSize(const Size(500, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      // Deliberately without a Material ancestor, mirroring the Cupertino
      // overlay where the ambient fallback style carries a yellow double
      // underline.
      await tester.pumpWidget(
        MaterialApp(
          home: WalletPickerContent(
            controller: controller,
            onSelected: (_) {},
            palette: palette,
          ),
        ),
      );
      await tester.pump();

      final context = tester.element(find.byKey(WalletUiKeys.picker));
      final style = DefaultTextStyle.of(context).style;
      expect(style.decoration, TextDecoration.none);
      expect(style.color, palette.foreground);
    });

    testWidgets('lays wallets out responsively and supports custom tiles', (
      tester,
    ) async {
      final controller = await _controller(
        wallets: [_Wallet('One'), _Wallet('Two')],
      );
      var selected = '';
      var closed = false;
      await _pumpCore(
        tester,
        controller,
        palette: palette,
        width: 420,
        onClose: () => closed = true,
        onSelected: (wallet) => selected = wallet.name,
      );
      final first = tester.getTopLeft(find.byKey(WalletUiKeys.walletTile(0)));
      final second = tester.getTopLeft(find.byKey(WalletUiKeys.walletTile(1)));
      expect(first.dx, second.dx);
      await tester.tap(find.byKey(WalletUiKeys.closePicker));
      await tester.tap(find.byKey(WalletUiKeys.walletTile(1)));
      expect(closed, isTrue);
      expect(selected, 'Two');

      var customTapped = false;
      await _pumpCore(
        tester,
        controller,
        palette: palette,
        width: 800,
        tileBuilder: (_, wallet, index, onTap) => TextButton(
          onPressed: () {
            customTapped = true;
            onTap();
          },
          child: Text('Custom ${wallet.name} $index'),
        ),
      );
      final wideFirst = tester.getTopLeft(
        find.byKey(WalletUiKeys.walletTile(0)),
      );
      final wideSecond = tester.getTopLeft(
        find.byKey(WalletUiKeys.walletTile(1)),
      );
      expect(wideFirst.dy, wideSecond.dy);
      await tester.tap(find.text('Custom One 0'));
      expect(customTapped, isTrue);
      controller.dispose();
    });
  });

  group('Material UI', () {
    testWidgets('connects and disconnects from the compact button', (
      tester,
    ) async {
      final wallet = _Wallet('Material');
      final controller = await _controller(wallets: [wallet]);
      await _pumpMaterial(tester, controller, width: 390);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
      await tester.tap(find.byKey(WalletUiKeys.closePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      expect(find.text('Primary'), findsOneWidget);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.disconnectButton));
      await tester.pumpAndSettle();
      expect(wallet.disconnected, isTrue);
      controller.dispose();
    });

    testWidgets('uses a dialog and custom builders on wide screens', (
      tester,
    ) async {
      final controller = await _controller(wallets: [_Wallet('Wide')]);
      await _pumpMaterial(
        tester,
        controller,
        width: 1000,
        buttonBuilder: (_, state, onPressed) => TextButton(
          onPressed: onPressed,
          child: const Text('Open custom'),
        ),
        emptyBuilder: (_) => const Text('No custom wallets'),
        headerBuilder: (_, title, onClose) => TextButton(
          onPressed: onClose,
          child: Text(title),
        ),
        tileBuilder: (_, wallet, index, onTap) => TextButton(
          onPressed: onTap,
          child: Text('Pick ${wallet.name}'),
        ),
      );
      await tester.tap(find.text('Open custom'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('Pick Wide'));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      controller.dispose();
    });

    testWidgets('keeps a rejected picker open and displays the error', (
      tester,
    ) async {
      final controller = await _controller(
        wallets: [_Wallet('Reject', reject: true)],
      );
      await _pumpMaterial(tester, controller);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pumpAndSettle();
      expect(find.textContaining('rejected'), findsOneWidget);
      expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
      controller.dispose();
    });
  });

  group('Cupertino and adaptive UI', () {
    testWidgets('connects and disconnects using Cupertino presentation', (
      tester,
    ) async {
      final wallet = _Wallet('Cupertino');
      final controller = await _controller(wallets: [wallet]);
      await _pumpCupertino(tester, controller, width: 390);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.closePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.disconnectButton));
      await tester.pumpAndSettle();
      expect(wallet.disconnected, isTrue);
      controller.dispose();
    });

    testWidgets('uses Cupertino dialog and custom button on wide screens', (
      tester,
    ) async {
      final controller = await _controller(
        wallets: [_Wallet('Wide Cupertino')],
      );
      await _pumpCupertino(
        tester,
        controller,
        width: 900,
        brightness: Brightness.dark,
        builder: (_, state, onPressed) => CupertinoButton(
          onPressed: onPressed,
          child: const Text('Open Cupertino'),
        ),
      );
      await tester.tap(find.text('Open Cupertino'));
      await tester.pumpAndSettle();
      expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
      await tester.tap(find.byKey(WalletUiKeys.closePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Cupertino'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      controller.dispose();
    });

    testWidgets('selects both explicit adaptive styles', (tester) async {
      final controller = await _controller();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: [
                AdaptiveWalletButton(
                  controller: controller,
                  style: WalletUiStyle.material,
                ),
                AdaptiveWalletButton(
                  controller: controller,
                  style: WalletUiStyle.cupertino,
                ),
                TextButton(
                  onPressed: () => showAdaptiveWalletPicker(
                    context: context,
                    controller: controller,
                  ),
                  child: const Text('Adaptive Material'),
                ),
                TextButton(
                  onPressed: () => showAdaptiveWalletPicker(
                    context: context,
                    controller: controller,
                    style: WalletUiStyle.cupertino,
                  ),
                  child: const Text('Adaptive Cupertino'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(MaterialWalletButton), findsOneWidget);
      expect(find.byType(CupertinoWalletButton), findsOneWidget);
      expect(defaultWalletUiStyle(TargetPlatform.iOS), WalletUiStyle.cupertino);
      expect(
        defaultWalletUiStyle(TargetPlatform.macOS),
        WalletUiStyle.cupertino,
      );
      expect(
        defaultWalletUiStyle(TargetPlatform.android),
        WalletUiStyle.material,
      );
      expect(
        defaultWalletUiStyle(TargetPlatform.linux),
        WalletUiStyle.material,
      );
      await tester.tap(find.text('Adaptive Material'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.closePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adaptive Cupertino'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.closePicker));
      await tester.pumpAndSettle();
      controller.dispose();
    });
  });
  group('Skribble UI', () {
    testWidgets('connects and disconnects from the compact button', (
      tester,
    ) async {
      final wallet = _Wallet('Skribble');
      final controller = await _controller(wallets: [wallet]);
      await _pumpSkribble(tester, controller, width: 390);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      expect(find.byType(WiredBottomSheet), findsOneWidget);
      expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
      await tester.tap(find.byKey(WalletUiKeys.closePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      expect(find.text('Primary'), findsOneWidget);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.disconnectButton));
      await tester.pumpAndSettle();
      expect(wallet.disconnected, isTrue);
      controller.dispose();
    });

    testWidgets('uses a hand-drawn dialog on wide screens', (tester) async {
      final controller = await _controller(wallets: [_Wallet('Wide sketch')]);
      await _pumpSkribble(tester, controller, width: 1000);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      // The rough ink border is drawn by a hand-drawn canvas.
      expect(find.byType(WiredCanvas), findsOneWidget);
      expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      controller.dispose();
    });

    testWidgets('keeps a rejected picker open and displays the error', (
      tester,
    ) async {
      final controller = await _controller(
        wallets: [_Wallet('Reject', reject: true)],
      );
      await _pumpSkribble(tester, controller, width: 390);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pump();
      expect(find.textContaining('rejected'), findsOneWidget);
      expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders custom builders inside the hand-drawn shell', (
      tester,
    ) async {
      final controller = await _controller(wallets: [_Wallet('Custom')]);
      await _pumpSkribble(
        tester,
        controller,
        width: 390,
        headerBuilder: (_, title, onClose) => GestureDetector(
          onTap: onClose,
          child: Text('Custom $title'),
        ),
        tileBuilder: (_, wallet, index, onTap) => TextButton(
          onPressed: onTap,
          child: Text('Sketch ${wallet.name} $index'),
        ),
      );
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      expect(find.byType(WiredBottomSheet), findsOneWidget);
      expect(find.text('Custom Choose a wallet'), findsOneWidget);
      await tester.tap(find.text('Custom Choose a wallet'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sketch Custom 0'));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      controller.dispose();
    });

    testWidgets('shows the doodle empty state when no wallets are found', (
      tester,
    ) async {
      final controller = await _controller();
      await _pumpSkribble(tester, controller, width: 390);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      expect(find.byKey(WalletUiKeys.emptyState), findsOneWidget);
      expect(find.byType(WiredDoodle), findsOneWidget);
      expect(find.text('No wallets found'), findsOneWidget);
      expect(
        find.text('Install a compatible wallet, then try again.'),
        findsOneWidget,
      );
      controller.dispose();
    });

    testWidgets('connects through an explicit light hand-drawn theme', (
      tester,
    ) async {
      final wallet = _Wallet('Paper');
      final controller = await _controller(wallets: [wallet]);
      await _pumpSkribble(
        tester,
        controller,
        width: 390,
        // A light border flips the filled button's contrast ink to black.
        theme: WiredThemeData(borderColor: const Color(0xffdddddd)),
      );
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      expect(find.text('Primary'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('shows a hand-drawn progress indicator while connecting', (
      tester,
    ) async {
      final wallet = _Wallet('Gated', gated: true);
      final controller = await _controller(wallets: [wallet]);
      await _pumpSkribble(tester, controller, width: 390);
      await tester.tap(find.byKey(WalletUiKeys.connectButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
      await tester.pump();
      expect(find.byType(WiredLoadingIndicator), findsOneWidget);
      expect(
        controller.state.connectionStatus,
        WalletConnectionStatus.connecting,
      );
      wallet.approveConnect();
      await tester.pumpAndSettle();
      expect(controller.state.isConnected, isTrue);
      controller.dispose();
    });

    testWidgets('resolves the hand-drawn theme and palette', (tester) async {
      final explicit = WiredThemeData(
        borderColor: const Color(0xffff0000),
        textColor: const Color(0xffeeeeee),
        disabledTextColor: const Color(0xff888888),
        fillColor: const Color(0xff101010),
      );
      final palette = skribbleWalletPalette(explicit);
      expect(palette.accent, explicit.borderColor);
      expect(palette.foreground, explicit.textColor);
      expect(palette.mutedForeground, explicit.disabledTextColor);
      expect(palette.surface, explicit.fillColor);
      expect(palette.tile, explicit.fillColor);
      expect(palette.tileBorder, explicit.borderColor);

      final inherited = WiredThemeData(borderColor: const Color(0xff00ff00));
      WiredThemeData? resolved;
      await tester.pumpWidget(
        WiredTheme(
          data: inherited,
          child: Builder(
            builder: (context) {
              resolved = resolveSkribbleWalletTheme(context, null);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(identical(resolved, inherited), isTrue);
      resolved = null;
      await tester.pumpWidget(
        WiredTheme(
          data: inherited,
          child: Builder(
            builder: (context) {
              resolved = resolveSkribbleWalletTheme(context, explicit);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(identical(resolved, explicit), isTrue);
      resolved = null;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            resolved = resolveSkribbleWalletTheme(context, null);
            return const SizedBox();
          },
        ),
      );
      expect(identical(resolved, WiredThemeData.defaultTheme), isTrue);
    });
  });
}

Future<WalletController> _controller({List<Wallet> wallets = const []}) async {
  final registry = WalletRegistryController();
  for (final wallet in wallets) {
    registry.register(wallet);
  }
  final controller = WalletController(registry, chain: SolanaChainId.localnet);
  await controller.initialize();
  return controller;
}

Future<void> _pumpCore(
  WidgetTester tester,
  WalletController controller, {
  required WalletUiPalette palette,
  double width = 500,
  WalletEmptyBuilder? emptyBuilder,
  WalletPickerHeaderBuilder? headerBuilder,
  VoidCallback? onClose,
  ValueChanged<Wallet>? onSelected,
  WalletTileBuilder? tileBuilder,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WalletPickerContent(
          controller: controller,
          emptyBuilder: emptyBuilder,
          headerBuilder: headerBuilder,
          onClose: onClose,
          onSelected: onSelected ?? (_) {},
          palette: palette,
          tileBuilder: tileBuilder,
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpMaterial(
  WidgetTester tester,
  WalletController controller, {
  double width = 500,
  WalletButtonBuilder? buttonBuilder,
  WalletEmptyBuilder? emptyBuilder,
  WalletPickerHeaderBuilder? headerBuilder,
  WalletTileBuilder? tileBuilder,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 700)),
        child: Scaffold(
          body: MaterialWalletButton(
            controller: controller,
            builder: buttonBuilder,
            emptyBuilder: emptyBuilder,
            headerBuilder: headerBuilder,
            tileBuilder: tileBuilder,
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpCupertino(
  WidgetTester tester,
  WalletController controller, {
  double width = 500,
  Brightness brightness = Brightness.light,
  WalletButtonBuilder? builder,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    CupertinoApp(
      theme: CupertinoThemeData(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 700)),
        child: CupertinoPageScaffold(
          child: CupertinoWalletButton(
            controller: controller,
            builder: builder,
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpSkribble(
  WidgetTester tester,
  WalletController controller, {
  double width = 500,
  WiredThemeData? theme,
  WalletButtonBuilder? builder,
  WalletEmptyBuilder? emptyBuilder,
  WalletPickerHeaderBuilder? headerBuilder,
  WalletTileBuilder? tileBuilder,
}) async {
  await tester.binding.setSurfaceSize(Size(width, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 700)),
        child: Scaffold(
          body: SkribbleWalletButton(
            controller: controller,
            theme: theme,
            builder: builder,
            emptyBuilder: emptyBuilder,
            headerBuilder: headerBuilder,
            tileBuilder: tileBuilder,
          ),
        ),
      ),
    ),
  );
}

class _PendingRegistry extends WalletRegistryController {
  final Completer<void> _completer = Completer();
  void complete() => _completer.complete();
  @override
  Future<void> initialize() => _completer.future;
}

class _Wallet implements Wallet {
  _Wallet(this.name, {this.reject = false, bool gated = false})
    : icon = WalletIcon(_svgIcon),
      account = WalletAccount(
        address: '11111111111111111111111111111111',
        publicKey: Uint8List(32),
        chains: const [SolanaChainId.localnet],
        features: const [SolanaFeatureId.signMessage],
        label: 'Primary',
      ) {
    _gate = gated ? Completer<void>() : null;
    features = {
      StandardFeatureId.connect: _Connect(this),
      StandardFeatureId.disconnect: _Disconnect(this),
    };
  }
  final WalletAccount account;
  bool disconnected = false;
  final bool reject;
  Completer<void>? _gate;
  @override
  List<WalletAccount> get accounts => [account];
  @override
  List<String> get chains => const [SolanaChainId.localnet];
  @override
  late final Map<String, WalletFeature> features;
  @override
  final WalletIcon icon;
  @override
  final String name;
  @override
  String get version => walletStandardVersion;

  /// Resolves a gated connection, as if the user approved in the wallet.
  void approveConnect() {
    if (_gate != null && !_gate!.isCompleted) _gate!.complete();
  }
}

class _Connect implements StandardConnectFeature {
  const _Connect(this.wallet);
  final _Wallet wallet;
  @override
  Future<StandardConnectOutput> connect([
    StandardConnectInput input = const StandardConnectInput(),
  ]) async {
    if (wallet.reject) throw StateError('rejected');
    final gate = wallet._gate;
    if (gate != null) await gate.future;
    return StandardConnectOutput([wallet.account]);
  }

  @override
  String get version => '1.0.0';
}

class _Disconnect implements StandardDisconnectFeature {
  const _Disconnect(this.wallet);
  final _Wallet wallet;
  @override
  Future<void> disconnect() async => wallet.disconnected = true;
  @override
  String get version => '1.0.0';
}

const _pngIcon =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
    'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';
const _svgIcon =
    'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxIDEiPjxyZWN0IHdpZHRoPSIxIiBoZWlnaHQ9IjEiLz48L3N2Zz4=';
