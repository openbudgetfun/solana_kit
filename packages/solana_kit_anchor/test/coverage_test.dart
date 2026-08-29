import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_anchor/solana_kit_anchor.dart';
import 'package:test/test.dart';

const Address _wallet = Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS');

/// One instruction exercising every supported primitive and compound
/// argument type.
const Map<String, Object?> _kitchenSinkIdl = {
  'address': 'Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS',
  'metadata': {'name': 'kitchen'},
  'instructions': [
    <String, Object?>{
      'name': 'kitchen_sink',
      'discriminator': [93, 250, 107, 196, 35, 69, 26, 202],
      'args': [
        {'name': 'flag', 'type': 'bool'},
        {'name': 'u8', 'type': 'u8'},
        {'name': 'u16', 'type': 'u16'},
        {'name': 'u32', 'type': 'u32'},
        {'name': 'u64', 'type': 'u64'},
        {'name': 'u128', 'type': 'u128'},
        {'name': 'i8', 'type': 'i8'},
        {'name': 'i16', 'type': 'i16'},
        {'name': 'i32', 'type': 'i32'},
        {'name': 'i64', 'type': 'i64'},
        {'name': 'i128', 'type': 'i128'},
        {'name': 'f32', 'type': 'f32'},
        {'name': 'f64', 'type': 'f64'},
        {'name': 'text', 'type': 'string'},
        {'name': 'wallet', 'type': 'pubkey'},
        {
          'name': 'nums',
          'type': {'vec': 'u32'},
        },
        {
          'name': 'fixed',
          'type': {
            'array': ['u8', 3],
          },
        },
        {
          'name': 'some',
          'type': {'option': 'u8'},
        },
        {
          'name': 'none',
          'type': {'option': 'u8'},
        },
        {'name': 'chunk', 'type': 'bytes'},
      ],
    },
  ],
  'accounts': [],
  'events': [],
  'errors': [
    {'code': 7000, 'name': 'NoMessage'},
  ],
  'types': [],
};

Map<String, Object?> _kitchenSinkValues() => {
  'flag': true,
  'u8': 255,
  'u16': 0x1234,
  'u32': 0x12345,
  'u64': BigInt.from(16960),
  'u128': (BigInt.one << 128) - BigInt.one,
  'i8': -128,
  'i16': -32768,
  'i32': -1234,
  'i64': BigInt.one,
  'i128': -BigInt.one,
  'f32': 2.5,
  'f64': -1.25,
  'text': 'anchor',
  'wallet': _wallet,
  'nums': [1, 2, 3],
  'fixed': [9, 8, 7],
  'some': 42,
  'none': null,
  'chunk': [1, 2, 3],
};

void main() {
  final idl = AnchorIdlProgram.parse(_kitchenSinkIdl);
  final coder = AnchorCoder(idl);
  final encoded = coder.encodeInstructionData(
    'kitchen_sink',
    _kitchenSinkValues(),
  );

  test('kitchen-sink instruction matches the borsh byte vector', () {
    const expected =
        '5dfa6bc423451aca01ff3412452301004042000000000000ffffffffffffffffffffffffffffffff8000802efbffff0100000000000000ffffffffffffffffffffffffffffffff00002040000000000000f4bf06000000616e63686f72da075cb2ff5ec6817613de530b692a8735477769da47430cbd8154335c4a832703000000010000000200000003000000090807012a0003000000010203';
    expect(
      encoded.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(),
      expected,
    );
  });

  test('decodeInstructionData round-trips the kitchen sink', () {
    final args = coder.decodeInstructionData('kitchen_sink', encoded);
    expect(args['flag'], true);
    expect(args['u8'], 255);
    expect(args['u16'], 0x1234);
    expect(args['u32'], 0x12345);
    expect(args['u64'], BigInt.from(16960));
    expect(args['u128'], (BigInt.one << 128) - BigInt.one);
    expect(args['i8'], -128);
    expect(args['i16'], -32768);
    expect(args['i32'], -1234);
    expect(args['i64'], BigInt.one);
    expect(args['i128'], -BigInt.one);
    expect(args['f32'], 2.5);
    expect(args['f64'], -1.25);
    expect(args['text'], 'anchor');
    expect(args['wallet'], _wallet);
    expect(args['nums'], [1, 2, 3]);
    expect(args['fixed'], [9, 8, 7]);
    expect(args['some'], 42);
    expect(args['none'], isNull);
    expect(args['chunk'], [1, 2, 3]);
  });

  test('codecFor exposes the runtime codec pair', () {
    final (encoder, decoder) = coder.codecFor(const AnchorIdlBytes());
    final encodedBytes = encoder.encode([1, 2, 3]);
    // `bytes` args are u32-length-prefixed.
    expect(encodedBytes, [3, 0, 0, 0, 1, 2, 3]);
    expect(decoder.decode(encodedBytes), [1, 2, 3]);
  });

  test('empty log sequences yield no events', () {
    expect(coder.decodeEventLogs([]), isEmpty);
  });

  test('anchorProgramError falls back for IDL errors without messages', () {
    final error = anchorProgramError(7000, idl: idl);
    expect(error.name, 'NoMessage');
    expect(error.message, contains('Custom program error'));
    expect(error.toString(), startsWith('AnchorProgramError(7000, NoMessage)'));
  });

  test('AnchorDiscriminatorMismatch has a readable toString', () {
    const mismatch = AnchorDiscriminatorMismatch(
      expected: [1],
      found: [2],
    );
    expect(mismatch.toString(), contains('expected: [1]'));
    expect(mismatch.toString(), contains('found: [2]'));
  });

  test('field parsing surfaces bad shapes when the type is read', () {
    // A map without a type entry falls back to bare-type-node parsing.
    final nameOnly = AnchorIdlField.parse({'name': 'noType'}, 0);
    expect(() => nameOnly.type, throwsArgumentError);
    // Nested unsupported type nodes also surface on type access.
    final badScalar = AnchorIdlField.parse(
      <String, Object?>{'name': 'x', 'type': 'nope'},
      0,
    );
    expect(() => badScalar.type, throwsArgumentError);
  });

  test('enum variant parsing rejects non-object variants', () {
    expect(() => AnchorIdlEnumVariant.parse(42), throwsArgumentError);
  });

  test('toString renders type names', () {
    expect(AnchorIdlPrimitive.u8.toString(), 'u8');
    expect(const AnchorIdlBytes().toString(), 'bytes');
    expect(const AnchorIdlDefined('Thing').toString(), 'Thing');
  });

  test('option prefixes, bare null types, and named fields validate', () {
    // 8-byte option prefixes are rejected.
    expect(
      () => AnchorIdlType.parse(<String, Object?>{
        'option': 'u8',
        'prefix': 8,
      }),
      throwsArgumentError,
    );
    // Non-integer prefixes are rejected too.
    expect(
      () => AnchorIdlType.parse(<String, Object?>{
        'option': 'u8',
        'prefix': 'wide',
      }),
      throwsArgumentError,
    );
    // A named field whose type key is explicitly null is invalid.
    expect(
      () => AnchorIdlField.parse(<String, Object?>{
        'name': 'x',
        'type': null,
      }, 0),
      throwsArgumentError,
    );
    // A defined type whose type key is null is invalid.
    expect(
      () => AnchorIdlProgram.parse(<String, Object?>{
        'types': <Object?>[
          <String, Object?>{'name': 'Empty2'},
        ],
      }),
      throwsArgumentError,
    );
  });

  test('defined types must carry known kinds', () {
    expect(
      () => AnchorIdlProgram.parse(<String, Object?>{
        'types': <Object?>[
          <String, Object?>{
            'name': 'Weird2',
            'type': {'kind': 'mystery'},
          },
        ],
      }),
      throwsArgumentError,
    );
    expect(
      () => AnchorIdlProgram.parse(<String, Object?>{
        'types': <Object?>[
          <String, Object?>{'name': 'Bare'},
        ],
      }),
      throwsArgumentError,
    );
  });

  test('scalar type bodies are not valid defined types', () {
    expect(
      () => AnchorIdlProgram.parse(<String, Object?>{
        'types': <Object?>[
          <String, Object?>{'name': 'Bare', 'type': 'u8'},
        ],
      }),
      throwsArgumentError,
    );
  });

  test('missing definitions throw at codec build time', () {
    expect(
      () => coder.codecFor(const AnchorIdlDefined('Missing')),
      throwsArgumentError,
    );
  });

  test('instruction entries without string names are rejected', () {
    expect(
      () => coder.codecFor(const AnchorIdlDefined('Missing')),
      throwsArgumentError,
    );
    expect(
      () => coder.encodeAccount(
        'Counter'
        '_Missing',
        {},
      ),
      throwsArgumentError,
    );
  });

  test('instruction entries without string names are rejected', () {
    expect(
      () => AnchorIdlProgram.parse({
        'instructions': [
          {'nope': true},
        ],
      }),
      throwsArgumentError,
    );
    expect(
      () => AnchorIdlProgram.parse({
        'instructions': [
          {
            'name': 'x',
            'args': [
              <String, Object?>{
                'name': 'weird',
                'type': {
                  'defined': {'name': 'Nope'},
                },
              },
            ],
          },
        ],
        'types': <Object?>[],
      }),
      returnsNormally,
    );
    final bareArgs = AnchorIdlProgram.parse(<String, Object?>{
      'types': <Object?>[],
      'instructions': <Object?>[
        <String, Object?>{
          'name': 'x',
          'args': <Object?>[13],
        },
      ],
    });
    expect(bareArgs.name, isEmpty);
  });

  test('enum variant fields accept bare non-list shapes', () {
    final idlProgram = AnchorIdlProgram.parse({
      'types': [
        {
          'name': 'WeirdEnum',
          'type': {
            'kind': 'enum',
            'variants': [
              <String, Object?>{
                'name': 'One',
                'fields': <String, Object?>{
                  'defined': {'name': 'Plain'},
                },
              },
            ],
          },
        },
        {
          'name': 'Plain',
          'type': {
            'kind': 'struct',
            'fields': [
              {'name': 'v', 'type': 'u8'},
            ],
          },
        },
      ],
    });
    expect(idlProgram.types['WeirdEnum'], isA<AnchorIdlEnum>());
  });

  test('scalar codecs reject unknown names when constructed directly', () {
    const bogus = AnchorIdlPrimitive('u4096');
    expect(() => coder.codecFor(bogus), throwsArgumentError);
  });
}
