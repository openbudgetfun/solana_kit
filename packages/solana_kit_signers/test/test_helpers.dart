import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Creates a mock instruction with signer accounts for each provided
/// signer.
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
      ? getTransactionSignerAddress(signers[0])
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
  message = appendTransactionMessageInstruction(
    createMockInstructionWithSigners(signers),
    message,
  );
  return message;
}

/// A mock implementation of [TransactionPartialSigner].
class MockTransactionPartialSigner implements TransactionPartialSigner {
  /// Creates a mock partial signer.
  MockTransactionPartialSigner(this.address);

  @override
  final Address address;

  /// The mock implementation for signTransactions.
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
    if (signTransactionsMock != null) {
      return signTransactionsMock!(transactions, config);
    }
    return transactions.map((_) => <Address, SignatureBytes>{}).toList();
  }

  /// Records of calls made.
  final calls = <(List<Transaction>, TransactionSignerConfig?)>[];
}

/// A mock implementation of [TransactionModifyingSigner].
class MockTransactionModifyingSigner implements TransactionModifyingSigner {
  /// Creates a mock modifying signer.
  MockTransactionModifyingSigner(this.address);

  @override
  final Address address;

  /// The mock implementation for modifyAndSignTransactions.
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
    if (modifyAndSignTransactionsMock != null) {
      return modifyAndSignTransactionsMock!(transactions, config);
    }
    return transactions;
  }
}

/// A mock implementation of [TransactionSendingSigner].
class MockTransactionSendingSigner implements TransactionSendingSigner {
  /// Creates a mock sending signer.
  MockTransactionSendingSigner(this.address);

  @override
  final Address address;

  /// The mock implementation for signAndSendTransactions.
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
    if (signAndSendTransactionsMock != null) {
      return signAndSendTransactionsMock!(transactions, config);
    }
    return transactions.map((_) => SignatureBytes(Uint8List(64))).toList();
  }
}

/// A mock implementation of [MessagePartialSigner].
class MockMessagePartialSigner implements MessagePartialSigner {
  /// Creates a mock message partial signer.
  MockMessagePartialSigner(this.address);

  @override
  final Address address;

  @override
  Future<List<Map<Address, SignatureBytes>>> signMessages(
    List<SignableMessage> messages, [
    SignerConfig? config,
  ]) async {
    return messages.map((_) => <Address, SignatureBytes>{}).toList();
  }
}

/// A mock implementation of [MessageModifyingSigner].
class MockMessageModifyingSigner implements MessageModifyingSigner {
  /// Creates a mock message modifying signer.
  MockMessageModifyingSigner(this.address);

  @override
  final Address address;

  @override
  Future<List<SignableMessage>> modifyAndSignMessages(
    List<SignableMessage> messages, [
    SignerConfig? config,
  ]) async {
    return messages;
  }
}

/// A mock composite signer implementing sending and partial transaction
/// signer interfaces (but not modifying).
class MockTransactionSendingPartialSigner
    implements TransactionPartialSigner, TransactionSendingSigner {
  /// Creates a mock sending+partial signer.
  MockTransactionSendingPartialSigner(this.address);

  @override
  final Address address;

  /// The mock implementation for signTransactions.
  Future<List<Map<Address, SignatureBytes>>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  signTransactionsMock;

  /// The mock implementation for signAndSendTransactions.
  Future<List<SignatureBytes>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  signAndSendTransactionsMock;

  @override
  Future<List<Map<Address, SignatureBytes>>> signTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    if (signTransactionsMock != null) {
      return signTransactionsMock!(transactions, config);
    }
    return transactions.map((_) => <Address, SignatureBytes>{}).toList();
  }

  @override
  Future<List<SignatureBytes>> signAndSendTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    if (signAndSendTransactionsMock != null) {
      return signAndSendTransactionsMock!(transactions, config);
    }
    return transactions.map((_) => SignatureBytes(Uint8List(64))).toList();
  }
}

/// A mock composite signer implementing all three transaction signer
/// interfaces.
class MockTransactionCompositeSigner
    implements
        TransactionPartialSigner,
        TransactionModifyingSigner,
        TransactionSendingSigner {
  /// Creates a mock composite signer.
  MockTransactionCompositeSigner(this.address);

  @override
  final Address address;

  /// The mock implementation for signTransactions.
  Future<List<Map<Address, SignatureBytes>>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  signTransactionsMock;

  /// The mock implementation for modifyAndSignTransactions.
  Future<List<Transaction>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  modifyAndSignTransactionsMock;

  /// The mock implementation for signAndSendTransactions.
  Future<List<SignatureBytes>> Function(
    List<Transaction>,
    TransactionSignerConfig?,
  )?
  signAndSendTransactionsMock;

  @override
  Future<List<Map<Address, SignatureBytes>>> signTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    if (signTransactionsMock != null) {
      return signTransactionsMock!(transactions, config);
    }
    return transactions.map((_) => <Address, SignatureBytes>{}).toList();
  }

  @override
  Future<List<Transaction>> modifyAndSignTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    if (modifyAndSignTransactionsMock != null) {
      return modifyAndSignTransactionsMock!(transactions, config);
    }
    return transactions;
  }

  @override
  Future<List<SignatureBytes>> signAndSendTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    if (signAndSendTransactionsMock != null) {
      return signAndSendTransactionsMock!(transactions, config);
    }
    return transactions.map((_) => SignatureBytes(Uint8List(64))).toList();
  }
}
