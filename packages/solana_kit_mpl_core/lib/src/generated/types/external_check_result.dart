// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class ExternalCheckResult {
  const ExternalCheckResult({
    required this.flags,
  });

  final int flags;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalCheckResult &&
          runtimeType == other.runtimeType &&
          flags == other.flags;

  @override
  int get hashCode => flags.hashCode;

  @override
  String toString() => 'ExternalCheckResult(flags: $flags)';
}

Encoder<ExternalCheckResult> getExternalCheckResultEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('flags', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ExternalCheckResult value) => <String, Object?>{
      'flags': value.flags,
    },
  );
}

Decoder<ExternalCheckResult> getExternalCheckResultDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('flags', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        ExternalCheckResult(
          flags: map['flags']! as int,
        ),
  );
}

Codec<ExternalCheckResult, ExternalCheckResult> getExternalCheckResultCodec() {
  return combineCodec(
    getExternalCheckResultEncoder(),
    getExternalCheckResultDecoder(),
  );
}
