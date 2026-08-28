// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

enum PayloadKey {
  amount,
  authority,
  authoritySeeds,
  delegate,
  delegateSeeds,
  destination,
  destinationSeeds,
  holder,
  source,
  sourceSeeds,
}

Encoder<PayloadKey> getPayloadKeyEncoder() {
  return transformEncoder(
    getU8Encoder(),
    (PayloadKey value) => value.index,
  );
}

Decoder<PayloadKey> getPayloadKeyDecoder() {
  return transformDecoder(
    getU8Decoder(),
    (int value, Uint8List bytes, int offset) => PayloadKey.values[value],
  );
}

Codec<PayloadKey, PayloadKey> getPayloadKeyCodec() {
  return combineCodec(getPayloadKeyEncoder(), getPayloadKeyDecoder());
}
