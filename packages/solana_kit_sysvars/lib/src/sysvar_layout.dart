import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

/// A map of field names to their encoded values used by struct codecs.
typedef StructuredFields = Map<String, Object?>;

/// Creates a fixed-size encoder that converts a value into structured fields
/// before writing them with the provided struct encoder.
FixedSizeEncoder<T> mapFixedSizeStructEncoder<T>({
  required int fixedSize,
  required FixedSizeEncoder<StructuredFields> structEncoder,
  required StructuredFields Function(T value) toFields,
}) {
  return FixedSizeEncoder<T>(
    fixedSize: fixedSize,
    write: (value, bytes, offset) {
      return structEncoder.write(toFields(value), bytes, offset);
    },
  );
}

/// Creates a fixed-size decoder that reads structured fields with the provided
/// struct decoder and maps them back into a value.
FixedSizeDecoder<T> mapFixedSizeStructDecoder<T>({
  required int fixedSize,
  required FixedSizeDecoder<StructuredFields> structDecoder,
  required T Function(StructuredFields fields) fromFields,
}) {
  return FixedSizeDecoder<T>(
    fixedSize: fixedSize,
    read: (bytes, offset) {
      final (fields, newOffset) = structDecoder.read(bytes, offset);
      return (fromFields(fields), newOffset);
    },
  );
}

/// Creates a fixed-size codec that combines the matching fixed-size struct
/// encoder and decoder for symmetric encoding and decoding.
FixedSizeCodec<T, T> mapFixedSizeStructCodec<T>({
  required int fixedSize,
  required FixedSizeEncoder<StructuredFields> structEncoder,
  required FixedSizeDecoder<StructuredFields> structDecoder,
  required StructuredFields Function(T value) toFields,
  required T Function(StructuredFields fields) fromFields,
}) {
  return combineCodec(
        mapFixedSizeStructEncoder(
          fixedSize: fixedSize,
          structEncoder: structEncoder,
          toFields: toFields,
        ),
        mapFixedSizeStructDecoder(
          fixedSize: fixedSize,
          structDecoder: structDecoder,
          fromFields: fromFields,
        ),
      )
      as FixedSizeCodec<T, T>;
}

/// Computes a stable hash for the given structured fields.
int hashStructuredFields(Iterable<Object?> fields) => Object.hashAll(fields);

/// Formats the given structured fields as a human-readable
/// `typeName(key: value, ...)` string.
String formatStructuredFields(String typeName, StructuredFields fields) {
  final entries = fields.entries.map((entry) => '${entry.key}: ${entry.value}');
  return '$typeName(${entries.join(', ')})';
}
