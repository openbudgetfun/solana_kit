// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class SetCollectionSizeArgs {
  const SetCollectionSizeArgs({
    required this.size,
  });

  final BigInt size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetCollectionSizeArgs &&
          runtimeType == other.runtimeType &&
          size == other.size;

  @override
  int get hashCode => size.hashCode;

  @override
  String toString() => 'SetCollectionSizeArgs(size: $size)';
}

Encoder<SetCollectionSizeArgs> getSetCollectionSizeArgsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('size', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetCollectionSizeArgs value) => <String, Object?>{
      'size': value.size,
    },
  );
}

Decoder<SetCollectionSizeArgs> getSetCollectionSizeArgsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('size', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetCollectionSizeArgs(
          size: map['size']! as BigInt,
        ),
  );
}

Codec<SetCollectionSizeArgs, SetCollectionSizeArgs>
getSetCollectionSizeArgsCodec() {
  return combineCodec(
    getSetCollectionSizeArgsEncoder(),
    getSetCollectionSizeArgsDecoder(),
  );
}
