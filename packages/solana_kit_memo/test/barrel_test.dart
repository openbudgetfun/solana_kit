import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:test/test.dart';

void main() {
  group('barrel exports', () {
    test('program addresses are accessible', () {
      expect(
        memoProgramAddress.value,
        equals('Memo1UhkJ4AsZNBm8hWoQeYfRDfaK9K7a8Kj9vOUdhM7Q'),
      );
      expect(
        memoLegacyProgramAddress.value,
        equals('MemoSq4gqABb5KBAsS3tQ9UJMKg7hXe3LF7tu4RssKE3'),
      );
    });

    test('instruction helper is callable', () {
      final instruction = getAddMemoInstruction(memo: 'barrel');

      expect(instruction.programAddress, equals(memoProgramAddress));
      expect(parseAddMemoInstruction(instruction).memo, equals('barrel'));
    });
  });
}
