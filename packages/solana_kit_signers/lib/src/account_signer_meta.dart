import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/src/deduplicate_signers.dart';
import 'package:solana_kit_signers/src/fee_payer_signer.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// An extension of the [AccountMeta] type that allows us to store
/// transaction signers inside it.
///
/// Note that, because this type represents a signer, it must use one of
/// the following two roles:
/// - [AccountRole.readonlySigner]
/// - [AccountRole.writableSigner]
class AccountSignerMeta extends AccountMeta {
  /// Creates an [AccountSignerMeta] with the given properties.
  const AccountSignerMeta({
    required super.address,
    required super.role,
    required this.signer,
  });

  /// The transaction signer associated with this account meta.
  final Object signer;
}

/// Extracts and deduplicates all transaction signers stored inside the
/// account metas of an instruction.
///
/// Any extracted signers that share the same address will be
/// de-duplicated.
List<Object> getSignersFromInstruction(Instruction instruction) {
  final accounts = instruction.accounts;
  if (accounts == null) return [];

  final signers = <Object>[];
  for (final account in accounts) {
    if (account is AccountSignerMeta) {
      signers.add(account.signer);
    }
  }

  return deduplicateSigners(signers);
}

/// Extracts and deduplicates all transaction signers stored inside a given
/// transaction message.
///
/// This includes any signers stored as the fee payer or in the instructions
/// of the transaction message.
///
/// Any extracted signers that share the same address will be
/// de-duplicated.
List<Object> getSignersFromTransactionMessage(
  TransactionMessage transactionMessage,
) {
  final signers = <Object>[];

  // Check if the fee payer is a signer.
  if (transactionMessage is TransactionMessageWithFeePayerSigner) {
    signers.add(transactionMessage.feePayerSigner);
  }

  // Extract signers from all instructions.
  for (final instruction in transactionMessage.instructions) {
    signers.addAll(getSignersFromInstruction(instruction));
  }

  return deduplicateSigners(signers);
}
