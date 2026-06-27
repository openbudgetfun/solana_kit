// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';


@immutable
class DepositRecord {
  const DepositRecord({
    required this.discriminator,
    required this.depositor,
    required this.vault,
    required this.amount,
    required this.timestamp,
  });

  final Uint8List discriminator;
  final Address depositor;
  final Address vault;
  final BigInt amount;
  final BigInt timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepositRecord &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          depositor == other.depositor &&
          vault == other.vault &&
          amount == other.amount &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(discriminator, depositor, vault, amount, timestamp);

  @override
  String toString() => 'DepositRecord(discriminator: $discriminator, depositor: $depositor, vault: $vault, amount: $amount, timestamp: $timestamp)';
}


/// The size of the [DepositRecord] account data in bytes.
const int depositRecordSize = 88;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.


Encoder<DepositRecord> getDepositRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', fixEncoderSize(getBytesEncoder(), 8)),
    ('depositor', getAddressEncoder()),
    ('vault', getAddressEncoder()),
    ('amount', getU64Encoder()),
    ('timestamp', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DepositRecord value) => <String, Object?>{
      'discriminator': value.discriminator,
      'depositor': value.depositor,
      'vault': value.vault,
      'amount': value.amount,
      'timestamp': value.timestamp,
    },
  );
}

Decoder<DepositRecord> getDepositRecordDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('depositor', getAddressDecoder()),
    ('vault', getAddressDecoder()),
    ('amount', getU64Decoder()),
    ('timestamp', getI64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => DepositRecord(
      discriminator: map['discriminator']! as Uint8List,
      depositor: map['depositor']! as Address,
      vault: map['vault']! as Address,
      amount: map['amount']! as BigInt,
      timestamp: map['timestamp']! as BigInt,
    ),
  );
}

Codec<DepositRecord, DepositRecord> getDepositRecordCodec() {
  return combineCodec(getDepositRecordEncoder(), getDepositRecordDecoder());
}

Account<DepositRecord> decodeDepositRecord(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getDepositRecordDecoder());
}
