// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class ResumeData {
  const ResumeData({
    required this.expectedExpiresAtTs,
  });

  final BigInt expectedExpiresAtTs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeData &&
          runtimeType == other.runtimeType &&
          expectedExpiresAtTs == other.expectedExpiresAtTs;

  @override
  int get hashCode => expectedExpiresAtTs.hashCode;

  @override
  String toString() => 'ResumeData(expectedExpiresAtTs: $expectedExpiresAtTs)';
}

Encoder<ResumeData> getResumeDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('expectedExpiresAtTs', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ResumeData value) => <String, Object?>{
      'expectedExpiresAtTs': value.expectedExpiresAtTs,
    },
  );
}

Decoder<ResumeData> getResumeDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('expectedExpiresAtTs', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ResumeData(
      expectedExpiresAtTs: map['expectedExpiresAtTs']! as BigInt,
    ),
  );
}

Codec<ResumeData, ResumeData> getResumeDataCodec() {
  return combineCodec(getResumeDataEncoder(), getResumeDataDecoder());
}
