// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './delegation.dart';

@immutable
class Stake {
  const Stake({required this.delegation, required this.creditsObserved});

  final Delegation delegation;
  final BigInt creditsObserved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stake &&
          runtimeType == other.runtimeType &&
          delegation == other.delegation &&
          creditsObserved == other.creditsObserved;

  @override
  int get hashCode => Object.hash(delegation, creditsObserved);

  @override
  String toString() =>
      'Stake(delegation: $delegation, creditsObserved: $creditsObserved)';
}

Encoder<Stake> getStakeEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('delegation', getDelegationEncoder()),
    ('creditsObserved', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Stake value) => <String, Object?>{
      'delegation': value.delegation,
      'creditsObserved': value.creditsObserved,
    },
  );
}

Decoder<Stake> getStakeDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('delegation', getDelegationDecoder()),
    ('creditsObserved', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Stake(
      delegation: map['delegation']! as Delegation,
      creditsObserved: map['creditsObserved']! as BigInt,
    ),
  );
}

Codec<Stake, Stake> getStakeCodec() {
  return combineCodec(getStakeEncoder(), getStakeDecoder());
}
