import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_wallet_ui/solana_kit_wallet_ui.dart';
import 'package:solana_kit_wallet_ui_example/app_keys.dart';
import 'package:solana_kit_wallet_ui_example/main.dart';

void main() {
  testWidgets('demo mode renders the wallet surface and signs a message', (
    tester,
  ) async {
    await tester.pumpWidget(const WalletExampleApp(demoMode: true));
    await tester.pumpAndSettle();

    expect(find.text('SOLANA KIT'), findsOneWidget);
    expect(find.text('A wallet surface that feels at home.'), findsOneWidget);
    expect(find.text('Connect a wallet to sign a message.'), findsOneWidget);
    expect(find.text('Surfpool has not been checked.'), findsOneWidget);

    // Connect the deterministic demo wallet through the adaptive button.
    await tester.tap(find.byType(AdaptiveWalletButton));
    await tester.pumpAndSettle();
    expect(find.byKey(WalletUiKeys.picker), findsOneWidget);
    expect(find.text('Surfpool demo wallet'), findsOneWidget);

    await tester.tap(find.byKey(WalletUiKeys.walletTile(0)));
    await tester.pumpAndSettle();

    // Signing flows through the demo wallet's signMessage feature.
    await tester.tap(find.byKey(AppKeys.signMessage));
    await tester.pumpAndSettle();
    expect(find.text('Signed · 64 bytes'), findsOneWidget);
  });
}
