import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Creates a mock instruction with signer accounts for each provided signer.
Instruction createMockInstructionWithSigners(List<Object> signers) {
  return Instruction(
    programAddress: const Address(
      '55555555555555555555555555555555555555555555',
    ),
    accounts: signers
        .map(
          (signer) => AccountSignerMeta(
            address: getTransactionSignerAddress(signer),
            role: AccountRole.readonlySigner,
            signer: signer,
          ),
        )
        .toList(),
    data: Uint8List(0),
  );
}

/// Creates a mock transaction message with signers.
TransactionMessage createMockTransactionMessageWithSigners(
  List<Object> signers,
) {
  final feePayerAddress = signers.isNotEmpty
      ? getTransactionSignerAddress(signers.first)
      : const Address('22222222222222222222222222222222222222222222');

  var message = createTransactionMessage(version: TransactionVersion.v0);
  message = setTransactionMessageFeePayer(feePayerAddress, message);
  message = setTransactionMessageLifetimeUsingBlockhash(
    BlockhashLifetimeConstraint(
      blockhash: 'Ep1Aq1hQ8oZ1FMd94KxvFSTiigHmGF4iYwYkiigZcKhB',
      lastValidBlockHeight: BigInt.from(42),
    ),
    message,
  );
  return appendTransactionMessageInstruction(
    createMockInstructionWithSigners(signers),
    message,
  );
}

/// A mock implementation of [TransactionPartialSigner].
class MockTransactionPartialSigner implements TransactionPartialSigner {
  /// Creates a mock partial signer.
  MockTransactionPartialSigner(this.address);

  @override
  final Address address;

  /// Optional mock implementation override.
  Future<List<Map<Address, SignatureBytes>>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  signTransactionsMock;

  @override
  Future<List<Map<Address, SignatureBytes>>> signTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    return signTransactionsMock?.call(transactions, config) ??
        transactions.map((_) => <Address, SignatureBytes>{}).toList();
  }
}

/// A mock implementation of [TransactionModifyingSigner].
class MockTransactionModifyingSigner implements TransactionModifyingSigner {
  /// Creates a mock modifying signer.
  MockTransactionModifyingSigner(this.address);

  @override
  final Address address;

  /// Optional mock implementation override.
  Future<List<Transaction>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  modifyAndSignTransactionsMock;

  @override
  Future<List<Transaction>> modifyAndSignTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    return modifyAndSignTransactionsMock?.call(transactions, config) ??
        transactions;
  }
}

/// A mock implementation of [TransactionSendingSigner].
class MockTransactionSendingSigner implements TransactionSendingSigner {
  /// Creates a mock sending signer.
  MockTransactionSendingSigner(this.address);

  @override
  final Address address;

  /// Optional mock implementation override.
  Future<List<SignatureBytes>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  signAndSendTransactionsMock;

  @override
  Future<List<SignatureBytes>> signAndSendTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    return signAndSendTransactionsMock?.call(transactions, config) ??
        transactions.map((_) => SignatureBytes(Uint8List(64))).toList();
  }
}
