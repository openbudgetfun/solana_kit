// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authorized.dart';
import './lockup.dart';

@immutable
class Meta {
  const Meta({
    required this.rentExemptReserve,
    required this.authorized,
    required this.lockup,
  });

  final BigInt rentExemptReserve;
  final Authorized authorized;
  final Lockup lockup;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meta &&
          runtimeType == other.runtimeType &&
          rentExemptReserve == other.rentExemptReserve &&
          authorized == other.authorized &&
          lockup == other.lockup;

  @override
  int get hashCode => Object.hash(rentExemptReserve, authorized, lockup);

  @override
  String toString() =>
      'Meta(rentExemptReserve: $rentExemptReserve, authorized: $authorized, lockup: $lockup)';
}

Encoder<Meta> getMetaEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('rentExemptReserve', getU64Encoder()),
    ('authorized', getAuthorizedEncoder()),
    ('lockup', getLockupEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Meta value) => <String, Object?>{
      'rentExemptReserve': value.rentExemptReserve,
      'authorized': value.authorized,
      'lockup': value.lockup,
    },
  );
}

Decoder<Meta> getMetaDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('rentExemptReserve', getU64Decoder()),
    ('authorized', getAuthorizedDecoder()),
    ('lockup', getLockupDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Meta(
      rentExemptReserve: map['rentExemptReserve']! as BigInt,
      authorized: map['authorized']! as Authorized,
      lockup: map['lockup']! as Lockup,
    ),
  );
}

Codec<Meta, Meta> getMetaCodec() {
  return combineCodec(getMetaEncoder(), getMetaDecoder());
}
