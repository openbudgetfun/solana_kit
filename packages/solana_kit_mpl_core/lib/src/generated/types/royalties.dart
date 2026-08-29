// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './creator.dart';
import './rule_set.dart';

@immutable
class Royalties {
  const Royalties({
    required this.basisPoints,
    required this.creators,
    required this.ruleSet,
  });

  final int basisPoints;
  final List<Creator> creators;
  final RuleSet ruleSet;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Royalties &&
          runtimeType == other.runtimeType &&
          basisPoints == other.basisPoints &&
          _listEquals(creators, other.creators) &&
          ruleSet == other.ruleSet;

  @override
  int get hashCode =>
      Object.hash(basisPoints, _listHashCode(creators), ruleSet);

  @override
  String toString() =>
      'Royalties(basisPoints: $basisPoints, creators: $creators, ruleSet: $ruleSet)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a);
}

Encoder<Royalties> getRoyaltiesEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('basisPoints', getU16Encoder()),
    (
      'creators',
      getArrayEncoder(
        transformEncoder(getCreatorEncoder(), (Creator value) => value),
      ),
    ),
    ('ruleSet', getRuleSetEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (Royalties value) => <String, Object?>{
      'basisPoints': value.basisPoints,
      'creators': value.creators,
      'ruleSet': value.ruleSet,
    },
  );
}

Decoder<Royalties> getRoyaltiesDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('basisPoints', getU16Decoder()),
    ('creators', getArrayDecoder(getCreatorDecoder())),
    ('ruleSet', getRuleSetDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Royalties(
      basisPoints: map['basisPoints']! as int,
      creators: map['creators']! as List<Creator>,
      ruleSet: map['ruleSet']! as RuleSet,
    ),
  );
}

Codec<Royalties, Royalties> getRoyaltiesCodec() {
  return combineCodec(getRoyaltiesEncoder(), getRoyaltiesDecoder());
}
