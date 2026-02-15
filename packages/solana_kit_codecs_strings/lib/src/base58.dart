import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_strings/src/base_x.dart';

const String _alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// Returns an encoder for base-58 strings.
///
/// This encoder serializes strings using a base-58 encoding scheme,
/// commonly used in cryptocurrency addresses and other compact
/// representations.
///
/// For more details, see [getBase58Codec].
VariableSizeEncoder<String> getBase58Encoder() => getBaseXEncoder(_alphabet);

/// Returns a decoder for base-58 strings.
///
/// This decoder deserializes base-58 encoded strings from a byte array.
///
/// For more details, see [getBase58Codec].
VariableSizeDecoder<String> getBase58Decoder() => getBaseXDecoder(_alphabet);

/// Returns a codec for encoding and decoding base-58 strings.
///
/// This codec serializes strings using a base-58 encoding scheme,
/// commonly used in cryptocurrency addresses and other compact
/// representations.
VariableSizeCodec<String, String> getBase58Codec() => getBaseXCodec(_alphabet);
