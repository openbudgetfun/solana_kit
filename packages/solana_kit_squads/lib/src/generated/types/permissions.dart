// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class Permissions {
  const Permissions({
    required this.mask,
  });

  final int mask;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Permissions &&
          runtimeType == other.runtimeType &&
          mask == other.mask;

  @override
  int get hashCode => mask.hashCode;

  @override
  String toString() => 'Permissions(mask: $mask)';
}

Encoder<Permissions> getPermissionsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('mask', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Permissions value) => <String, Object?>{
      'mask': value.mask,
    },
  );
}

Decoder<Permissions> getPermissionsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('mask', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Permissions(
      mask: map['mask']! as int,
    ),
  );
}

Codec<Permissions, Permissions> getPermissionsCodec() {
  return combineCodec(getPermissionsEncoder(), getPermissionsDecoder());
}
