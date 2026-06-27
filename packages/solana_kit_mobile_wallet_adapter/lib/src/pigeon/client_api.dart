import 'package:flutter/services.dart';

/// Platform-specific API for launching wallet intents on Android.
///
/// On iOS, all methods are no-ops that return safe default values.
class MwaClientHostApi {
  MwaClientHostApi({BinaryMessenger? binaryMessenger})
    : _channel = MethodChannel(
        'com.solana.solanakit.mobilewallet/client',
        const StandardMethodCodec(),
        binaryMessenger,
      );

  final MethodChannel _channel;

  /// Launches a wallet app by sending an Android Intent with the given [uri].
  ///
  /// On iOS, this is a no-op.
  Future<void> launchIntent(String uri) async {
    await _channel.invokeMethod<void>('launchIntent', {'uri': uri});
  }

  /// Checks if any wallet app capable of handling MWA intents is installed.
  ///
  /// Returns `true` on Android if a compatible wallet is found, `false`
  /// otherwise. Always returns `false` on iOS.
  Future<bool> isWalletEndpointAvailable() async {
    final result = await _channel.invokeMethod<bool>(
      'isWalletEndpointAvailable',
    );
    return result ?? false;
  }
}
