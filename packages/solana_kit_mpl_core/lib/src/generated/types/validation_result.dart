// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum ValidationResult {
  approved,
  rejected,
  pass,
  forceApproved,
}

Encoder<ValidationResult> getValidationResultEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (ValidationResult value) => value.index,
  );
}

Decoder<ValidationResult> getValidationResultDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => ValidationResult.values[value],
  );
}

Codec<ValidationResult, ValidationResult> getValidationResultCodec() {
  return combineCodec(
    getValidationResultEncoder(),
    getValidationResultDecoder(),
  );
}
