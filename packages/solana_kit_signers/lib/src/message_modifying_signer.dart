import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/src/signable_message.dart';
import 'package:solana_kit_signers/src/types.dart';

/// A signer interface that _potentially_ modifies the content of the
/// provided [SignableMessage]s before signing them.
///
/// For instance, this enables wallets to prefix or suffix nonces to the
/// messages they sign. For each message, instead of returning a signature
/// dictionary, the [modifyAndSignMessages] function returns an updated
/// [SignableMessage] with a potentially modified content and signature
/// dictionary.
///
/// Characteristics:
/// - **Sequential**. Contrary to partial signers, these cannot be executed
///   in parallel as each call can modify the content of the message.
/// - **First signers**. For a given message, a modifying signer must always
///   be used before a partial signer.
/// - **Potential conflicts**. If more than one modifying signer is provided,
///   the second signer may invalidate the signature of the first one.
// ignore: one_member_abstracts
abstract class MessageModifyingSigner {
  /// The base58-encoded address of this signer.
  Address get address;

  /// Potentially modifies the provided [messages] before signing them and
  /// returns the updated [SignableMessage]s.
  Future<List<SignableMessage>> modifyAndSignMessages(
    List<SignableMessage> messages, [
    SignerConfig? config,
  ]);
}

/// Checks whether the provided value implements the
/// [MessageModifyingSigner] interface.
bool isMessageModifyingSigner(Object? value) {
  return value is MessageModifyingSigner;
}

/// Asserts that the provided value implements the
/// [MessageModifyingSigner] interface.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedMessageModifyingSigner] if the check
/// fails.
void assertIsMessageModifyingSigner(Object? value) {
  if (!isMessageModifyingSigner(value)) {
    final addr = value is MessageModifyingSigner ? value.address.value : '';
    throw SolanaError(SolanaErrorCode.signerExpectedMessageModifyingSigner, {
      'address': addr,
    });
  }
}
