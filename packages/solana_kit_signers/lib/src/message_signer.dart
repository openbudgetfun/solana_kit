import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_signers/src/message_modifying_signer.dart';
import 'package:solana_kit_signers/src/message_partial_signer.dart';
import 'package:solana_kit_signers/src/transaction_modifying_signer.dart';
import 'package:solana_kit_signers/src/transaction_partial_signer.dart';
import 'package:solana_kit_signers/src/transaction_sending_signer.dart';

/// Checks whether the provided value implements either the
/// [MessagePartialSigner] or [MessageModifyingSigner] interface.
bool isMessageSigner(Object? value) {
  return isMessagePartialSigner(value) || isMessageModifyingSigner(value);
}

/// Asserts that the provided value implements either the
/// [MessagePartialSigner] or [MessageModifyingSigner] interface.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedMessageSigner] if the check fails.
void assertIsMessageSigner(Object? value) {
  if (!isMessageSigner(value)) {
    final address = switch (value) {
      MessagePartialSigner(:final address) => address,
      MessageModifyingSigner(:final address) => address,
      TransactionPartialSigner(:final address) => address,
      TransactionModifyingSigner(:final address) => address,
      TransactionSendingSigner(:final address) => address,
      _ => null,
    };
    throw SolanaError(SolanaErrorCode.signerExpectedMessageSigner, {
      if (address != null) 'address': address,
    });
  }
}
