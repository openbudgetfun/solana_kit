// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class Authorized {
  const Authorized({required this.staker, required this.withdrawer});

  final Address staker;
  final Address withdrawer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authorized &&
          runtimeType == other.runtimeType &&
          staker == other.staker &&
          withdrawer == other.withdrawer;

  @override
  int get hashCode => Object.hash(staker, withdrawer);

  @override
  String toString() => 'Authorized(staker: $staker, withdrawer: $withdrawer)';
}

Encoder<Authorized> getAuthorizedEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('staker', getAddressEncoder()),
    ('withdrawer', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Authorized value) => <String, Object?>{
      'staker': value.staker,
      'withdrawer': value.withdrawer,
    },
  );
}

Decoder<Authorized> getAuthorizedDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('staker', getAddressDecoder()),
    ('withdrawer', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Authorized(
      staker: map['staker']! as Address,
      withdrawer: map['withdrawer']! as Address,
    ),
  );
}

Codec<Authorized, Authorized> getAuthorizedCodec() {
  return combineCodec(getAuthorizedEncoder(), getAuthorizedDecoder());
}
