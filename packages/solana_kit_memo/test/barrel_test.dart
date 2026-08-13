import 'package:solana_kit_address_constants/solana_kit_address_constants.dart'
    show memoProgramAddress;
import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide memoProgramAddress;
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
      // `memoProgramAddress` and `memoLegacyProgramAddress` are re-exported from
      // `solana_kit_address_constants` (the canonical home) — the standalone
      // memo package is the single source of truth for the program addresses.
      final instruction = getAddMemoInstruction(
        memo: 'barrel',
        programAddress: memoProgramAddress,
      );

      expect(instruction.programAddress, equals(memoProgramAddress));
      expect(parseAddMemoInstruction(instruction).memo, equals('barrel'));
    });
  });
}
