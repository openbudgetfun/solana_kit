import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_memo/solana_kit_memo.dart';
import 'package:test/test.dart';

void main() {
  group('AddMemo', () {
    test('known memo string produces UTF-8 encoded bytes', () {
      final instruction = getAddMemoInstruction(memo: 'Hello, memo!');

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
      final instruction = getAddMemoInstruction(memo: 'memo 語');

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

      expect(decoded, equals(original));
      expect(encoded, equals(Uint8List.fromList(utf8.encode(original.memo))));
    });

    test('parseAddMemoInstruction decodes instruction data', () {
      final instruction = getAddMemoInstruction(memo: 'parsed memo');

      expect(
        parseAddMemoInstruction(instruction),
        equals(const AddMemoInstructionData(memo: 'parsed memo')),
      );
    });

    test('getAddMemoInstructionFromData preserves custom accounts', () {
      const signer = AccountMeta(
        address: Address('11111111111111111111111111111111'),
        role: AccountRole.readonlySigner,
      );
      final instruction = getAddMemoInstructionFromData(
        data: const AddMemoInstructionData(memo: 'signed memo'),
        accounts: const [signer],
      );

      expect(instruction.accounts, equals(const [signer]));
    });

    test('supports legacy memo program address', () {
      final instruction = getAddMemoInstruction(
        memo: 'legacy memo',
        programAddress: memoLegacyProgramAddress,
      );

      expect(instruction.programAddress, equals(memoLegacyProgramAddress));
    });

    test('value equality and toString', () {
      const a = AddMemoInstructionData(memo: 'same');
      const b = AddMemoInstructionData(memo: 'same');
      const c = AddMemoInstructionData(memo: 'different');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
      expect(a.toString(), contains('same'));
    });
  });
}
