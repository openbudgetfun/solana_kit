import 'dart:async';

import 'package:solana_kit_mobile_wallet_adapter/src/kit_mobile_wallet.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/local_association_scenario.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/pigeon/client_api.dart';
import 'package:solana_kit_mobile_wallet_adapter/src/platform_check.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/solana_kit_mobile_wallet_adapter_protocol.dart';

/// Executes a callback within an MWA session, handling the full lifecycle.
///
/// 1. Verifies MWA is supported on the current platform (Android)
/// 2. Creates a [LocalAssociationScenario]
/// 3. Launches the wallet app
/// 4. Performs the handshake and establishes the encrypted session
/// 5. Calls [callback] with a [KitMobileWallet] proxy
/// 6. Cleans up the session
///
/// Example:
/// ```dart
/// final result = await transact((wallet) async {
///   final auth = await wallet.authorize(
///     identity: AppIdentity(name: 'My dApp'),
///     chain: 'solana:mainnet',
///   );
///   return auth;
/// });
/// ```
Future<T> transact<T>(
  Future<T> Function(KitMobileWallet wallet) callback, {
  WalletAssociationConfig? config,
  MwaClientHostApi? clientApi,
}) async {
  assertMwaSupported();

  final scenario = LocalAssociationScenario(
    clientApi: clientApi,
    baseUri: config?.baseUri,
  );

  try {
    final wallet = await scenario.start();
    final kitWallet = wrapWithKitApi(wallet);
    return await callback(kitWallet);
  } finally {
    await scenario.close();
  }
}
