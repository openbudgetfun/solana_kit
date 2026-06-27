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
class FixedDelegation {
  const FixedDelegation({
    required this.header,
    required this.subscriptionAuthority,
    required this.mint,
    required this.amount,
    required this.expiryTs,
  });

  final Header header;
  final Address subscriptionAuthority;
  final Address mint;
  final BigInt amount;
  final BigInt expiryTs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedDelegation &&
          runtimeType == other.runtimeType &&
          header == other.header &&
          subscriptionAuthority == other.subscriptionAuthority &&
          mint == other.mint &&
          amount == other.amount &&
          expiryTs == other.expiryTs;

  @override
  int get hashCode => Object.hash(header, subscriptionAuthority, mint, amount, expiryTs);

  @override
  String toString() => 'FixedDelegation(header: $header, subscriptionAuthority: $subscriptionAuthority, mint: $mint, amount: $amount, expiryTs: $expiryTs)';
}


Encoder<FixedDelegation> getFixedDelegationEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('header', getHeaderEncoder()),
    ('subscriptionAuthority', getAddressEncoder()),
    ('mint', getAddressEncoder()),
    ('amount', getU64Encoder()),
    ('expiryTs', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FixedDelegation value) => <String, Object?>{
      'header': value.header,
      'subscriptionAuthority': value.subscriptionAuthority,
      'mint': value.mint,
      'amount': value.amount,
      'expiryTs': value.expiryTs,
    },
  );
}

Decoder<FixedDelegation> getFixedDelegationDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('header', getHeaderDecoder()),
    ('subscriptionAuthority', getAddressDecoder()),
    ('mint', getAddressDecoder()),
    ('amount', getU64Decoder()),
    ('expiryTs', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => FixedDelegation(
      header: map['header']! as Header,
      subscriptionAuthority: map['subscriptionAuthority']! as Address,
      mint: map['mint']! as Address,
      amount: map['amount']! as BigInt,
      expiryTs: map['expiryTs']! as BigInt,
    ),
  );
}

Codec<FixedDelegation, FixedDelegation> getFixedDelegationCodec() {
  return combineCodec(getFixedDelegationEncoder(), getFixedDelegationDecoder());
}

Account<FixedDelegation> decodeFixedDelegation(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getFixedDelegationDecoder());
}
