// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

/// A Solana epoch.
typedef Epoch = BigInt;

/// Returns the encoder for [Epoch].
Encoder<Epoch> getEpochEncoder() => getU64Encoder();

/// Returns the decoder for [Epoch].
Decoder<Epoch> getEpochDecoder() => getU64Decoder();

/// Returns the codec for [Epoch].
Codec<Epoch, Epoch> getEpochCodec() =>
    combineCodec(getEpochEncoder(), getEpochDecoder());
