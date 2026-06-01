import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Pipe', () {
    test('pipes values through multiple transforms', () {
      final result = 1.pipe((value) => value + 1).pipe((value) => value * 2);
      expect(result, 4);
    });

    test('supports changing result types', () {
      final result = 'solana'
          .pipe((value) => value.toUpperCase())
          .pipe((value) => '$value!');
      expect(result, 'SOLANA!');
    });
  });
}
