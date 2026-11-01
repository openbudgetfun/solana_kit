import 'dart:io';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

/// Resolves [relative] against this package's root, whether the test runner
/// starts in the package directory or in the workspace root.
File _fixture(String relative) {
  final current = Directory.current.path;
  final inPackage = current.endsWith('solana_kit_anchor');
  final base = inPackage ? current : '$current/packages/solana_kit_anchor';

  return File('$base/$relative'.replaceAll('//', '/'));
}

void main() {
  final fixtureJson = _fixture('test/fixtures/idl.json').readAsStringSync();

  test('parses the Anchor test-suite IDL end to end', () {
    final idl = AnchorIdlProgram.parse(fixtureJson);

    expect(idl.address, isNotEmpty);
    expect(idl.name, 'idl');
    expect(idl.instructions, isNotEmpty);
    expect(idl.accounts, isNotEmpty);
    expect(idl.events, isNotEmpty);
    expect(idl.errors, isNotEmpty);
    expect(idl.types, isNotEmpty);

    // The explicit IDL discriminator matches the Anchor sighash.
    final instruction = idl.instructions['account_and_event_arg_and_field'];
    expect(instruction, isNotNull);
    expect(
      instruction!.discriminator,
      instructionDiscriminator('account_and_event_arg_and_field'),
    );

    // Defined-type names strip their module paths.
    expect(idl.types.keys, contains('NamedStruct'));
    expect(idl.types.keys, isNot(contains('idl::NamedStruct')));
    expect(idl.errors[500000]!.name, 'SomeError');
  });

  test('rejects unsupported shapes', () {
    // Generic type instantiation.
    expect(
      () => AnchorIdlType.parse({
        'defined': {
          'name': 'Box',
          'generics': [
            {'kind': 'type', 'type': 'u16'},
          ],
        },
      }),
      throwsArgumentError,
    );
    // Unknown scalar.
    expect(() => AnchorIdlType.parse('u4096'), throwsArgumentError);
    // Unknown compound node.
    expect(() => AnchorIdlType.parse({'wat': 'u8'}), throwsArgumentError);
    // 8-byte option prefix.
    expect(
      () => AnchorIdlType.parse({
        'option': 'u8',
        'prefix': 8,
      }),
      throwsArgumentError,
    );
    // Non-integer array length.
    expect(
      () => AnchorIdlType.parse({
        'array': ['u8', 'many'],
      }),
      throwsArgumentError,
    );
    // Unsupported defined-type kinds.
    expect(
      () => AnchorIdlProgram.parse({
        'types': [
          <String, Object?>{
            'name': 'Weird',
            'type': {'kind': 'alias', 'value': 'u8'},
          },
        ],
      }),
      throwsArgumentError,
    );
  });

  test('parses scalar, compound, tuple, and alias shapes', () {
    final bytesType = AnchorIdlType.parse(<String, Object?>{
      'bytes': <Object?>{},
    });
    expect(bytesType, isA<AnchorIdlBytes>());

    final vec =
        AnchorIdlType.parse(<String, Object?>{'vec': 'u32'}) as AnchorIdlVec;
    expect(vec.element, AnchorIdlPrimitive.u32);

    final option = AnchorIdlType.parse(<String, Object?>{
      'option': 'u64',
    }) as AnchorIdlOption;
    expect(option.prefix, 1);
    expect(option.inner, AnchorIdlPrimitive.u64);

    final array = AnchorIdlType.parse(<String, Object?>{
      'array': ['u8', '4'],
    }) as AnchorIdlArray;
    expect(array.length, 4);
  });

  test('module-path names map onto their last segment', () {
    expect(typeNameOf('idl::some_module::NamedStruct'), 'NamedStruct');
    expect(typeNameOf('Plain'), 'Plain');
  });

  group('fixed-array lengths', () {
    for (final length in <Object?>[
      -1,
      '-1',
      -0.5,
      1.5,
      1000001,
      '1000001',
      4294967295,
      double.infinity,
      double.negativeInfinity,
      double.nan,
      null,
      true,
    ]) {
      test('rejects invalid length $length when building a program codec', () {
        expect(
          () {
            final idl = AnchorIdlProgram.parse({
              'types': [
                {
                  'name': 'Values',
                  'type': {
                    'kind': 'struct',
                    'fields': [
                      {
                        'name': 'values',
                        'type': {
                          'array': ['u8', length],
                        },
                      },
                    ],
                  },
                },
              ],
            });

            AnchorCoder(idl).codecFor(const AnchorIdlDefined('Values'));
          },
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.name,
              'name',
              'type.array.length',
            ),
          ),
        );
      });
    }

    for (final length in <Object>[0, 4, 4.0, '4', 1000000]) {
      test('accepts valid length $length (${length.runtimeType})', () {
        final array = AnchorIdlType.parse({
          'array': ['u8', length],
        }) as AnchorIdlArray;

        expect(array.length, length is String ? int.parse(length) : length);
      });
    }
  });

  test('rejects non-object documents', () {
    expect(() => AnchorIdlProgram.parse(42), throwsArgumentError);
    expect(
      () => AnchorIdlProgram.parse({
        'instructions': [13],
      }),
      throwsArgumentError,
    );
  });

  test('rejects entries with missing names and error codes', () {
    expect(
      () => AnchorIdlProgram.parse({
        'instructions': [
          <String, Object?>{
            'discriminator': [1, 2, 3, 4, 5, 6, 7, 8],
          },
        ],
      }),
      throwsArgumentError,
    );
    expect(
      () => AnchorIdlProgram.parse({
        'errors': [
          <String, Object?>{'name': 'NameOnly'},
        ],
      }),
      throwsArgumentError,
    );
    expect(
      () => AnchorIdlProgram.parse({
        'types': [
          <String, Object?>{
            'type': {'kind': 'struct'},
          },
        ],
      }),
      throwsArgumentError,
    );
  });
}
