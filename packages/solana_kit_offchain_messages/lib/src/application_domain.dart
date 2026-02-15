import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// A 32-byte application domain identifying the application requesting
/// off-chain message signing.
///
/// This is represented as a base58-encoded string that decodes to exactly
/// 32 bytes (same format as a Solana address).
typedef OffchainMessageApplicationDomain = Address;

/// Returns `true` if [putativeApplicationDomain] is a valid offchain message
/// application domain.
bool isOffchainMessageApplicationDomain(String putativeApplicationDomain) {
  return isAddress(putativeApplicationDomain);
}

/// Asserts that [putativeApplicationDomain] is a valid offchain message
/// application domain.
///
/// Throws a [SolanaError] with offchain-message-specific error codes for
/// invalid string lengths or byte lengths.
void assertIsOffchainMessageApplicationDomain(
  String putativeApplicationDomain,
) {
  try {
    assertIsAddress(putativeApplicationDomain);
  } on SolanaError catch (error) {
    if (isSolanaError(error, SolanaErrorCode.addressesStringLengthOutOfRange)) {
      throw SolanaError(
        SolanaErrorCode.offchainMessageApplicationDomainStringLengthOutOfRange,
        error.context,
      );
    }
    if (isSolanaError(error, SolanaErrorCode.addressesInvalidByteLength)) {
      throw SolanaError(
        SolanaErrorCode.offchainMessageInvalidApplicationDomainByteLength,
        error.context,
      );
    }
    rethrow;
  }
}

/// Asserts that [putativeApplicationDomain] is a valid application domain and
/// returns it as an [OffchainMessageApplicationDomain].
OffchainMessageApplicationDomain offchainMessageApplicationDomain(
  String putativeApplicationDomain,
) {
  assertIsOffchainMessageApplicationDomain(putativeApplicationDomain);
  return Address(putativeApplicationDomain);
}
