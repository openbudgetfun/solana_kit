import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/src/message_modifying_signer.dart';
import 'package:solana_kit_signers/src/message_partial_signer.dart';
import 'package:solana_kit_signers/src/transaction_modifying_signer.dart';
import 'package:solana_kit_signers/src/transaction_partial_signer.dart';
import 'package:solana_kit_signers/src/transaction_sending_signer.dart';

/// Gets the address from any signer type.
Address getSignerAddress(Object signer) {
  if (signer is TransactionPartialSigner) return signer.address;
  if (signer is TransactionModifyingSigner) return signer.address;
  if (signer is TransactionSendingSigner) return signer.address;
  if (signer is MessagePartialSigner) return signer.address;
  if (signer is MessageModifyingSigner) return signer.address;
  throw ArgumentError('Value is not a signer: $signer');
}

/// Removes all duplicated signers from a provided list by comparing
/// their addresses.
///
/// If two distinct signer objects share the same address, a [SolanaError]
/// with code [SolanaErrorCode.signerAddressCannotHaveMultipleSigners] is
/// thrown.
List<T> deduplicateSigners<T extends Object>(List<T> signers) {
  final deduplicated = <Address, T>{};

  for (final signer in signers) {
    final addr = getSignerAddress(signer);
    final existing = deduplicated[addr];
    if (existing == null) {
      deduplicated[addr] = signer;
    } else if (!identical(existing, signer)) {
      throw SolanaError(
        SolanaErrorCode.signerAddressCannotHaveMultipleSigners,
        {'address': addr.value},
      );
    }
  }

  return deduplicated.values.toList();
}
