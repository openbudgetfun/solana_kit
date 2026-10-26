import 'dart:convert';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

const _program = '11111111111111111111111111111111';
const _node = {
  'defined': {'name': 'Node'},
};

void main() {
  group('cyclic defined types', () {
    for (final (label, fieldType) in <(String, Object)>[
      ('direct', _node),
      ('option', {'option': _node}),
      ('vec', {'vec': _node}),
      (
        'array',
        {
          'array': [_node, 1],
        },
      ),
    ]) {
      test('rejects a $label self-reference', () {
        final coder = _coder({
          'Node': {
            'kind': 'struct',
            'fields': [
              {'name': 'next', 'type': fieldType},
            ],
          },
        });

        expect(
          () => coder.codecFor(const AnchorIdlDefined('Node')),
          throwsA(_cycleError('Node')),
        );
      });
    }

    test('rejects a cycle through a struct and an enum tuple variant', () {
      final coder = _coder({
        'Node': {
          'kind': 'struct',
          'fields': [
            {
              'name': 'state',
              'type': {
                'defined': {'name': 'State'},
              },
            },
          ],
        },
        'State': {
          'kind': 'enum',
          'variants': [
            {
              'name': 'Next',
              'fields': [_node],
            },
          ],
        },
      });

      expect(
        () => coder.codecFor(const AnchorIdlDefined('Node')),
        throwsA(_cycleError('Node')),
      );
    });

    test('rejects cycles through instruction, account, and event APIs', () {
      final coder = _coder({
        'Node': {
          'kind': 'struct',
          'fields': [
            {'name': 'next', 'type': _node},
          ],
        },
      });
      final operations = <void Function()>[
        () => coder.encodeInstructionData('write', {'value': null}),
        () => coder.decodeInstructionData('write', [1]),
        () => coder.encodeAccount('Node', {}),
        () => coder.decodeAccount('Node', [1]),
        () => coder.decodeEventLogs([
          'Program $_program invoke [1]',
          'Program data: ${base64Encode([1])}',
          'Program $_program success',
        ]),
      ];

      for (final operation in operations) {
        expect(operation, throwsA(_cycleError('Node')));
      }
    });
  });

  test('repeated acyclic references still encode and decode', () {
    final coder = _coder({
      'Node': {
        'kind': 'struct',
        'fields': [
          for (final name in ['left', 'right'])
            {
              'name': name,
              'type': {
                'defined': {'name': 'Leaf'},
              },
            },
        ],
      },
      'Leaf': {
        'kind': 'struct',
        'fields': [
          {'name': 'value', 'type': 'u8'},
        ],
      },
    });
    final (encoder, decoder) = coder.codecFor(const AnchorIdlDefined('Node'));
    final value = {
      'left': {'value': 7},
      'right': {'value': 9},
    };

    expect(encoder.encode(value), [7, 9]);
    expect(decoder.decode(encoder.encode(value)), value);
    expect(coder.encodeAccount('Node', value), [1, 7, 9]);
    expect(coder.decodeAccount('Node', [1, 7, 9]).data, value);
  });

  test('failed construction can be retried after fixing a missing type', () {
    final coder = _coder({
      'Node': {
        'kind': 'struct',
        'fields': [
          {
            'name': 'value',
            'type': {
              'defined': {'name': 'Leaf'},
            },
          },
        ],
      },
    });

    expect(
      () => coder.codecFor(const AnchorIdlDefined('Node')),
      throwsArgumentError,
    );

    coder.idl.types['Leaf'] = const AnchorIdlStruct(fields: []);
    final (encoder, decoder) = coder.codecFor(const AnchorIdlDefined('Node'));
    final value = <String, Object?>{'value': <String, Object?>{}};

    expect(encoder.encode(value), isEmpty);
    expect(decoder.decode(encoder.encode(value)), value);
  });
}

/// Checks that recursion fails with the offending type's name.
Matcher _cycleError(String name) => isA<ArgumentError>()
    .having((error) => error.invalidValue, 'invalidValue', name)
    .having((error) => error.message, 'message', contains('Cyclic'));

/// Parses runtime IDL definitions shared by every coder entrypoint.
AnchorCoder _coder(Map<String, Object?> definitions) => AnchorCoder(
  AnchorIdlProgram.parse({
    'address': _program,
    'instructions': [
      {
        'name': 'write',
        'discriminator': [1],
        'args': [
          {'name': 'value', 'type': _node},
        ],
      },
    ],
    'accounts': [
      {
        'name': 'Node',
        'discriminator': [1],
      },
    ],
    'events': [
      {
        'name': 'Node',
        'discriminator': [1],
      },
    ],
    'types': [
      for (final entry in definitions.entries)
        {'name': entry.key, 'type': entry.value},
    ],
  }),
);
