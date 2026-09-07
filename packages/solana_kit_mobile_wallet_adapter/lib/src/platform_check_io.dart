import 'dart:io';

import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Returns `true` if the Mobile Wallet Adapter protocol is supported on the
/// current platform (Android only).
bool isMwaSupported() => Platform.isAndroid;

/// How long the association flow keeps retrying the wallet's WebSocket
/// server. Native sessions fail fast (the wallet app is foreground by the
/// time the sheet appears).
/// How long the association flow keeps retrying the wallet's WebSocket
/// server before timing out.
const Duration mwaConnectionDeadline = Duration(milliseconds: 30000);

/// Throws a [SolanaError] with code [SolanaErrorCode.mwaPlatformNotSupported]
/// if MWA is not supported on the current platform.
void assertMwaSupported() {
  if (!isMwaSupported()) {
    throw SolanaError(SolanaErrorCode.mwaPlatformNotSupported);
  }
}
