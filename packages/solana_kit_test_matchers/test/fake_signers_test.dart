import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('MockTransactionPartialSigner', () {
    test('stores address', () {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionPartialSigner(addr);
      expect(signer.address, addr);
    });

    test('signTransactions returns empty maps by default', () async {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionPartialSigner(addr);
      final result = await signer.signTransactions([
        Transaction(
          messageBytes: Uint8List(32),
          signatures: {addr: SignatureBytes(Uint8List(64))},
        ),
      ]);
      expect(result, hasLength(1));
      expect(result.first, isEmpty);
    });
  });

  group('MockTransactionModifyingSigner', () {
    test('stores address', () {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionModifyingSigner(addr);
      expect(signer.address, addr);
    });

    test('modifyAndSignTransactions returns original transactions by default',
        () async {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionModifyingSigner(addr);
      final txn = Transaction(
        messageBytes: Uint8List(32),
        signatures: {addr: SignatureBytes(Uint8List(64))},
      );
      final result = await signer.modifyAndSignTransactions([txn]);
      expect(result, hasLength(1));
      expect(identical(result.first, txn), isTrue);
    });
  });

  group('MockTransactionSendingSigner', () {
    test('stores address', () {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionSendingSigner(addr);
      expect(signer.address, addr);
    });

    test('signAndSendTransactions returns zero signatures by default',
        () async {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionSendingSigner(addr);
      final result = await signer.signAndSendTransactions([
        Transaction(
          messageBytes: Uint8List(32),
          signatures: {addr: SignatureBytes(Uint8List(64))},
        ),
      ]);
      expect(result, hasLength(1));
      expect(result.first.value, hasLength(64));
    });
  });

  group('createMockInstructionWithSigners', () {
    test('creates instruction with signer accounts', () {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionPartialSigner(addr);
      final instruction = createMockInstructionWithSigners([signer]);
      expect(instruction.accounts, hasLength(1));
      expect(instruction.programAddress.value, isNotEmpty);
    });
  });

  group('createMockTransactionMessageWithSigners', () {
    test('creates a transaction message with signers', () {
      const addr = Address('11111111111111111111111111111111');
      final signer = MockTransactionPartialSigner(addr);
      final message = createMockTransactionMessageWithSigners([signer]);
      expect(message.feePayer, addr);
      expect(message.instructions, hasLength(1));
    });

    test('creates a message with empty signers', () {
      final message = createMockTransactionMessageWithSigners([]);
      expect(message.feePayer, isNotNull);
    });
  });
}
