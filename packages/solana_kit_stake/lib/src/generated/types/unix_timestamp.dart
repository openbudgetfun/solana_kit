// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

/// A Unix timestamp.
typedef UnixTimestamp = BigInt;

/// Returns the encoder for [UnixTimestamp].
Encoder<UnixTimestamp> getUnixTimestampEncoder() => getI64Encoder();

/// Returns the decoder for [UnixTimestamp].
Decoder<UnixTimestamp> getUnixTimestampDecoder() => getI64Decoder();

/// Returns the codec for [UnixTimestamp].
Codec<UnixTimestamp, UnixTimestamp> getUnixTimestampCodec() =>
    combineCodec(getUnixTimestampEncoder(), getUnixTimestampDecoder());
