import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/src/signable_message.dart';
import 'package:solana_kit_signers/src/types.dart';

/// A signer interface that signs an array of [SignableMessage]s without
/// modifying their content.
///
/// It defines a [signMessages] function that returns a signature dictionary
/// for each provided message. Such signature dictionaries are expected to
/// be merged with the existing ones if any.
///
/// Characteristics:
/// - **Parallel**. When multiple signers sign the same message, we can
///   perform this operation in parallel to obtain all their signatures.
/// - **Flexible order**. The order in which we use these signers for a
///   given message doesn't matter.
// ignore: one_member_abstracts
abstract class MessagePartialSigner {
  /// The base58-encoded address of this signer.
  Address get address;

  /// Signs the provided [messages] and returns a signature dictionary
  /// for each message.
  Future<List<Map<Address, SignatureBytes>>> signMessages(
    List<SignableMessage> messages, [
    SignerConfig? config,
  ]);
}

/// Checks whether the provided value implements the [MessagePartialSigner]
/// interface.
bool isMessagePartialSigner(Object? value) {
  return value is MessagePartialSigner;
}

/// Asserts that the provided value implements the [MessagePartialSigner]
/// interface.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedMessagePartialSigner] if the check fails.
void assertIsMessagePartialSigner(Object? value) {
  if (!isMessagePartialSigner(value)) {
    final addr = value is MessagePartialSigner ? value.address.value : '';
    throw SolanaError(SolanaErrorCode.signerExpectedMessagePartialSigner, {
      'address': addr,
    });
  }
}
