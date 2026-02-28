import 'package:flutter_test/flutter_test.dart';
import 'package:solana_kit_mobile_wallet_adapter_example/main.dart';

void main() {
  testWidgets('renders manual test app shell', (tester) async {
    await tester.pumpWidget(const ManualMwaExampleApp());

    expect(find.text('Solana Kit MWA Manual Test'), findsOneWidget);
    expect(find.text('Authorize'), findsOneWidget);
  });
}
