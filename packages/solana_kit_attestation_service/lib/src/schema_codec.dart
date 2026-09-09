import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_attestation_service/src/generated/accounts/schema.dart';
import 'package:solana_kit_attestation_service/src/generated/types/schema_data_type.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

/// The decoded field values of an Attestation's data blob, keyed by field
/// name.
typedef AttestationData = Map<String, Object>;

/// Decodes a Schema's `name` or `description` blob as UTF-8 text.
///
/// The on-chain program stores these blobs as plain UTF-8 bytes. Malformed
/// bytes surface as replacement characters rather than throwing, mirroring
/// the upstream TypeScript client: these fields are display text, and the
/// program does not validate their encoding. The generated account codec
/// removes the blobs' u32 length prefix, so [bytes] holds the raw content.
String decodeSchemaText(Uint8List bytes) {
  return utf8.decode(bytes, allowMalformed: true);
}

/// Decodes a Schema's `fieldNames` blob into its field names.
///
/// The blob holds a run of u32-length-prefixed UTF-8 strings. The generated
/// account codec removes the blob's outer u32 length prefix, so [bytes]
/// holds the raw content.
///
/// Unlike [decodeSchemaText], decoding is strict and throws a
/// [FormatException] on malformed UTF-8: field names become the keys of
/// attestation data maps, and a silently corrupted key would strand the
/// values stored under it. The house `getUtf8Decoder` rejects malformed
/// bytes for the same reason.
List<String> decodeSchemaFieldNames(Uint8List bytes) {
  final stringDecoder = addDecoderSizePrefix(
    getUtf8Decoder(),
    getU32Decoder(),
  );
  final names = <String>[];
  var offset = 0;
  while (offset < bytes.length) {
    final (name, next) = stringDecoder.read(bytes, offset);
    names.add(name);
    offset = next;
  }
  return names;
}

/// Decodes a Schema's `layout` blob into its declared data types.
///
/// The blob holds one `SchemaDataType` discriminant per field. The
/// generated account codec removes the blob's u32 length prefix, so [bytes]
/// holds the raw content.
List<SchemaDataType> decodeSchemaLayout(Uint8List bytes) {
  return [
    for (final byte in bytes)
      if (byte < SchemaDataType.values.length)
        SchemaDataType.values[byte]
      else
        throw FormatException(
          'Unknown schema data type discriminant: $byte',
        ),
  ];
}

/// Builds a codec for an Attestation's `data` blob from the schema it
/// conforms to.
///
/// The codec maps each field name declared by [schema] to the codec of its
/// declared [SchemaDataType], matching the byte layout the on-chain program
/// validates against: numbers are little-endian, a `char` is a 4-byte
/// Unicode code point, strings are u32-length-prefixed UTF-8, and every vec
/// carries a u32 element count.
///
/// Encoding rejects maps whose keys do not exactly match the schema: a
/// missing field would silently produce an attestation the program rejects,
/// and an unknown field would be dropped from the blob without a trace.
Codec<AttestationData, AttestationData> getAttestationDataCodec(
  Schema schema,
) {
  final fieldNames = decodeSchemaFieldNames(schema.fieldNames);
  final layout = decodeSchemaLayout(schema.layout);
  if (fieldNames.length != layout.length) {
    throw ArgumentError('Schema field names and layout do not match');
  }

  final fields = <(String, Encoder<Object?>, Decoder<Object?>)>[];
  for (var i = 0; i < fieldNames.length; i++) {
    final (fieldEncoder, fieldDecoder) = _getFieldCodec(layout[i]);
    fields.add((fieldNames[i], fieldEncoder, fieldDecoder));
  }

  AttestationData alignWithSchema(Map<String, Object?> data) {
    _requireSameKeys(data.keys, fieldNames);
    return AttestationData.from(data);
  }

  final encoder = transformEncoder<Map<String, Object?>, AttestationData>(
    getStructEncoder(<(String, Encoder<Object?>)>[
      for (final (name, fieldEncoder, _) in fields) (name, fieldEncoder),
    ]),
    alignWithSchema,
  );
  final decoder = transformDecoder<Map<String, Object?>, AttestationData>(
    getStructDecoder(<(String, Decoder<Object?>)>[
      for (final (name, _, fieldDecoder) in fields) (name, fieldDecoder),
    ]),
    (value, _, _) => AttestationData.from(value),
  );

  return combineCodec(encoder, decoder);
}

/// Throws unless the data map's keys exactly match the schema's field
/// names.
void _requireSameKeys(
  Iterable<String> keys,
  List<String> fieldNames,
) {
  final declared = Set<String>.of(fieldNames);
  final provided = Set<String>.of(keys);
  for (final name in fieldNames) {
    if (!provided.contains(name)) {
      throw ArgumentError(
        "Schema field '$name' is missing from the attestation data; "
        'expected fields: ${fieldNames.join(', ')}',
      );
    }
  }
  for (final key in provided) {
    if (!declared.contains(key)) {
      throw ArgumentError(
        "Unknown attestation data field '$key'; "
        'the schema declares: ${fieldNames.join(', ')}',
      );
    }
  }
}

/// Serializes [data] to the byte blob stored on an Attestation account.
Uint8List serializeAttestationData(Schema schema, AttestationData data) {
  return getAttestationDataCodec(schema).encode(data);
}

/// Deserializes the `data` blob of an Attestation account into its field
/// values.
AttestationData deserializeAttestationData(Schema schema, Uint8List bytes) {
  return getAttestationDataCodec(schema).decode(bytes);
}

(Encoder<Object?>, Decoder<Object?>) _getFieldCodec(SchemaDataType type) {
  return switch (type) {
    SchemaDataType.u8 => (
      _widenEncoder(getU8Encoder()),
      _widenDecoder(getU8Decoder()),
    ),
    SchemaDataType.u16 => (
      _widenEncoder(getU16Encoder()),
      _widenDecoder(getU16Decoder()),
    ),
    SchemaDataType.u32 => (
      _widenEncoder(getU32Encoder()),
      _widenDecoder(getU32Decoder()),
    ),
    SchemaDataType.u64 => (
      _widenEncoder(getU64Encoder()),
      _widenDecoder(getU64Decoder()),
    ),
    SchemaDataType.u128 => (
      _widenEncoder(getU128Encoder()),
      _widenDecoder(getU128Decoder()),
    ),
    SchemaDataType.i8 => (
      _widenEncoder(getI8Encoder()),
      _widenDecoder(getI8Decoder()),
    ),
    SchemaDataType.i16 => (
      _widenEncoder(getI16Encoder()),
      _widenDecoder(getI16Decoder()),
    ),
    SchemaDataType.i32 => (
      _widenEncoder(getI32Encoder()),
      _widenDecoder(getI32Decoder()),
    ),
    SchemaDataType.i64 => (
      _widenEncoder(getI64Encoder()),
      _widenDecoder(getI64Decoder()),
    ),
    SchemaDataType.i128 => (
      _widenEncoder(getI128Encoder()),
      _widenDecoder(getI128Decoder()),
    ),
    SchemaDataType.bool => (
      _widenEncoder(getBooleanEncoder()),
      _widenDecoder(getBooleanDecoder()),
    ),
    SchemaDataType.char => (
      _widenEncoder(_getCharEncoder()),
      _widenDecoder(_getCharDecoder()),
    ),
    SchemaDataType.string => (
      _widenEncoder(_getStringEncoder()),
      _widenDecoder(_getStringDecoder()),
    ),
    SchemaDataType.vecU8 => (
      _widenEncoder(getArrayEncoder(getU8Encoder())),
      _widenDecoder(getArrayDecoder(getU8Decoder())),
    ),
    SchemaDataType.vecU16 => (
      _widenEncoder(getArrayEncoder(getU16Encoder())),
      _widenDecoder(getArrayDecoder(getU16Decoder())),
    ),
    SchemaDataType.vecU32 => (
      _widenEncoder(getArrayEncoder(getU32Encoder())),
      _widenDecoder(getArrayDecoder(getU32Decoder())),
    ),
    SchemaDataType.vecU64 => (
      _widenEncoder(getArrayEncoder(getU64Encoder())),
      _widenDecoder(getArrayDecoder(getU64Decoder())),
    ),
    SchemaDataType.vecU128 => (
      _widenEncoder(getArrayEncoder(getU128Encoder())),
      _widenDecoder(getArrayDecoder(getU128Decoder())),
    ),
    SchemaDataType.vecI8 => (
      _widenEncoder(getArrayEncoder(getI8Encoder())),
      _widenDecoder(getArrayDecoder(getI8Decoder())),
    ),
    SchemaDataType.vecI16 => (
      _widenEncoder(getArrayEncoder(getI16Encoder())),
      _widenDecoder(getArrayDecoder(getI16Decoder())),
    ),
    SchemaDataType.vecI32 => (
      _widenEncoder(getArrayEncoder(getI32Encoder())),
      _widenDecoder(getArrayDecoder(getI32Decoder())),
    ),
    SchemaDataType.vecI64 => (
      _widenEncoder(getArrayEncoder(getI64Encoder())),
      _widenDecoder(getArrayDecoder(getI64Decoder())),
    ),
    SchemaDataType.vecI128 => (
      _widenEncoder(getArrayEncoder(getI128Encoder())),
      _widenDecoder(getArrayDecoder(getI128Decoder())),
    ),
    SchemaDataType.vecBool => (
      _widenEncoder(getArrayEncoder(getBooleanEncoder())),
      _widenDecoder(getArrayDecoder(getBooleanDecoder())),
    ),
    SchemaDataType.vecChar => (
      _widenEncoder(getArrayEncoder(_getCharEncoder())),
      _widenDecoder(getArrayDecoder(_getCharDecoder())),
    ),
    SchemaDataType.vecString => (
      _widenEncoder(getArrayEncoder(_getStringEncoder())),
      _widenDecoder(getArrayDecoder(_getStringDecoder())),
    ),
  };
}

/// Lifts a concretely typed encoder so it can hold a place in a dynamic
/// field map.
Encoder<Object?> _widenEncoder<T extends Object>(Encoder<T> encoder) {
  T passthrough(Object? value) => value! as T;
  return transformEncoder<T, Object?>(encoder, passthrough);
}

/// Lifts a concretely typed decoder so it can hold a place in a dynamic
/// field map.
Decoder<Object?> _widenDecoder<T extends Object>(Decoder<T> decoder) {
  Object? passthrough(T value, Uint8List bytes, int offset) => value;
  return transformDecoder<T, Object?>(decoder, passthrough);
}

Encoder<String> _getCharEncoder() {
  return transformEncoder<num, String>(
    getU32Encoder(),
    _charToCodePoint,
  );
}

Decoder<String> _getCharDecoder() {
  String decode(int codePoint, Uint8List _, int _) {
    return _codePointToChar(codePoint);
  }

  return transformDecoder<int, String>(getU32Decoder(), decode);
}

Encoder<String> _getStringEncoder() {
  return transformEncoder<Uint8List, String>(
    addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    utf8.encode,
  );
}

Decoder<String> _getStringDecoder() {
  String decode(Uint8List bytes, Uint8List _, int _) {
    return _decodeStringBytes(bytes);
  }

  return transformDecoder<Uint8List, String>(
    addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    decode,
  );
}

/// A Rust `char` holds a Unicode scalar value: at most U+10FFFF and never a
/// surrogate. Values outside that range have no character to map to.
bool _isUnicodeScalarValue(int codePoint) {
  return codePoint <= 0x10ffff && (codePoint < 0xd800 || codePoint > 0xdfff);
}

/// Rust encodes a `char` as its 4-byte little-endian Unicode code point.
int _charToCodePoint(String value) {
  final runes = value.runes.toList();
  if (runes.length != 1 ||
      !_isUnicodeScalarValue(runes.single) ||
      String.fromCharCode(runes.single) != value) {
    throw ArgumentError.value(
      value,
      'char',
      'Char fields must hold exactly one Unicode character',
    );
  }
  return runes.single;
}

String _codePointToChar(int codePoint) {
  if (!_isUnicodeScalarValue(codePoint)) {
    throw FormatException(
      'Char field holds $codePoint, which is not a Unicode character',
    );
  }
  return String.fromCharCode(codePoint);
}

/// Attestations in the wild store raw binary (hashes, ciphertext) in fields a
/// schema declares as strings. Decoding is therefore strict, and bytes that
/// are not valid UTF-8 are surfaced losslessly as a `0x`-prefixed hex string
/// instead of silently producing replacement characters. Encoding is always
/// UTF-8: a hex string produced by this fallback is text like any other and
/// will be written back out as its literal characters.
String _decodeStringBytes(Uint8List bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '0x$hex';
  }
}
