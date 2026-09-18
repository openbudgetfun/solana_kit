import 'dart:typed_data';

import 'package:solana_kit_address_constants/solana_kit_address_constants.dart'
    show
        memoLegacyProgramAddress,
        memoLegacyProgramAddressV3,
        memoProgramAddress;
import 'package:solana_kit_addresses/solana_kit_addresses.dart' show Address;
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:test/test.dart';

void main() {
  const nonMemoProgramAddress = Address('11111111111111111111111111111111');

  Instruction memoInstruction(Address programAddress, String memo) {
    return Instruction(
      programAddress: programAddress,
      data: getUtf8Encoder().encode(memo),
    );
  }

  group('supportedMemoProgramAddresses', () {
    test('lists every deployed program address from oldest to newest', () {
      expect(
        supportedMemoProgramAddresses,
        equals(<Address>[
          memoLegacyProgramAddress,
          memoLegacyProgramAddressV3,
          memoProgramAddress,
        ]),
      );
    });
  });

  group('getMemosFromInstructions', () {
    test('extracts memos emitted by every supported program version', () {
      final instructions = [
        memoInstruction(memoLegacyProgramAddress, 'from v1'),
        memoInstruction(memoLegacyProgramAddressV3, 'from v3'),
        memoInstruction(memoProgramAddress, 'from v4'),
      ];

      final memos = getMemosFromInstructions(instructions);

      expect(memos, hasLength(3));
      expect(memos[0].memo, equals('from v1'));
      expect(memos[0].bytes, equals(getUtf8Encoder().encode('from v1')));
      expect(memos[0].programAddress, equals(memoLegacyProgramAddress));
      expect(memos[0].index, equals(0));
      expect(memos[1].memo, equals('from v3'));
      expect(memos[1].bytes, equals(getUtf8Encoder().encode('from v3')));
      expect(memos[1].programAddress, equals(memoLegacyProgramAddressV3));
      expect(memos[1].index, equals(1));
      expect(memos[2].memo, equals('from v4'));
      expect(memos[2].bytes, equals(getUtf8Encoder().encode('from v4')));
      expect(memos[2].programAddress, equals(memoProgramAddress));
      expect(memos[2].index, equals(2));
    });

    test('ignores non-memo instructions and preserves the original index', () {
      final instructions = [
        const Instruction(programAddress: nonMemoProgramAddress),
        memoInstruction(memoProgramAddress, 'Hello world!'),
        const Instruction(programAddress: nonMemoProgramAddress),
      ];

      final memos = getMemosFromInstructions(instructions);

      expect(memos, hasLength(1));
      expect(memos[0].memo, equals('Hello world!'));
      expect(memos[0].bytes, equals(getUtf8Encoder().encode('Hello world!')));
      expect(memos[0].programAddress, equals(memoProgramAddress));
      expect(memos[0].index, equals(1));
    });

    test('returns multiple memos in order', () {
      final instructions = [
        memoInstruction(memoProgramAddress, 'first'),
        const Instruction(programAddress: nonMemoProgramAddress),
        memoInstruction(memoProgramAddress, 'second'),
      ];

      final memos = getMemosFromInstructions(instructions);

      expect(memos.map((m) => m.memo), equals(['first', 'second']));
    });

    test('decodes multi-byte UTF-8 memos', () {
      final instructions = [memoInstruction(memoProgramAddress, 'gm 🌞 café')];

      final memos = getMemosFromInstructions(instructions);

      expect(memos.single.memo, equals('gm 🌞 café'));
    });

    test('yields an empty string and empty bytes for a memo instruction with no data', () {
      final instructions = [
        const Instruction(programAddress: memoProgramAddress),
      ];

      final memos = getMemosFromInstructions(instructions);

      expect(memos, hasLength(1));
      expect(memos[0].memo, equals(''));
      expect(memos[0].bytes, equals(Uint8List(0)));
      expect(memos[0].programAddress, equals(memoProgramAddress));
      expect(memos[0].index, equals(0));
    });

    test('returns an empty list when there are no memo instructions', () {
      final instructions = [
        const Instruction(programAddress: nonMemoProgramAddress),
      ];

      expect(getMemosFromInstructions(instructions), isEmpty);
    });
  });
}
