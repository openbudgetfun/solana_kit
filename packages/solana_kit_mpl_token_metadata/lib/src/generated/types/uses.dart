// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './use_method.dart';

@immutable
class Uses {
  const Uses({
    required this.useMethod,
    required this.remaining,
    required this.total,
  });

  final UseMethod useMethod;
  final BigInt remaining;
  final BigInt total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Uses &&
          runtimeType == other.runtimeType &&
          useMethod == other.useMethod &&
          remaining == other.remaining &&
          total == other.total;

  @override
  int get hashCode => Object.hash(useMethod, remaining, total);

  @override
  String toString() =>
      'Uses(useMethod: $useMethod, remaining: $remaining, total: $total)';
}

Encoder<Uses> getUsesEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('useMethod', getUseMethodEncoder()),
    ('remaining', getU64Encoder()),
    ('total', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Uses value) => <String, Object?>{
      'useMethod': value.useMethod,
      'remaining': value.remaining,
      'total': value.total,
    },
  );
}

Decoder<Uses> getUsesDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('useMethod', getUseMethodDecoder()),
    ('remaining', getU64Decoder()),
    ('total', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Uses(
      useMethod: map['useMethod']! as UseMethod,
      remaining: map['remaining']! as BigInt,
      total: map['total']! as BigInt,
    ),
  );
}

Codec<Uses, Uses> getUsesCodec() {
  return combineCodec(getUsesEncoder(), getUsesDecoder());
}
