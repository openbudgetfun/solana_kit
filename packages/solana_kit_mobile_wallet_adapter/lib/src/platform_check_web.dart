import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:web/web.dart' as web;

/// Returns `true` on web when the page runs in a secure context, which is
/// required for the Mobile Wallet Adapter localhost WebSocket transport.
///
/// Secure contexts include HTTPS pages and `http://localhost`, so browsers on
/// mobile devices qualify when served appropriately.
/// How long the association flow keeps retrying the wallet's WebSocket
/// server. On web the pairing sheet can appear before the wallet app is
/// foreground (Chrome keeps the tab alive in the background), so the retry
/// window is extended — the session establishes as soon as the wallet
/// activity resumes.
/// How long the association flow keeps retrying the wallet's WebSocket
/// server before timing out. Extended on web: the pairing sheet can appear
/// before the wallet activity is foreground, so the session establishes as
/// soon as the wallet app resumes.
const Duration mwaConnectionDeadline = Duration(minutes: 3);

/// Returns `true` on web when the page runs in a secure context, which is
/// required for the Mobile Wallet Adapter localhost WebSocket transport.
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
