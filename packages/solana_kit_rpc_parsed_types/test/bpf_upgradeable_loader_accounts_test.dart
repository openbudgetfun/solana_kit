import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedBpfUpgradeableLoaderProgramAccount', () {
    test('can construct a program account', () {
      const account = JsonParsedBpfProgram(
        info: JsonParsedBpfProgramInfo(
          programData: Address('3vnUTQbDuCgfVn7yQcigUwMQNGkLBZ7GfKWb3gYbAY23'),
        ),
      );

      expect(account.type, 'program');
      expect(
        account.info.programData.value,
        '3vnUTQbDuCgfVn7yQcigUwMQNGkLBZ7GfKWb3gYbAY23',
      );
      expect(account, isA<JsonParsedBpfUpgradeableLoaderProgramAccount>());
    });

    test('can construct a programData account', () {
      final account = JsonParsedBpfProgramData(
        info: JsonParsedBpfProgramDataInfo(
          authority: const Address(
            '7g4Los4WMQnpxYiBJpU1HejBiM6xCk5RDFGCABhWE9M6',
          ),
          data: (const Base64EncodedBytes('f0VMRgIBAAAAAAAAA'), 'base64'),
          slot: BigInt.from(259942942),
        ),
      );

      expect(account.type, 'programData');
      expect(
        account.info.authority?.value,
        '7g4Los4WMQnpxYiBJpU1HejBiM6xCk5RDFGCABhWE9M6',
      );
      expect(account.info.slot, BigInt.from(259942942));
      expect(account, isA<JsonParsedBpfUpgradeableLoaderProgramAccount>());
    });

    test('can discriminate via sealed class', () {
      const JsonParsedBpfUpgradeableLoaderProgramAccount account =
          JsonParsedBpfProgram(
            info: JsonParsedBpfProgramInfo(
              programData: Address(
                '3vnUTQbDuCgfVn7yQcigUwMQNGkLBZ7GfKWb3gYbAY23',
              ),
            ),
          );

      switch (account) {
        case JsonParsedBpfProgram(:final info):
          expect(
            info.programData.value,
            '3vnUTQbDuCgfVn7yQcigUwMQNGkLBZ7GfKWb3gYbAY23',
          );
        case JsonParsedBpfProgramData():
          fail('Expected program, got programData');
      }
    });

    test('BpfProgramInfo equality and toString', () {
      const info1 = JsonParsedBpfProgramInfo(
        programData: Address('3vnUTQbDuCgfVn7yQcigUwMQNGkLBZ7GfKWb3gYbAY23'),
      );
      const info2 = JsonParsedBpfProgramInfo(
        programData: Address('3vnUTQbDuCgfVn7yQcigUwMQNGkLBZ7GfKWb3gYbAY23'),
      );
      const info3 = JsonParsedBpfProgramInfo(
        programData: Address('7g4Los4WMQnpxYiBJpU1HejBiM6xCk5RDFGCABhWE9M6'),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('programData'));
    });

    test('BpfProgramDataInfo equality, hashCode, and toString', () {
      final info1 = JsonParsedBpfProgramDataInfo(
        authority: const Address('7g4Los4WMQnpxYiBJpU1HejBiM6xCk5RDFGCABhWE9M6'),
        data: (const Base64EncodedBytes('f0VMRgIBAAAAAAAAA'), 'base64'),
        slot: BigInt.from(259942942),
      );
      final info2 = JsonParsedBpfProgramDataInfo(
        authority: const Address('7g4Los4WMQnpxYiBJpU1HejBiM6xCk5RDFGCABhWE9M6'),
        data: (const Base64EncodedBytes('f0VMRgIBAAAAAAAAA'), 'base64'),
        slot: BigInt.from(259942942),
      );
      final info3 = JsonParsedBpfProgramDataInfo(
        authority: const Address('7g4Los4WMQnpxYiBJpU1HejBiM6xCk5RDFGCABhWE9M6'),
        data: (const Base64EncodedBytes('different'), 'base64'),
        slot: BigInt.from(259942942),
      );
      final info4 = JsonParsedBpfProgramDataInfo(
        authority: const Address('7g4Los4WMQnpxYiBJpU1HejBiM6xCk5RDFGCABhWE9M6'),
        data: (const Base64EncodedBytes('f0VMRgIBAAAAAAAAA'), 'base64'),
        slot: BigInt.from(999),
      );
      final info5 = JsonParsedBpfProgramDataInfo(
        data: (const Base64EncodedBytes('f0VMRgIBAAAAAAAAA'), 'base64'),
        slot: BigInt.from(259942942),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1 == info4, isFalse);
      expect(info1 == info5, isFalse);
      expect(info1.toString(), contains('slot:'));
    });
  });
}
