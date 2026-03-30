import 'package:flutter/material.dart';
import 'package:solana_kit_mobile_wallet_adapter_example/src/example_app.dart';

export 'src/example_app.dart';
export 'src/example_controller.dart';
export 'src/example_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SolanaKitMwaExampleApp());
}
