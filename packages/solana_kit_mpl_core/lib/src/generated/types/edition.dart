// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class Edition {
  const Edition({
    required this.number,
  });

  final int number;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edition &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Edition(number: $number)';
}

Encoder<Edition> getEditionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('number', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Edition value) => <String, Object?>{
      'number': value.number,
    },
  );
}

Decoder<Edition> getEditionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('number', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Edition(
      number: map['number']! as int,
    ),
  );
}

Codec<Edition, Edition> getEditionCodec() {
  return combineCodec(getEditionEncoder(), getEditionDecoder());
}
