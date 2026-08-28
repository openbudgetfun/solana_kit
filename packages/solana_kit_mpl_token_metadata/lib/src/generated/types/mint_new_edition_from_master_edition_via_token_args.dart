// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

@immutable
class MintNewEditionFromMasterEditionViaTokenArgs {
  const MintNewEditionFromMasterEditionViaTokenArgs({
    required this.edition,
  });

  final BigInt edition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MintNewEditionFromMasterEditionViaTokenArgs &&
          runtimeType == other.runtimeType &&
          edition == other.edition;

  @override
  int get hashCode => edition.hashCode;

  @override
  String toString() =>
      'MintNewEditionFromMasterEditionViaTokenArgs(edition: $edition)';
}

Encoder<MintNewEditionFromMasterEditionViaTokenArgs>
getMintNewEditionFromMasterEditionViaTokenArgsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('edition', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MintNewEditionFromMasterEditionViaTokenArgs value) => <String, Object?>{
      'edition': value.edition,
    },
  );
}

Decoder<MintNewEditionFromMasterEditionViaTokenArgs>
getMintNewEditionFromMasterEditionViaTokenArgsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('edition', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        MintNewEditionFromMasterEditionViaTokenArgs(
          edition: map['edition']! as BigInt,
        ),
  );
}

Codec<
  MintNewEditionFromMasterEditionViaTokenArgs,
  MintNewEditionFromMasterEditionViaTokenArgs
>
getMintNewEditionFromMasterEditionViaTokenArgsCodec() {
  return combineCodec(
    getMintNewEditionFromMasterEditionViaTokenArgsEncoder(),
    getMintNewEditionFromMasterEditionViaTokenArgsDecoder(),
  );
}
