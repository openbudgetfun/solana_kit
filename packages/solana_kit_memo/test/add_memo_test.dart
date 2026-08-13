import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart'
    show memoProgramAddress, memoLegacyProgramAddress;
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:test/test.dart';

void main() {
  group('AddMemo', () {
    test('known memo string produces UTF-8 encoded bytes', () {
      final instruction = getAddMemoInstruction(
        memo: 'Hello, memo!',
        programAddress: memoProgramAddress,
      );

      expect(instruction.programAddress, equals(memoProgramAddress));
      expect(instruction.accounts, isEmpty);
      expect(
        instruction.data,
        equals(
          Uint8List.fromList([
            72,
            101,
            108,
            108,
            111,
            44,
            32,
            109,
            101,
            109,
            111,
            33,
          ]),
        ),
      );
    });

    test('non-ASCII memo string produces UTF-8 encoded bytes', () {
      final instruction = getAddMemoInstruction(
        memo: 'memo 語',
        programAddress: memoProgramAddress,
      );

      expect(
        instruction.data,
        equals(Uint8List.fromList(utf8.encode('memo 語'))),
      );
    });

    test('codec round-trips instruction data', () {
      const original = AddMemoInstructionData(memo: 'Solana Kit memo');
      final codec = getAddMemoInstructionDataCodec();
      final encoded = codec.encode(original);
      final decoded = codec.decode(encoded);

      // The generated `AddMemoInstructionData` is a plain `@immutable` value
      // class without custom `==`, so we compare the inner `memo` field.
      expect(decoded.memo, equals(original.memo));
      expect(encoded, equals(Uint8List.fromList(utf8.encode(original.memo))));
    });

    test('parseAddMemoInstruction decodes instruction data', () {
      final instruction = getAddMemoInstruction(
        memo: 'parsed memo',
        programAddress: memoProgramAddress,
      );

      expect(parseAddMemoInstruction(instruction).memo, equals('parsed memo'));
    });

    test('supports legacy memo program address', () {
      final instruction = getAddMemoInstruction(
        memo: 'legacy memo',
        programAddress: memoLegacyProgramAddress,
      );

      expect(instruction.programAddress, equals(memoLegacyProgramAddress));
    });

    test('data class stores memo field', () {
      const a = AddMemoInstructionData(memo: 'same');

      expect(a.memo, equals('same'));
    });
  });
}