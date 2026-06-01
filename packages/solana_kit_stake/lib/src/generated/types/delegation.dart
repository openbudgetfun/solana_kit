// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './epoch.dart';

@immutable
class Delegation {
  const Delegation({
    required this.voterPubkey,
    required this.stake,
    required this.activationEpoch,
    required this.deactivationEpoch,
    required this.reserved,
  });

  final Address voterPubkey;
  final BigInt stake;
  final Epoch activationEpoch;
  final Epoch deactivationEpoch;
  final List<int> reserved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Delegation &&
          runtimeType == other.runtimeType &&
          voterPubkey == other.voterPubkey &&
          stake == other.stake &&
          activationEpoch == other.activationEpoch &&
          deactivationEpoch == other.deactivationEpoch &&
          _listEquals(reserved, other.reserved);

  @override
  int get hashCode => Object.hash(
    voterPubkey,
    stake,
    activationEpoch,
    deactivationEpoch,
    Object.hashAll(reserved),
  );

  @override
  String toString() =>
      'Delegation(voterPubkey: $voterPubkey, stake: $stake, activationEpoch: $activationEpoch, deactivationEpoch: $deactivationEpoch, reserved: $reserved)';
}

Encoder<Delegation> getDelegationEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('voterPubkey', getAddressEncoder()),
    ('stake', getU64Encoder()),
    ('activationEpoch', getEpochEncoder()),
    ('deactivationEpoch', getEpochEncoder()),
    (
      'reserved',
      getArrayEncoder(getU8Encoder(), size: const FixedArraySize(8)),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Delegation value) => <String, Object?>{
      'voterPubkey': value.voterPubkey,
      'stake': value.stake,
      'activationEpoch': value.activationEpoch,
      'deactivationEpoch': value.deactivationEpoch,
      'reserved': value.reserved,
    },
  );
}

Decoder<Delegation> getDelegationDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('voterPubkey', getAddressDecoder()),
    ('stake', getU64Decoder()),
    ('activationEpoch', getEpochDecoder()),
    ('deactivationEpoch', getEpochDecoder()),
    (
      'reserved',
      getArrayDecoder(getU8Decoder(), size: const FixedArraySize(8)),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Delegation(
      voterPubkey: map['voterPubkey']! as Address,
      stake: map['stake']! as BigInt,
      activationEpoch: map['activationEpoch']! as Epoch,
      deactivationEpoch: map['deactivationEpoch']! as Epoch,
      reserved: (map['reserved']! as List).cast<int>(),
    ),
  );
}

Codec<Delegation, Delegation> getDelegationCodec() {
  return combineCodec(getDelegationEncoder(), getDelegationDecoder());
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
