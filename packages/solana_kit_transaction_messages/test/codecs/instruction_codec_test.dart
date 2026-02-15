import 'dart:typed_data';

import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:test/test.dart';

void main() {
  group('Instruction encoder', () {
    test('serializes an instruction according to spec', () {
      final encoder = getInstructionEncoder();
      final result = encoder.encode(
        CompiledInstruction(
          programAddressIndex: 7,
          accountIndices: const [1, 2],
          data: Uint8List.fromList([4, 5, 6]),
        ),
      );
      expect(
        result,
        equals(
          Uint8List.fromList([
            // Program id index
            7,
            // Compact array of account indices
            2, // Compact-u16 length
            1, 2,
            // Compact array of instruction data
            3, // Compact-u16 length
            4, 5, 6,
          ]),
        ),
      );
    });

    test(
      'serializes a zero-length compact array when accountIndices is null',
      () {
        final encoder = getInstructionEncoder();
        final result = encoder.encode(
          CompiledInstruction(
            programAddressIndex: 1,
            data: Uint8List.fromList([3, 4]),
          ),
        );
        expect(
          result,
          equals(
            Uint8List.fromList([
              // Program id index
              1,
              // Compact array of account indices
              0, // Compact-u16 length
              // Compact array of instruction data
              2, // Compact-u16 length
              3, 4,
            ]),
          ),
        );
      },
    );

    test('serializes a zero-length compact array when data is null', () {
      final encoder = getInstructionEncoder();
      final result = encoder.encode(
        const CompiledInstruction(
          programAddressIndex: 1,
          accountIndices: [3, 4],
        ),
      );
      expect(
        result,
        equals(
          Uint8List.fromList([
            // Program id index
            1,
            // Compact array of account indices
            2, // Compact-u16 length
            3, 4,
            // Compact array of instruction data
            0, // Compact-u16 length
          ]),
        ),
      );
    });
  });

  group('Instruction decoder', () {
    test('deserializes an instruction according to spec', () {
      final decoder = getInstructionDecoder();
      final result = decoder.decode(
        Uint8List.fromList([
          // Program id index
          1,
          // Compact array of account indices
          2, // Compact-u16 length
          3, 4,
          // Compact array of instruction data
          5, // Compact-u16 length
          6, 7, 8, 9, 10,
        ]),
      );
      expect(result.programAddressIndex, equals(1));
      expect(result.accountIndices, equals([3, 4]));
      expect(result.data, equals(Uint8List.fromList([6, 7, 8, 9, 10])));
    });

    test(
      'sets accountIndices to null when the indices data is zero-length',
      () {
        final decoder = getInstructionDecoder();
        final result = decoder.decode(
          Uint8List.fromList([
            // Program id index
            1,
            // Compact array of account indices
            0, // Compact-u16 length
            // Compact array of instruction data
            2, // Compact-u16 length
            3, 4,
          ]),
        );
        expect(result.programAddressIndex, equals(1));
        expect(result.accountIndices, isNull);
        expect(result.data, equals(Uint8List.fromList([3, 4])));
      },
    );

    test('sets data to null when the instruction data is zero-length', () {
      final decoder = getInstructionDecoder();
      final result = decoder.decode(
        Uint8List.fromList([
          // Program id index
          1,
          // Compact array of account indices
          2, // Compact-u16 length
          3, 4,
          // Compact array of instruction data
          0, // Compact-u16 length
        ]),
      );
      expect(result.programAddressIndex, equals(1));
      expect(result.accountIndices, equals([3, 4]));
      expect(result.data, isNull);
    });
  });

  group('Instruction codec', () {
    test('round-trips a full instruction', () {
      final codec = getInstructionCodec();
      final instruction = CompiledInstruction(
        programAddressIndex: 42,
        accountIndices: const [1, 2, 3],
        data: Uint8List.fromList([10, 20, 30]),
      );
      final encoded = codec.encode(instruction);
      final decoded = codec.decode(encoded);
      expect(decoded, equals(instruction));
    });
  });
}
