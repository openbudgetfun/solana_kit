import 'package:flutter/services.dart';
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart' show MobileWalletAdapterConfig;
import 'package:solana_kit_mobile_wallet_adapter/src/wallet/wallet_config.dart' show MobileWalletAdapterConfig;

/// Platform-specific API for the wallet side of MWA on Android.
///
/// This bridges to the Android `walletlib` for WebSocket server management
/// and dApp request handling.
class MwaWalletHostApi {
  MwaWalletHostApi({BinaryMessenger? binaryMessenger})
      : _channel = MethodChannel(
          'com.solana.solanakit.mobilewallet/wallet',
          const StandardMethodCodec(),
          binaryMessenger,
        );

  final MethodChannel _channel;

  /// Creates a new wallet scenario on the native side.
  ///
  /// [walletName] is the human-readable name of the wallet.
  /// [configJson] is the JSON-encoded [MobileWalletAdapterConfig].
  ///
  /// Returns a session ID string.
  Future<String> createScenario({
    required String walletName,
    required String configJson,
  }) async {
    final result = await _channel.invokeMethod<String>(
      'createScenario',
      {'walletName': walletName, 'configJson': configJson},
    );
    return result!;
  }

  /// Starts the wallet scenario, beginning to accept connections.
  Future<void> startScenario({required String sessionId}) async {
    await _channel.invokeMethod<void>(
      'startScenario',
      {'sessionId': sessionId},
    );
  }

  /// Closes the wallet scenario and stops accepting connections.
  Future<void> closeScenario({required String sessionId}) async {
    await _channel.invokeMethod<void>(
      'closeScenario',
      {'sessionId': sessionId},
    );
  }

  /// Resolves a pending request from a dApp with the given result.
  Future<void> resolveRequest({
    required String sessionId,
    required String requestId,
    required String resultJson,
  }) async {
    await _channel.invokeMethod<void>(
      'resolveRequest',
      {
        'sessionId': sessionId,
        'requestId': requestId,
        'resultJson': resultJson,
      },
    );
  }

  /// Sets the callback handler for wallet-side events from native code.
  void setMethodCallHandler(
    Future<Object?> Function(MethodCall call)? handler,
  ) {
    _channel.setMethodCallHandler(handler);
  }
}
