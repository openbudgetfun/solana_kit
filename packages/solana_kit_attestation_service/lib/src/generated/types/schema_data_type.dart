// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum SchemaDataType {
  u8,
  u16,
  u32,
  u64,
  u128,
  i8,
  i16,
  i32,
  i64,
  i128,
  bool,
  char,
  string,
  vecU8,
  vecU16,
  vecU32,
  vecU64,
  vecU128,
  vecI8,
  vecI16,
  vecI32,
  vecI64,
  vecI128,
  vecBool,
  vecChar,
  vecString,
}

Encoder<SchemaDataType> getSchemaDataTypeEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (SchemaDataType value) => value.index,
  );
}

Decoder<SchemaDataType> getSchemaDataTypeDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => SchemaDataType.values[value],
  );
}

Codec<SchemaDataType, SchemaDataType> getSchemaDataTypeCodec() {
  return combineCodec(getSchemaDataTypeEncoder(), getSchemaDataTypeDecoder());
}
