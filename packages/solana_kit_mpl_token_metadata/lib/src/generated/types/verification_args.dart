// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum VerificationArgs {
  creatorV1,
  collectionV1,
}

Encoder<VerificationArgs> getVerificationArgsEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (VerificationArgs value) => value.index,
  );
}

Decoder<VerificationArgs> getVerificationArgsDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => VerificationArgs.values[value],
  );
}

Codec<VerificationArgs, VerificationArgs> getVerificationArgsCodec() {
  return combineCodec(
    getVerificationArgsEncoder(),
    getVerificationArgsDecoder(),
  );
}
