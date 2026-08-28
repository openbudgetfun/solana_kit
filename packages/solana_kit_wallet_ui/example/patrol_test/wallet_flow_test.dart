import 'package:patrol/patrol.dart';
import 'package:solana_kit_wallet_ui/solana_kit_wallet_ui.dart';
import 'package:solana_kit_wallet_ui_example/app_keys.dart';
import 'package:solana_kit_wallet_ui_example/main.dart';

void main() {
  patrolTest('connects, signs, and reaches Surfpool', ($) async {
    await $.pumpWidgetAndSettle(const WalletExampleApp());

    await $(WalletUiKeys.connectButton).tap();
    await $(WalletUiKeys.walletTile(0)).tap();
    await $(AppKeys.signMessage).tap();
    await $(AppKeys.checkSurfpool).tap();

    await $('Signed · 64 bytes').waitUntilVisible();
    await $('Surfpool ready').waitUntilVisible();
  });
}
