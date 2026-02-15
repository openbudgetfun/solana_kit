import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

import 'package:solana_kit_transactions/src/transaction.dart';

/// A lifetime constraint based on the age of a blockhash observed on the
/// network.
///
/// The transaction will continue to be eligible to land until the network
/// considers the [blockhash] to be expired.
@immutable
class TransactionBlockhashLifetime {
  /// Creates a [TransactionBlockhashLifetime].
  const TransactionBlockhashLifetime({
    required this.blockhash,
    required this.lastValidBlockHeight,
  });

  /// A recent blockhash observed by the transaction proposer.
  final String blockhash;

  /// The block height beyond which the network will consider the blockhash
  /// to be too old to make a transaction eligible to land.
  final BigInt lastValidBlockHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionBlockhashLifetime &&
          blockhash == other.blockhash &&
          lastValidBlockHeight == other.lastValidBlockHeight;

  @override
  int get hashCode => Object.hash(blockhash, lastValidBlockHeight);

  @override
  String toString() =>
      'TransactionBlockhashLifetime(blockhash: $blockhash, '
      'lastValidBlockHeight: $lastValidBlockHeight)';
}

/// A lifetime constraint based on a durable nonce.
///
/// The transaction will continue to be eligible to land until the network
/// considers the [nonce] to have advanced.
@immutable
class TransactionDurableNonceLifetime {
  /// Creates a [TransactionDurableNonceLifetime].
  const TransactionDurableNonceLifetime({
    required this.nonce,
    required this.nonceAccountAddress,
  });

  /// A value contained in the account with address [nonceAccountAddress]
  /// at the time the transaction was prepared.
  final String nonce;

  /// The account that contains the [nonce] value.
  final Address nonceAccountAddress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionDurableNonceLifetime &&
          nonce == other.nonce &&
          nonceAccountAddress == other.nonceAccountAddress;

  @override
  int get hashCode => Object.hash(nonce, nonceAccountAddress);

  @override
  String toString() =>
      'TransactionDurableNonceLifetime(nonce: $nonce, '
      'nonceAccountAddress: $nonceAccountAddress)';
}

/// The lifetime constraint for a transaction.
///
/// This is a sealed class with two subtypes:
/// - [TransactionBlockhashLifetime]
/// - [TransactionDurableNonceLifetime]
typedef TransactionLifetimeConstraint = Object;

/// A transaction that has a lifetime constraint attached.
class TransactionWithLifetime extends Transaction {
  /// Creates a [TransactionWithLifetime].
  TransactionWithLifetime({
    required super.messageBytes,
    required super.signatures,
    required this.lifetimeConstraint,
  });

  /// The lifetime constraint for this transaction.
  final Object lifetimeConstraint;
}

/// Returns `true` if [transaction] has a blockhash-based lifetime constraint.
bool isTransactionWithBlockhashLifetime(Transaction transaction) {
  if (transaction is! TransactionWithLifetime) return false;
  final constraint = transaction.lifetimeConstraint;
  if (constraint is! TransactionBlockhashLifetime) return false;
  // Validate that the blockhash is a valid base58 string of 32 bytes.
  return _isBlockhash(constraint.blockhash);
}

/// Asserts that [transaction] has a blockhash-based lifetime constraint.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionExpectedBlockhashLifetime] if the assertion
/// fails.
void assertIsTransactionWithBlockhashLifetime(Transaction transaction) {
  if (!isTransactionWithBlockhashLifetime(transaction)) {
    throw SolanaError(SolanaErrorCode.transactionExpectedBlockhashLifetime);
  }
}

/// Returns `true` if [transaction] has a durable nonce-based lifetime
/// constraint.
bool isTransactionWithDurableNonceLifetime(Transaction transaction) {
  if (transaction is! TransactionWithLifetime) return false;
  final constraint = transaction.lifetimeConstraint;
  if (constraint is! TransactionDurableNonceLifetime) return false;
  // Validate the nonce account address is a valid address.
  return isAddress(constraint.nonceAccountAddress.value);
}

/// Asserts that [transaction] has a durable nonce-based lifetime constraint.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionExpectedNonceLifetime] if the assertion fails.
void assertIsTransactionWithDurableNonceLifetime(Transaction transaction) {
  if (!isTransactionWithDurableNonceLifetime(transaction)) {
    throw SolanaError(SolanaErrorCode.transactionExpectedNonceLifetime);
  }
}

/// The System Program address.
const _systemProgramAddress = Address('11111111111111111111111111111111');

/// Checks if a compiled instruction is an AdvanceNonceAccount instruction.
bool _compiledInstructionIsAdvanceNonceInstruction(
  CompiledInstruction instruction,
  List<Address> staticAddresses,
) {
  return staticAddresses[instruction.programAddressIndex] ==
          _systemProgramAddress &&
      instruction.data != null &&
      _isAdvanceNonceAccountInstructionData(instruction.data!) &&
      instruction.accountIndices != null &&
      instruction.accountIndices!.length == 3;
}

/// Checks if instruction data represents the AdvanceNonceAccount instruction.
/// AdvanceNonceAccount is the fifth instruction in the System Program
/// (index 4).
bool _isAdvanceNonceAccountInstructionData(Uint8List data) {
  return data.length == 4 &&
      data[0] == 4 &&
      data[1] == 0 &&
      data[2] == 0 &&
      data[3] == 0;
}

/// Returns `true` if [value] is a valid blockhash (base58 string that
/// decodes to exactly 32 bytes).
bool _isBlockhash(String value) {
  if (value.length < 32 || value.length > 44) return false;
  try {
    // Reuse the address validation logic since a blockhash has the same
    // base58-32-byte format as an address.
    assertIsAddress(value);
    return true;
  } on Object {
    return false;
  }
}

/// Gets the lifetime constraint for a transaction from a compiled
/// transaction message that includes a lifetime token.
///
/// If the first instruction is an AdvanceNonceAccount instruction, returns
/// a [TransactionDurableNonceLifetime]. Otherwise, returns a
/// [TransactionBlockhashLifetime] with lastValidBlockHeight set to max u64.
Future<Object> getTransactionLifetimeConstraintFromCompiledTransactionMessage(
  CompiledTransactionMessage compiledTransactionMessage,
) async {
  final instructions = compiledTransactionMessage.instructions;
  final staticAccounts = compiledTransactionMessage.staticAccounts;
  final lifetimeToken = compiledTransactionMessage.lifetimeToken;

  if (instructions.isNotEmpty &&
      _compiledInstructionIsAdvanceNonceInstruction(
        instructions[0],
        staticAccounts,
      )) {
    final nonceAccountIndex = instructions[0].accountIndices![0];
    if (nonceAccountIndex >= staticAccounts.length) {
      throw SolanaError(
        SolanaErrorCode.transactionNonceAccountCannotBeInLookupTable,
        {'nonce': lifetimeToken},
      );
    }
    final nonceAccountAddress = staticAccounts[nonceAccountIndex];
    return TransactionDurableNonceLifetime(
      nonce: lifetimeToken ?? '',
      nonceAccountAddress: nonceAccountAddress,
    );
  } else {
    // Not known from the compiled message, so set to the maximum possible.
    final maxU64 = BigInt.parse('18446744073709551615');
    return TransactionBlockhashLifetime(
      blockhash: lifetimeToken ?? '',
      lastValidBlockHeight: maxU64,
    );
  }
}
