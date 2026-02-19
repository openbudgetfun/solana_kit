import Flutter
import UIKit

/// No-op plugin for iOS. MWA is only supported on Android.
public class SolanaKitMobileWalletAdapterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // No-op on iOS. MWA is Android-only.
    }
}
