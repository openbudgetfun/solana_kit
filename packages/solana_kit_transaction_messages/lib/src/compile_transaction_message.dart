import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_transaction_messages/src/compile_accounts.dart';
import 'package:solana_kit_transaction_messages/src/compile_address_table_lookups.dart';
import 'package:solana_kit_transaction_messages/src/compile_header.dart';
import 'package:solana_kit_transaction_messages/src/compile_instructions.dart';
import 'package:solana_kit_transaction_messages/src/compile_lifetime_token.dart';
import 'package:solana_kit_transaction_messages/src/compile_static_accounts.dart';
import 'package:solana_kit_transaction_messages/src/compiled_transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message_limits.dart';
import 'package:solana_kit_transaction_messages/src/v1_transaction_config.dart';

/// Converts a [TransactionMessage] into a [CompiledTransactionMessage]
/// suitable for encoding and execution on the network.
///
/// The transaction message must have a fee payer set.
///
/// This is a lossy process; you cannot fully reconstruct a source message
/// from a compiled message without extra information.
CompiledTransactionMessage compileTransactionMessage(
  TransactionMessage transactionMessage,
) {
  if (transactionMessage.feePayer == null) {
    throw SolanaError(SolanaErrorCode.transactionFeePayerMissing);
  }

  final orderedAccounts = getOrderedAccountsFromInstructions(
    transactionMessage.feePayer,
    transactionMessage.instructions,
  );
  assertTransactionMessageIsWithinLimits(
    transactionMessage,
    orderedAccounts: orderedAccounts,
  );
  final lifetimeConstraint = transactionMessage.lifetimeConstraint;
  final lifetimeToken = lifetimeConstraint != null
      ? getCompiledLifetimeToken(lifetimeConstraint)
      : null;

  if (transactionMessage.version == TransactionVersion.v1) {
    final accountIndex = getAccountIndex(orderedAccounts);
    return CompiledTransactionMessage(
      version: TransactionVersion.v1,
      header: getCompiledMessageHeader(orderedAccounts),
      staticAccounts: orderedAccounts
          .map((account) => account.address)
          .toList(),
      lifetimeToken: lifetimeToken,
      instructions: const [],
      configMask: getTransactionConfigMask(transactionMessage.config),
      configValues: getTransactionConfigValues(transactionMessage.config),
      instructionHeaders: transactionMessage.instructions
          .map((instruction) => getInstructionHeader(instruction, accountIndex))
          .toList(),
      instructionPayloads: transactionMessage.instructions
          .map(
            (instruction) => getInstructionPayload(instruction, accountIndex),
          )
          .toList(),
      numInstructions: transactionMessage.instructions.length,
      numStaticAccounts: orderedAccounts.length,
    );
  }

  return CompiledTransactionMessage(
    version: transactionMessage.version,
    header: getCompiledMessageHeader(orderedAccounts),
    staticAccounts: getCompiledStaticAccounts(orderedAccounts),
    lifetimeToken: lifetimeToken,
    instructions: getCompiledInstructions(
      transactionMessage.instructions,
      orderedAccounts,
    ),
    addressTableLookups: transactionMessage.version != TransactionVersion.legacy
        ? getCompiledAddressTableLookups(orderedAccounts)
        : null,
  );
}
