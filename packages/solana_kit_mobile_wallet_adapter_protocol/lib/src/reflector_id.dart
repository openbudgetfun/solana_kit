import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/constants.dart';

/// Validates that [id] is within the allowed reflector ID range
/// (0 to 2^53 - 1).
///
/// Returns [id] if valid, otherwise throws a [SolanaError] with code
/// [SolanaErrorCode.mwaReflectorIdOutOfRange].
int assertReflectorId(int id) {
  if (id < 0 || id > mwaMaxReflectorId) {
    throw SolanaError(SolanaErrorCode.mwaReflectorIdOutOfRange, {'id': id});
  }
  return id;
}
