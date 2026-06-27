// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import '../types/header.dart';

@immutable
class RecurringDelegation {
  const RecurringDelegation({
    required this.header,
    required this.subscriptionAuthority,
    required this.mint,
    required this.currentPeriodStartTs,
    required this.periodLengthS,
    required this.expiryTs,
    required this.amountPerPeriod,
    required this.amountPulledInPeriod,
  });

  final Header header;
  final Address subscriptionAuthority;
  final Address mint;
  final BigInt currentPeriodStartTs;
  final BigInt periodLengthS;
  final BigInt expiryTs;
  final BigInt amountPerPeriod;
  final BigInt amountPulledInPeriod;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringDelegation &&
          runtimeType == other.runtimeType &&
          header == other.header &&
          subscriptionAuthority == other.subscriptionAuthority &&
          mint == other.mint &&
          currentPeriodStartTs == other.currentPeriodStartTs &&
          periodLengthS == other.periodLengthS &&
          expiryTs == other.expiryTs &&
          amountPerPeriod == other.amountPerPeriod &&
          amountPulledInPeriod == other.amountPulledInPeriod;

  @override
  int get hashCode => Object.hash(
    header,
    subscriptionAuthority,
    mint,
    currentPeriodStartTs,
    periodLengthS,
    expiryTs,
    amountPerPeriod,
    amountPulledInPeriod,
  );

  @override
  String toString() =>
      'RecurringDelegation(header: $header, subscriptionAuthority: $subscriptionAuthority, mint: $mint, currentPeriodStartTs: $currentPeriodStartTs, periodLengthS: $periodLengthS, expiryTs: $expiryTs, amountPerPeriod: $amountPerPeriod, amountPulledInPeriod: $amountPulledInPeriod)';
}

Encoder<RecurringDelegation> getRecurringDelegationEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('header', getHeaderEncoder()),
    ('subscriptionAuthority', getAddressEncoder()),
    ('mint', getAddressEncoder()),
    ('currentPeriodStartTs', getI64Encoder()),
    ('periodLengthS', getU64Encoder()),
    ('expiryTs', getI64Encoder()),
    ('amountPerPeriod', getU64Encoder()),
    ('amountPulledInPeriod', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RecurringDelegation value) => <String, Object?>{
      'header': value.header,
      'subscriptionAuthority': value.subscriptionAuthority,
      'mint': value.mint,
      'currentPeriodStartTs': value.currentPeriodStartTs,
      'periodLengthS': value.periodLengthS,
      'expiryTs': value.expiryTs,
      'amountPerPeriod': value.amountPerPeriod,
      'amountPulledInPeriod': value.amountPulledInPeriod,
    },
  );
}

Decoder<RecurringDelegation> getRecurringDelegationDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('header', getHeaderDecoder()),
    ('subscriptionAuthority', getAddressDecoder()),
    ('mint', getAddressDecoder()),
    ('currentPeriodStartTs', getI64Decoder()),
    ('periodLengthS', getU64Decoder()),
    ('expiryTs', getI64Decoder()),
    ('amountPerPeriod', getU64Decoder()),
    ('amountPulledInPeriod', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RecurringDelegation(
          header: map['header']! as Header,
          subscriptionAuthority: map['subscriptionAuthority']! as Address,
          mint: map['mint']! as Address,
          currentPeriodStartTs: map['currentPeriodStartTs']! as BigInt,
          periodLengthS: map['periodLengthS']! as BigInt,
          expiryTs: map['expiryTs']! as BigInt,
          amountPerPeriod: map['amountPerPeriod']! as BigInt,
          amountPulledInPeriod: map['amountPulledInPeriod']! as BigInt,
        ),
  );
}

Codec<RecurringDelegation, RecurringDelegation> getRecurringDelegationCodec() {
  return combineCodec(
    getRecurringDelegationEncoder(),
    getRecurringDelegationDecoder(),
  );
}

Account<RecurringDelegation> decodeRecurringDelegation(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getRecurringDelegationDecoder());
}
