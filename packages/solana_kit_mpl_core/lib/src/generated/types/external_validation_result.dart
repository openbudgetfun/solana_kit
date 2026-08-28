// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum ExternalValidationResult {
  approved,
  rejected,
  pass,
}

Encoder<ExternalValidationResult> getExternalValidationResultEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (ExternalValidationResult value) => value.index,
  );
}

Decoder<ExternalValidationResult> getExternalValidationResultDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) =>
        ExternalValidationResult.values[value],
  );
}

Codec<ExternalValidationResult, ExternalValidationResult>
getExternalValidationResultCodec() {
  return combineCodec(
    getExternalValidationResultEncoder(),
    getExternalValidationResultDecoder(),
  );
}
