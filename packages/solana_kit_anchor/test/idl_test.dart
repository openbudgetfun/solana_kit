import 'dart:io';

import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

void main() {
  final fixtureJson = File('test/fixtures/idl.json').readAsStringSync();

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

    final option =
        AnchorIdlType.parse(<String, Object?>{'option': 'u64'})
            as AnchorIdlOption;
    expect(option.prefix, 1);
    expect(option.inner, AnchorIdlPrimitive.u64);

    final array =
        AnchorIdlType.parse(<String, Object?>{
              'array': ['u8', '4'],
            })
            as AnchorIdlArray;
    expect(array.length, 4);
  });

  test('module-path names map onto their last segment', () {
    expect(typeNameOf('idl::some_module::NamedStruct'), 'NamedStruct');
    expect(typeNameOf('Plain'), 'Plain');
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
}
