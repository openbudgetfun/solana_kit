import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:web/web.dart' as web;

/// Returns `true` on web when the page runs in a secure context, which is
/// required for the Mobile Wallet Adapter localhost WebSocket transport.
///
/// Secure contexts include HTTPS pages and `http://localhost`, so browsers on
/// mobile devices qualify when served appropriately.
bool isMwaSupported() {
  if (!const bool.fromEnvironment('dart.library.js_interop')) {
    return false;
  }
  return web.window.isSecureContext;
}

/// Throws a [SolanaError] with code [SolanaErrorCode.mwaPlatformNotSupported]
/// if MWA is not supported on the current platform.
void assertMwaSupported() {
  if (!isMwaSupported()) {
    throw SolanaError(SolanaErrorCode.mwaPlatformNotSupported);
  }
}
