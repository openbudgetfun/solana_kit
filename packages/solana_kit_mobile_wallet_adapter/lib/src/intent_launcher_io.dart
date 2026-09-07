import 'package:solana_kit_mobile_wallet_adapter/src/pigeon/client_api.dart';

/// Launches the wallet app through the native Android plugin.
Future<void> launchWalletIntent(Uri intentUri) {
  return MwaClientHostApi().launchIntent(intentUri.toString());
}
