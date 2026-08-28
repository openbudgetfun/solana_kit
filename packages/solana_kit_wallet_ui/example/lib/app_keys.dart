import 'package:flutter/widgets.dart';

/// Stable keys used by the example's integration tests.
abstract final class AppKeys {
  /// Surfpool connectivity action.
  static const checkSurfpool = Key('example.check_surfpool');

  /// Message signing action.
  static const signMessage = Key('example.sign_message');

  /// Current signed-message result.
  static const signedMessageStatus = Key('example.signed_message_status');

  /// Current Surfpool result.
  static const surfpoolStatus = Key('example.surfpool_status');
}
