import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('createTransactionMessage', () {
    test('creates a legacy transaction', () {
      final message = createTransactionMessage(
        version: TransactionVersion.legacy,
      );
      expect(message.version, TransactionVersion.legacy);
      expect(message.instructions, isEmpty);
    });

    test('creates a v0 transaction', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);
      expect(message.version, TransactionVersion.v0);
      expect(message.instructions, isEmpty);
    });

    test('has no fee payer', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);
      expect(message.feePayer, isNull);
    });

    test('has no lifetime constraint', () {
      final message = createTransactionMessage(version: TransactionVersion.v0);
      expect(message.lifetimeConstraint, isNull);
    });
  });
}
