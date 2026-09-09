import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_attestation_service/solana_kit_attestation_service.dart';
import 'package:test/test.dart';

/// The bytes the Schema account stores for a text blob (its content only;
/// the account codec removes the outer u32 length prefix).
Uint8List content(List<int> bytes) => Uint8List.fromList(bytes);

/// Builds the field-names blob content: a run of u32-length-prefixed UTF-8
/// strings.
Uint8List fieldNamesContent(List<String> names) {
  final bytes = <int>[];
  for (final name in names) {
    final encoded = utf8.encode(name);
    final length = encoded.length;
    bytes.addAll([
      length & 0xff,
      (length >> 8) & 0xff,
      (length >> 16) & 0xff,
      (length >> 24) & 0xff,
      ...encoded,
    ]);
  }
  return Uint8List.fromList(bytes);
}

Schema makeSchema(List<SchemaDataType> layout, List<String> fieldNames) {
  return Schema(
    discriminator: 1,
    credential: const Address('11111111111111111111111111111111'),
    name: content(utf8.encode('test')),
    description: content(utf8.encode('test')),
    layout: content(layout.map((type) => type.index).toList()),
    fieldNames: fieldNamesContent(fieldNames),
    isPaused: false,
    version: 1,
  );
}

Schema makeSchemaWithBlobs({
  required Uint8List name,
  required Uint8List description,
  required Uint8List layout,
  required Uint8List fieldNames,
}) {
  return Schema(
    discriminator: 1,
    credential: const Address('11111111111111111111111111111111'),
    name: name,
    description: description,
    layout: layout,
    fieldNames: fieldNames,
    isPaused: false,
    version: 1,
  );
}

void main() {
  group('decodeSchemaText', () {
    test('decodes utf-8 content bytes', () {
      expect(decodeSchemaText(content(utf8.encode('hello'))), equals('hello'));
    });

    test('replaces malformed utf-8 bytes instead of throwing', () {
      expect(
        decodeSchemaText(content([0xff, 0xfe])),
        equals('\u{FFFD}\u{FFFD}'),
      );
    });
  });

  group('decodeSchemaFieldNames', () {
    test('decodes a run of length-prefixed strings', () {
      expect(
        decodeSchemaFieldNames(fieldNamesContent(['name', 'location'])),
        equals(['name', 'location']),
      );
    });

    test('decodes an empty run', () {
      expect(decodeSchemaFieldNames(Uint8List(0)), isEmpty);
    });

    test('rejects malformed utf-8 bytes in field names', () {
      // A u32 prefix promising one byte, holding an invalid continuation.
      expect(
        () => decodeSchemaFieldNames(content([1, 0, 0, 0, 0xff])),
        throwsFormatException,
      );
    });
  });

  group('decodeSchemaLayout', () {
    test('decodes a run of discriminants', () {
      expect(
        decodeSchemaLayout(content([12, 0, 25])),
        equals([
          SchemaDataType.string,
          SchemaDataType.u8,
          SchemaDataType.vecString,
        ]),
      );
    });
  });

  group('getAttestationDataCodec', () {
    test('round trips data for a schema decoded from account bytes', () {
      final schema = makeSchema(
        [SchemaDataType.string, SchemaDataType.u8],
        [
          'name',
          'location',
        ],
      );
      final codec = getAttestationDataCodec(schema);
      final data = <String, Object>{'name': 'hello', 'location': 10};

      final serialized = codec.encode(data);
      expect(
        serialized,
        equals(
          Uint8List.fromList([
            5, 0, 0, 0, 104, 101, 108, 108, 111, 10, //
          ]),
        ),
      );
      expect(codec.decode(serialized), equals(data));
    });

    test('matches the byte layout the program validates against', () {
      final schema = makeSchema(
        [
          SchemaDataType.u8,
          SchemaDataType.vecString,
          SchemaDataType.u128,
        ],
        [
          'count',
          'tags',
          'big',
        ],
      );
      final data = <String, Object>{
        'count': 10,
        'tags': ['test1', 'test2'],
        'big': BigInt.from(199),
      };

      final serialized = serializeAttestationData(schema, data);
      expect(
        serialized,
        equals(
          Uint8List.fromList([
            10, //
            2, 0, 0, 0, // Vec<String> length
            5, 0, 0, 0, 116, 101, 115, 116, 49, // "test1"
            5, 0, 0, 0, 116, 101, 115, 116, 50, // "test2"
            199, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 199u128
          ]),
        ),
      );
      expect(deserializeAttestationData(schema, serialized), equals(data));
    });

    test('encodes char as a 4 byte little-endian code point', () {
      final schema = makeSchema(
        [SchemaDataType.char, SchemaDataType.vecChar],
        [
          'grade',
          'grades',
        ],
      );
      final data = <String, Object>{
        'grade': 'A',
        'grades': ['B', 'C'],
      };

      final serialized = serializeAttestationData(schema, data);
      expect(
        serialized,
        equals(
          Uint8List.fromList([
            65, 0, 0, 0, //
            2, 0, 0, 0, //
            66, 0, 0, 0, //
            67, 0, 0, 0, //
          ]),
        ),
      );
      expect(deserializeAttestationData(schema, serialized), equals(data));
    });

    test('round trips every supported layout type', () {
      final schema = makeSchema(
        [
          SchemaDataType.u8, SchemaDataType.u16, SchemaDataType.u32, //
          SchemaDataType.u64, SchemaDataType.u128, SchemaDataType.i8, //
          SchemaDataType.i16, SchemaDataType.i32, SchemaDataType.i64, //
          SchemaDataType.i128, SchemaDataType.bool, SchemaDataType.char, //
          SchemaDataType.string, SchemaDataType.vecU8, SchemaDataType.vecU16, //
          SchemaDataType.vecU32,
          SchemaDataType.vecU64,
          SchemaDataType.vecU128, //
          SchemaDataType.vecI8, SchemaDataType.vecI16, SchemaDataType.vecI32, //
          SchemaDataType.vecI64,
          SchemaDataType.vecI128,
          SchemaDataType.vecBool, //
          SchemaDataType.vecChar, SchemaDataType.vecString,
        ],
        [
          'u8',
          'u16',
          'u32',
          'u64',
          'u128',
          'i8',
          'i16',
          'i32',
          'i64',
          'i128', //
          'bool', 'char', 'string', 'vecU8', 'vecU16', 'vecU32', 'vecU64', //
          'vecU128', 'vecI8', 'vecI16', 'vecI32', 'vecI64', 'vecI128', //
          'vecBool', 'vecChar', 'vecString',
        ],
      );
      final data = <String, Object>{
        'u8': 1,
        'u16': 2,
        'u32': 3,
        'u64': BigInt.from(4),
        'u128': BigInt.from(5),
        'i8': -1,
        'i16': -2,
        'i32': -3,
        'i64': BigInt.from(-4),
        'i128': BigInt.from(-5),
        'bool': true,
        'char': '🔥',
        'string': 'hello',
        'vecU8': [1, 2],
        'vecU16': [3, 4],
        'vecU32': [5, 6],
        'vecU64': [BigInt.from(7), BigInt.from(8)],
        'vecU128': [BigInt.from(9), BigInt.from(10)],
        'vecI8': [-1, -2],
        'vecI16': [-3, -4],
        'vecI32': [-5, -6],
        'vecI64': [BigInt.from(-7), BigInt.from(-8)],
        'vecI128': [BigInt.from(-9), BigInt.from(-10)],
        'vecBool': [true, false],
        'vecChar': ['a', 'b'],
        'vecString': ['x', 'y'],
      };

      final serialized = serializeAttestationData(schema, data);
      expect(deserializeAttestationData(schema, serialized), equals(data));
    });

    test('decodes non-utf-8 string bytes as a hex string', () {
      final hashBytes = Uint8List.fromList(
        [0xf5, 0x4f, 0x22, 0x80, 0x7c, 0xff],
      );
      final data = Uint8List.fromList([
        hashBytes.length, 0, 0, 0, //
        ...hashBytes,
      ]);

      final decoded = deserializeAttestationData(
        makeSchema([SchemaDataType.string], ['id']),
        data,
      );

      expect(decoded['id'], equals('0xf54f22807cff'));
    });

    test('decodes valid utf-8 string bytes as text', () {
      final text = utf8.encode('héllo');
      final data = Uint8List.fromList([
        text.length, 0, 0, 0, //
        ...text,
      ]);

      final decoded = deserializeAttestationData(
        makeSchema([SchemaDataType.string], ['id']),
        data,
      );

      expect(decoded['id'], equals('héllo'));
    });

    test('names the missing field when encoding incomplete data', () {
      final schema = makeSchema(
        [SchemaDataType.u8, SchemaDataType.string],
        [
          'count',
          'label',
        ],
      );

      expect(
        () => serializeAttestationData(schema, {'count': 1}),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains("Schema field 'label' is missing"),
          ),
        ),
      );
    });

    test('rejects fields the schema does not declare', () {
      final schema = makeSchema([SchemaDataType.u8], ['count']);

      expect(
        () => serializeAttestationData(schema, {
          'count': 1,
          'extra': 'dropped silently if unchecked',
        }),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains("Unknown attestation data field 'extra'"),
          ),
        ),
      );
    });

    test('throws when field names and layout lengths disagree', () {
      expect(
        () => getAttestationDataCodec(
          makeSchema([SchemaDataType.u8, SchemaDataType.u8], ['only_one']),
        ),
        throwsArgumentError,
      );
    });

    test('throws when the layout blob holds an unknown discriminant', () {
      expect(
        () => getAttestationDataCodec(
          makeSchemaWithBlobs(
            name: content([0]),
            description: content([0]),
            layout: content([26]),
            fieldNames: fieldNamesContent(['mystery']),
          ),
        ),
        throwsFormatException,
      );
    });
  });

  group('char fields', () {
    test('rejects char data that is not a unicode character', () {
      final schema = makeSchema([SchemaDataType.char], ['grade']);

      for (final codePoint in [0x110000, 0xffffffff, 0xd800, 0xdfff]) {
        final encoded = Uint8List.fromList([
          codePoint & 0xff,
          (codePoint >> 8) & 0xff,
          (codePoint >> 16) & 0xff,
          (codePoint >> 24) & 0xff,
        ]);
        expect(
          () => deserializeAttestationData(schema, encoded),
          throwsFormatException,
          reason:
              'code point 0x${codePoint.toRadixString(16)} must be rejected',
        );
      }
    });

    test('rejects char values that cannot round trip through rust', () {
      final schema = makeSchema([SchemaDataType.char], ['grade']);

      for (final character in ['', 'ab', '\u{D800}']) {
        expect(
          () => serializeAttestationData(schema, {'grade': character}),
          throwsArgumentError,
          reason: '"$character" must be rejected',
        );
      }
    });
  });
}
