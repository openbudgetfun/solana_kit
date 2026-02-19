import 'dart:math';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/constants.dart';

/// Returns a random port in the dynamic/private port range (49152-65535)
/// as defined by RFC 6335.
int getRandomAssociationPort() {
  final random = Random.secure();
  return mwaMinAssociationPort +
      random.nextInt(mwaMaxAssociationPort - mwaMinAssociationPort + 1);
}

/// Validates that [port] is within the allowed association port range
/// (49152-65535).
///
/// Returns [port] if valid, otherwise throws a [SolanaError] with code
/// [SolanaErrorCode.mwaAssociationPortOutOfRange].
int assertAssociationPort(int port) {
  if (port < mwaMinAssociationPort || port > mwaMaxAssociationPort) {
    throw SolanaError(
      SolanaErrorCode.mwaAssociationPortOutOfRange,
      {'port': port},
    );
  }
  return port;
}
