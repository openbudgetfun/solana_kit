import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_signers/src/transaction_signer.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// A [TransactionMessage] that uses a transaction signer as the fee payer.
///
/// This is an alternative to setting the fee payer as just an address.
/// It stores the signer object alongside the transaction message so that
/// the signer can be extracted later when signing the transaction.
class TransactionMessageWithFeePayerSigner extends TransactionMessage {
  /// Creates a [TransactionMessageWithFeePayerSigner].
  TransactionMessageWithFeePayerSigner({
    required this.feePayerSigner,
    required super.version,
    super.instructions,
    super.lifetimeConstraint,
  }) : super(feePayer: getTransactionSignerAddress(feePayerSigner));

  /// The transaction signer to use as the fee payer.
  final Object feePayerSigner;

  @override
  TransactionMessage copyWith({
    TransactionVersion? version,
    List<Instruction>? instructions,
    Address? feePayer,
    bool clearFeePayer = false,
    LifetimeConstraint? lifetimeConstraint,
    bool clearLifetimeConstraint = false,
  }) {
    // If clearing the fee payer, fall back to the base TransactionMessage.
    if (clearFeePayer) {
      return TransactionMessage(
        version: version ?? this.version,
        instructions: instructions ?? this.instructions,
        lifetimeConstraint: clearLifetimeConstraint
            ? null
            : (lifetimeConstraint ?? this.lifetimeConstraint),
      );
    }

    return TransactionMessageWithFeePayerSigner(
      feePayerSigner: feePayerSigner,
      version: version ?? this.version,
      instructions: instructions ?? this.instructions,
      lifetimeConstraint: clearLifetimeConstraint
          ? null
          : (lifetimeConstraint ?? this.lifetimeConstraint),
    );
  }
}

/// Sets the fee payer of a transaction message using a transaction signer.
///
/// ```dart
/// final feePayer = await generateKeyPairSigner();
/// final transactionMessage = setTransactionMessageFeePayerSigner(
///   feePayer,
///   createTransactionMessage(version: TransactionVersion.v0),
/// );
/// ```
TransactionMessageWithFeePayerSigner setTransactionMessageFeePayerSigner(
  Object feePayer,
  TransactionMessage transactionMessage,
) {
  return TransactionMessageWithFeePayerSigner(
    feePayerSigner: feePayer,
    version: transactionMessage.version,
    instructions: transactionMessage.instructions,
    lifetimeConstraint: transactionMessage.lifetimeConstraint,
  );
}
