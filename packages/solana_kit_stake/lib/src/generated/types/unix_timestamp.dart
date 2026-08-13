// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

typedef UnixTimestamp = BigInt;

Encoder<UnixTimestamp> getUnixTimestampEncoder() {
  return getI64Encoder();
}

Decoder<UnixTimestamp> getUnixTimestampDecoder() {
  return getI64Decoder();
}

Codec<UnixTimestamp, UnixTimestamp> getUnixTimestampCodec() {
  return combineCodec(getUnixTimestampEncoder(), getUnixTimestampDecoder());
}
