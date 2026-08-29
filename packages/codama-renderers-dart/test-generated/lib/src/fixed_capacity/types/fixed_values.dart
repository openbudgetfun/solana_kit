// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


typedef FixedValues = List<int>;

Encoder<FixedValues> getFixedValuesEncoder() {
  return fixEncoderSize(getArrayEncoder(transformEncoder(getU8Encoder(), (int value) => value), size: RemainderArraySize()), 4, allowTruncation: false);
}

Decoder<FixedValues> getFixedValuesDecoder() {
  return fixDecoderSize(getArrayDecoder(getU8Decoder(), size: RemainderArraySize()), 4);
}

Codec<FixedValues, FixedValues> getFixedValuesCodec() {
  return combineCodec(getFixedValuesEncoder(), getFixedValuesDecoder());
}
