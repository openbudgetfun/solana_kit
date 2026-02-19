import 'dart:io';

import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Returns `true` if the Mobile Wallet Adapter protocol is supported on the
/// current platform (Android only).
bool isMwaSupported() => Platform.isAndroid;

/// Throws a [SolanaError] with code [SolanaErrorCode.mwaPlatformNotSupported]
/// if MWA is not supported on the current platform.
void assertMwaSupported() {
  if (!isMwaSupported()) {
    throw SolanaError(SolanaErrorCode.mwaPlatformNotSupported);
  }
}
