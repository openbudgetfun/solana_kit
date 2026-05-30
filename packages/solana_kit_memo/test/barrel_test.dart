import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:test/test.dart';

void main() {
  group('barrel exports', () {
    test('program addresses are accessible', () {
      expect(
        memoProgramAddress.value,
        equals('MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr'),
      );
      expect(
        memoLegacyProgramAddress.value,
        equals('Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo'),
      );
    });

    test('instruction helper is callable', () {
      final instruction = getAddMemoInstruction(memo: 'barrel');

      expect(instruction.programAddress, equals(memoProgramAddress));
      expect(parseAddMemoInstruction(instruction).memo, equals('barrel'));
    });
  });
}
