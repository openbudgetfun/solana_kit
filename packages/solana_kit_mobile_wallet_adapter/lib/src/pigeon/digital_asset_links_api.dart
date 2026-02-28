import 'package:flutter/services.dart';

/// Platform API for Android Digital Asset Links verification.
///
/// On non-Android platforms these methods return null/false defaults.
class MwaDigitalAssetLinksHostApi {
  MwaDigitalAssetLinksHostApi({BinaryMessenger? binaryMessenger})
    : _channel = MethodChannel(
        'com.solana.solanakit.mobilewallet/digital_asset_links',
        const StandardMethodCodec(),
        binaryMessenger,
      );

  final MethodChannel _channel;

  /// Returns the package name of the calling app, if available.
  Future<String?> getCallingPackage() async {
    return _channel.invokeMethod<String>('getCallingPackage');
  }

  /// Verifies the calling package against [clientIdentityUri].
  Future<bool> verifyCallingPackage({required String clientIdentityUri}) async {
    final result = await _channel.invokeMethod<bool>('verifyCallingPackage', {
      'clientIdentityUri': clientIdentityUri,
    });
    return result ?? false;
  }

  /// Verifies [packageName] against [clientIdentityUri].
  Future<bool> verifyPackage({
    required String packageName,
    required String clientIdentityUri,
  }) async {
    final result = await _channel.invokeMethod<bool>('verifyPackage', {
      'packageName': packageName,
      'clientIdentityUri': clientIdentityUri,
    });
    return result ?? false;
  }

  /// Returns the UID of the calling package.
  Future<int?> getCallingPackageUid() {
    return _channel.invokeMethod<int>('getCallingPackageUid');
  }

  /// Returns the UID for [packageName].
  Future<int?> getUidForPackage({required String packageName}) {
    return _channel.invokeMethod<int>('getUidForPackage', {
      'packageName': packageName,
    });
  }
}
