import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter_example/main.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

void main() {
  testWidgets('shows unsupported platform fallback UX', (tester) async {
    final controller = MwaExampleController(
      platformService: const _FakePlatformSupportService(
        isSupported: false,
        walletEndpointAvailable: false,
      ),
      sessionService: _FakeSessionService(),
    );

    await tester.pumpWidget(SolanaKitMwaExampleApp(controller: controller));
    await tester.pumpAndSettle();

    expect(
      find.text('Mobile Wallet Adapter is unavailable on this platform'),
      findsOneWidget,
    );
    expect(find.text('Recommended iOS fallback UX:'), findsOneWidget);
    expect(find.text('Authorize'), findsNothing);
  });

  testWidgets('renders supported Android-first sections', (tester) async {
    final controller = MwaExampleController(
      platformService: const _FakePlatformSupportService(
        isSupported: true,
        walletEndpointAvailable: true,
      ),
      sessionService: _FakeSessionService(),
    );

    await tester.pumpWidget(SolanaKitMwaExampleApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Android-first Flutter example app'), findsOneWidget);
    expect(find.text('Platform support gate'), findsOneWidget);
    expect(find.text('Refresh Wallet Status'), findsOneWidget);
    expect(find.text('Authorize'), findsOneWidget);
  });
}

class _FakePlatformSupportService implements MwaPlatformSupportService {
  const _FakePlatformSupportService({
    required this.isSupported,
    required this.walletEndpointAvailable,
  });

  @override
  final bool isSupported;

  final bool walletEndpointAvailable;

  @override
  Future<bool> isWalletEndpointAvailable() async => walletEndpointAvailable;
}

class _FakeSessionService implements MwaSessionService {
  @override
  Future<AuthorizationResult> authorize() async =>
      throw UnimplementedError('Not used in widget shell tests.');

  @override
  Future<void> deauthorize(String authToken) async =>
      throw UnimplementedError('Not used in widget shell tests.');

  @override
  Future<(AuthorizationResult, WalletCapabilities)> loadCapabilities(
    String authToken,
  ) async => throw UnimplementedError('Not used in widget shell tests.');

  @override
  Future<(AuthorizationResult, List<String>)> signAndSendTransactions({
    required String authToken,
    required List<String> payloads,
  }) async => throw UnimplementedError('Not used in widget shell tests.');

  @override
  Future<(AuthorizationResult, List<String>)> signMessage({
    required String authToken,
    required String message,
  }) async => throw UnimplementedError('Not used in widget shell tests.');
}
