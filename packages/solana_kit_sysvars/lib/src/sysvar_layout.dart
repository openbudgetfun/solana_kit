// ignore_for_file: public_member_api_docs
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

typedef StructuredFields = Map<String, Object?>;

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

int hashStructuredFields(Iterable<Object?> fields) => Object.hashAll(fields);

String formatStructuredFields(String typeName, StructuredFields fields) {
  final entries = fields.entries.map((entry) => '${entry.key}: ${entry.value}');
  return '$typeName(${entries.join(', ')})';
}
