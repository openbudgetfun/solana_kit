import 'dart:convert';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

/// An IDL with identical field layouts to isolate discriminator checks.
Map<String, Object?> _idl(List<int> discriminator) => {
  'address': '11111111111111111111111111111111',
  for (final section in ['instructions', 'accounts', 'events'])
    section: [
      {'name': 'Value', 'discriminator': discriminator},
    ],
  'types': [
    {
      'name': 'Value',
      'type': {'kind': 'struct'},
    },
  ],
};

void main() {
  const invalidEntries = <String, Map<String, Object?>>{
    'missing': {},
    'null': {'discriminator': null},
    'empty': {'discriminator': <int>[]},
    'scalar': {'discriminator': 1},
    'string': {'discriminator': '1'},
    'object': {'discriminator': <String, Object?>{}},
    'negative byte': {
      'discriminator': [0, -1],
    },
    'oversized byte': {
      'discriminator': [0, 256],
    },
    'fractional byte': {
      'discriminator': [0, 1.5],
    },
    'double byte': {
      'discriminator': [0, 1.0],
    },
    'string byte': {
      'discriminator': [0, '1'],
    },
    'null byte': {
      'discriminator': [0, null],
    },
    'boolean byte': {
      'discriminator': [0, true],
    },
  };

  for (final section in ['instructions', 'accounts', 'events']) {
    group('$section discriminator parsing', () {
      for (final entry in invalidEntries.entries) {
        test('rejects ${entry.key}', () {
          final document = <String, Object?>{
            section: [
              {'name': 'Value', ...entry.value},
            ],
          };

          expect(() => AnchorIdlProgram.parse(document), throwsArgumentError);
          expect(
            () => AnchorIdlProgram.parse(jsonEncode(document)),
            throwsArgumentError,
          );
        });
      }
    });
  }

  for (final length in [1, 2, 7, 8, 9]) {
    test('round-trips $length-byte discriminators without coercion', () {
      final discriminator = List.generate(
        length,
        (index) => index.isEven ? 0 : 255,
      );
      final coder = AnchorCoder(AnchorIdlProgram.parse(_idl(discriminator)));
      final instruction = coder.encodeInstructionData('Value', {});
      final account = coder.encodeAccount('Value', {});
      final logs = [
        'Program ${coder.idl.address} invoke [1]',
        'Program data: ${base64Encode(discriminator)}',
        'Program ${coder.idl.address} success',
      ];

      expect(instruction, discriminator);
      expect(coder.decodeInstructionData('Value', instruction), isEmpty);
      expect(account, discriminator);
      expect(coder.decodeAccount('Value', account).data, isEmpty);
      expect(coder.decodeEventLogs(logs).single.name, 'Value');

      for (final payload in [
        <int>[],
        discriminator.take(length - 1).toList(),
        [...discriminator.take(length - 1), discriminator.last ^ 0xff],
      ]) {
        expect(
          () => coder.decodeInstructionData('Value', payload),
          throwsA(isA<AnchorDiscriminatorMismatch>()),
        );
        expect(
          () => coder.decodeAccount('Value', payload),
          throwsA(isA<AnchorDiscriminatorMismatch>()),
        );
        expect(
          coder.decodeEventLogs([
            'Program ${coder.idl.address} invoke [1]',
            'Program data: ${base64Encode(payload)}',
            'Program ${coder.idl.address} success',
          ]),
          isEmpty,
        );
      }
    });
  }

  test('parsed discriminators cannot be changed after validation', () {
    final input = [1, 2];
    final idl = AnchorIdlProgram.parse(_idl(input));
    input[0] = 255;

    for (final discriminator in [
      idl.instructions['Value']!.discriminator,
      idl.accounts['Value']!.discriminator,
      idl.events['Value']!.discriminator,
    ]) {
      expect(discriminator, [1, 2]);
      expect(() => discriminator[0] = -1, throwsUnsupportedError);
      expect(discriminator.clear, throwsUnsupportedError);
    }
  });

  test('an empty discriminator never matches a payload', () {
    expect(startsWithDiscriminator([], []), isFalse);
    expect(startsWithDiscriminator([1, 2], []), isFalse);
  });

  test('manually constructed empty discriminators cannot bypass decoding', () {
    const idl = AnchorIdlProgram(
      address: '11111111111111111111111111111111',
      name: 'empty',
      instructions: {
        'Value': AnchorIdlInstruction(
          name: 'Value',
          discriminator: [],
          args: [],
        ),
      },
      accounts: {'Value': AnchorIdlAccount(name: 'Value', discriminator: [])},
      events: {'Value': AnchorIdlEvent(name: 'Value', discriminator: [])},
      errors: {},
      types: {'Value': AnchorIdlStruct(fields: [])},
    );
    final coder = AnchorCoder(idl);

    expect(
      () => coder.decodeInstructionData('Value', []),
      throwsA(isA<AnchorDiscriminatorMismatch>()),
    );
    expect(
      () => coder.decodeAccount('Value', []),
      throwsA(isA<AnchorDiscriminatorMismatch>()),
    );
    expect(
      coder.decodeEventLogs([
        'Program ${idl.address} invoke [1]',
        'Program data: ',
        'Program ${idl.address} success',
      ]),
      isEmpty,
    );
  });
}
