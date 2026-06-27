// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import '../types/header.dart';
import '../types/plan_terms.dart';


@immutable
class SubscriptionDelegation {
  const SubscriptionDelegation({
    required this.header,
    required this.terms,
    required this.amountPulledInPeriod,
    required this.currentPeriodStartTs,
    required this.expiresAtTs,
  });

  final Header header;
  final PlanTerms terms;
  final BigInt amountPulledInPeriod;
  final BigInt currentPeriodStartTs;
  final BigInt expiresAtTs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionDelegation &&
          runtimeType == other.runtimeType &&
          header == other.header &&
          terms == other.terms &&
          amountPulledInPeriod == other.amountPulledInPeriod &&
          currentPeriodStartTs == other.currentPeriodStartTs &&
          expiresAtTs == other.expiresAtTs;

  @override
  int get hashCode => Object.hash(header, terms, amountPulledInPeriod, currentPeriodStartTs, expiresAtTs);

  @override
  String toString() => 'SubscriptionDelegation(header: $header, terms: $terms, amountPulledInPeriod: $amountPulledInPeriod, currentPeriodStartTs: $currentPeriodStartTs, expiresAtTs: $expiresAtTs)';
}


Encoder<SubscriptionDelegation> getSubscriptionDelegationEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('header', getHeaderEncoder()),
    ('terms', getPlanTermsEncoder()),
    ('amountPulledInPeriod', getU64Encoder()),
    ('currentPeriodStartTs', getI64Encoder()),
    ('expiresAtTs', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SubscriptionDelegation value) => <String, Object?>{
      'header': value.header,
      'terms': value.terms,
      'amountPulledInPeriod': value.amountPulledInPeriod,
      'currentPeriodStartTs': value.currentPeriodStartTs,
      'expiresAtTs': value.expiresAtTs,
    },
  );
}

Decoder<SubscriptionDelegation> getSubscriptionDelegationDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('header', getHeaderDecoder()),
    ('terms', getPlanTermsDecoder()),
    ('amountPulledInPeriod', getU64Decoder()),
    ('currentPeriodStartTs', getI64Decoder()),
    ('expiresAtTs', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SubscriptionDelegation(
      header: map['header']! as Header,
      terms: map['terms']! as PlanTerms,
      amountPulledInPeriod: map['amountPulledInPeriod']! as BigInt,
      currentPeriodStartTs: map['currentPeriodStartTs']! as BigInt,
      expiresAtTs: map['expiresAtTs']! as BigInt,
    ),
  );
}

Codec<SubscriptionDelegation, SubscriptionDelegation> getSubscriptionDelegationCodec() {
  return combineCodec(getSubscriptionDelegationEncoder(), getSubscriptionDelegationDecoder());
}

Account<SubscriptionDelegation> decodeSubscriptionDelegation(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getSubscriptionDelegationDecoder());
}
