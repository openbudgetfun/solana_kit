import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_wallet_adapter/solana_kit_wallet_adapter.dart';
import 'package:solana_kit_wallet_standard/solana_kit_wallet_standard.dart';
import 'package:solana_kit_wallet_ui/solana_kit_wallet_ui.dart';
import 'package:solana_kit_wallet_ui_example/app_keys.dart';

const _demoMode = bool.fromEnvironment('DEMO_WALLET');
const _surfpoolUrl = String.fromEnvironment(
  'SURFPOOL_URL',
  defaultValue: 'http://10.0.2.2:8899',
);

const _walletColorScheme = ColorScheme.dark(
  primary: Color(0xff8b5cf6),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xff35205f),
  onPrimaryContainer: Color(0xfff0e7ff),
  secondary: Color(0xff22d3ee),
  onSecondary: Color(0xff041519),
  secondaryContainer: Color(0xff123844),
  onSecondaryContainer: Color(0xffcffafe),
  tertiary: Color(0xfff472b6),
  onTertiary: Color(0xff2f071f),
  error: Color(0xfffb7185),
  onError: Color(0xff30070e),
  surface: Color(0xff111629),
  onSurface: Color(0xfff8fafc),
  onSurfaceVariant: Color(0xffb6bfd6),
  outline: Color(0xff687391),
  outlineVariant: Color(0xff303a57),
  shadow: Color(0xff03040a),
  scrim: Color(0xff03040a),
);

const _canvas = Color(0xff070a14);
const _canvasHighlight = Color(0xff11132d);

/// Runs the wallet UI example.
void main() => runApp(const WalletExampleApp());

/// Interactive example used by browser, device, and Patrol verification.
///
/// [demoMode] guarantees the deterministic demo wallet, which is how the docs
/// site embeds the example (`DEMO_WALLET=true`). On the web, demo mode also
/// lists detected Wallet Standard wallets so the embedded demo surfaces the
/// visitor's installed wallets, mirroring the wallet adapter examples.
class WalletExampleApp extends StatefulWidget {
  /// Creates the example application.
  ///
  /// Defaults to the compile-time `DEMO_WALLET` environment switch.
  const WalletExampleApp({super.key, this.demoMode = _demoMode});

  /// Whether the wallet registry uses the deterministic demo wallet.
  final bool demoMode;

  @override
  State<WalletExampleApp> createState() => _WalletExampleAppState();
}

class _WalletExampleAppState extends State<WalletExampleApp> {
  late final WalletController _controller;
  String _signatureStatus = 'Connect a wallet to sign a message.';
  String _surfpoolStatus = 'Surfpool has not been checked.';

  @override
  void initState() {
    super.initState();
    final registry = widget.demoMode
        ? _demoRegistry()
        : createDefaultWalletRegistry(
            appIdentity: const WalletAppIdentity(name: 'Solana Kit wallet UI'),
            chain: SolanaChainId.localnet,
          );
    _controller = WalletController(registry, chain: SolanaChainId.localnet);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: _walletColorScheme,
        scaffoldBackgroundColor: _canvas,
        textTheme: Typography.whiteCupertino,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: Color(0xff465171)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_canvas, _canvasHighlight, _canvas],
              stops: [0, 0.5, 1],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 820;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Padding(
                      padding: EdgeInsets.all(wide ? 40 : 20),
                      child: wide
                          ? Row(
                              children: [
                                const Expanded(child: _Introduction()),
                                const SizedBox(width: 48),
                                Expanded(
                                  child: _Actions(
                                    controller: _controller,
                                    onSign: _signMessage,
                                    onSurfpool: _checkSurfpool,
                                    signatureStatus: _signatureStatus,
                                    surfpoolStatus: _surfpoolStatus,
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              children: [
                                const _Introduction(),
                                const SizedBox(height: 28),
                                _Actions(
                                  controller: _controller,
                                  onSign: _signMessage,
                                  onSurfpool: _checkSurfpool,
                                  signatureStatus: _signatureStatus,
                                  surfpoolStatus: _surfpoolStatus,
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkSurfpool() async {
    setState(() => _surfpoolStatus = 'Checking Surfpool…');
    try {
      final rpc = createSolanaRpc(url: _surfpoolUrl, allowInsecureHttp: true);
      await rpc.getSlot().send();
      if (mounted) {
        setState(() => _surfpoolStatus = 'Surfpool ready');
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _surfpoolStatus = 'Surfpool unavailable · $error');
      }
    }
  }

  Future<void> _signMessage() async {
    final wallet = _controller.state.selectedWallet;
    final account = _controller.state.selectedAccount;
    if (wallet == null || account == null) return;
    final feature = wallet.feature<SolanaSignMessageFeature>(
      SolanaFeatureId.signMessage,
    );
    if (feature == null) {
      setState(() => _signatureStatus = 'This wallet cannot sign messages.');
      return;
    }
    final output = await feature.signMessage([
      SolanaSignMessageInput(
        account: account,
        message: Uint8List.fromList(utf8.encode('Hello from Solana Kit')),
      ),
    ]);
    if (mounted) {
      setState(
        () => _signatureStatus =
            'Signed · ${output.single.signature.length} bytes',
      );
    }
  }
}

class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SOLANA KIT',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'A wallet surface that feels at home.',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            height: 1.02,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Wallet Standard on the web. Mobile Wallet Adapter on Android. Material, Cupertino, adaptive, or entirely yours.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 17,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.controller,
    required this.onSign,
    required this.onSurfpool,
    required this.signatureStatus,
    required this.surfpoolStatus,
  });
  final WalletController controller;
  final VoidCallback onSign;
  final VoidCallback onSurfpool;
  final String signatureStatus;
  final String surfpoolStatus;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
            blurRadius: 44,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdaptiveWalletButton(controller: controller),
            const SizedBox(height: 14),
            FilledButton.tonal(
              key: AppKeys.checkSurfpool,
              onPressed: onSurfpool,
              child: const Text('Check Surfpool'),
            ),
            const SizedBox(height: 14),
            ListenableBuilder(
              listenable: controller,
              builder: (context, child) => OutlinedButton(
                key: AppKeys.signMessage,
                onPressed: controller.state.isConnected ? onSign : null,
                child: const Text('Sign message'),
              ),
            ),
            const SizedBox(height: 20),
            Text(surfpoolStatus, key: AppKeys.surfpoolStatus),
            const SizedBox(height: 8),
            Text(signatureStatus, key: AppKeys.signedMessageStatus),
          ],
        ),
      ),
    );
  }
}

/// The registry used when the example is built for testing or embedding.
///
/// On the web the demo also lists detected Wallet Standard wallets so the
/// embedded docs demo surfaces the visitor's installed wallets, mirroring the
/// wallet adapter examples. On other platforms only the deterministic demo
/// wallet is available, which keeps device and Patrol tests predictable.
WalletRegistry _demoRegistry() {
  if (kIsWeb) {
    return createDefaultWalletRegistry(
      appIdentity: const WalletAppIdentity(name: 'Solana Kit wallet UI'),
      chain: SolanaChainId.localnet,
      additionalWallets: [DemoWallet()],
    );
  }
  return DemoWalletRegistry();
}

/// Deterministic registry used only when the example is built for testing.
class DemoWalletRegistry extends WalletRegistryController {
  @override
  Future<void> initialize() async => register(DemoWallet());
}

/// A deterministic Wallet Standard wallet used when the example is built for
/// testing and by the embedded docs demo.
class DemoWallet implements Wallet {
  /// Creates a deterministic demo wallet.
  DemoWallet() : icon = WalletIcon(_demoIcon) {
    account = WalletAccount(
      address: '11111111111111111111111111111111',
      publicKey: Uint8List(32),
      chains: const [SolanaChainId.localnet],
      features: const [SolanaFeatureId.signMessage],
      label: 'Surfpool demo',
    );
    features = {
      StandardFeatureId.connect: _DemoConnect(this),
      StandardFeatureId.disconnect: const _DemoDisconnect(),
      SolanaFeatureId.signMessage: const _DemoSignMessage(),
    };
  }

  /// The demo account authorized during connection.
  late final WalletAccount account;
  List<WalletAccount> _accounts = const [];
  @override
  List<WalletAccount> get accounts => _accounts;
  @override
  List<String> get chains => const [SolanaChainId.localnet];
  @override
  late final Map<String, WalletFeature> features;
  @override
  final WalletIcon icon;
  @override
  String get name => 'Surfpool demo wallet';
  @override
  String get version => walletStandardVersion;
}

class _DemoConnect implements StandardConnectFeature {
  const _DemoConnect(this.wallet);
  final DemoWallet wallet;
  @override
  Future<StandardConnectOutput> connect([
    StandardConnectInput input = const StandardConnectInput(),
  ]) async {
    wallet._accounts = [wallet.account];
    return StandardConnectOutput(wallet.accounts);
  }

  @override
  String get version => '1.0.0';
}

class _DemoDisconnect implements StandardDisconnectFeature {
  const _DemoDisconnect();
  @override
  Future<void> disconnect() async {}
  @override
  String get version => '1.0.0';
}

class _DemoSignMessage implements SolanaSignMessageFeature {
  const _DemoSignMessage();
  @override
  Future<List<SolanaSignMessageOutput>> signMessage(
    List<SolanaSignMessageInput> inputs,
  ) async => inputs
      .map(
        (input) => SolanaSignMessageOutput(
          signedMessage: input.message,
          signature: Uint8List(64)..fillRange(0, 64, 7),
          signatureType: 'ed25519',
        ),
      )
      .toList();
  @override
  String get version => '1.0.0';
}

const _demoIcon =
    'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA2NCA2NCI+PHJlY3Qgd2lkdGg9IjY0IiBoZWlnaHQ9IjY0IiByeD0iMTYiIGZpbGw9IiM4YjVjZjYiLz48cGF0aCBkPSJNMTYgMjBoMzJsLTEwIDEwSDZ6bTMyIDI0SDE2bDEwLTEwaDMyeiIgZmlsbD0iIzIyZDNlZSIvPjwvc3ZnPg==';
