import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_strings/src/base_x.dart';

const String _alphabet = '0123456789';

/// Returns an encoder for base-10 strings.
///
/// This encoder serializes strings using a base-10 encoding scheme.
/// The output consists of bytes representing the numerical values of the
/// input string.
///
/// For more details, see [getBase10Codec].
VariableSizeEncoder<String> getBase10Encoder() => getBaseXEncoder(_alphabet);

/// Returns a decoder for base-10 strings.
///
/// This decoder deserializes base-10 encoded strings from a byte array.
///
/// For more details, see [getBase10Codec].
VariableSizeDecoder<String> getBase10Decoder() => getBaseXDecoder(_alphabet);

/// Returns a codec for encoding and decoding base-10 strings.
///
/// This codec serializes strings using a base-10 encoding scheme. The
/// output consists of bytes representing the numerical values of the input
/// string.
VariableSizeCodec<String, String> getBase10Codec() => getBaseXCodec(_alphabet);
