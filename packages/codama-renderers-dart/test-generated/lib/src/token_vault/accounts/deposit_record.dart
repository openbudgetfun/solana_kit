// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

@immutable
class DepositRecord {
  DepositRecord({
    required this.depositor,
    required this.vault,
    required this.amount,
    required this.timestamp,
  }) : discriminator = Uint8List.fromList([
         0x53,
         0xe8,
         0x0a,
         0x1f,
         0xfb,
         0x31,
         0xbd,
         0xa7,
       ]);

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
  int get hashCode =>
      Object.hash(discriminator, depositor, vault, amount, timestamp);

  @override
  String toString() =>
      'DepositRecord(discriminator: $discriminator, depositor: $depositor, vault: $vault, amount: $amount, timestamp: $timestamp)';
}

/// The size of the [DepositRecord] account data in bytes.
const int depositRecordSize = 88;

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<DepositRecord> getDepositRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('depositor', getAddressEncoder()),
    ('vault', getAddressEncoder()),
    ('amount', getU64Encoder()),
    ('timestamp', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DepositRecord value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x53,
        0xe8,
        0x0a,
        0x1f,
        0xfb,
        0x31,
        0xbd,
        0xa7,
      ]),
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

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'depositRecord account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DepositRecord, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8).encode(
        Uint8List.fromList([0x53, 0xe8, 0x0a, 0x1f, 0xfb, 0x31, 0xbd, 0xa7]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      DepositRecord(
        depositor: map['depositor']! as Address,
        vault: map['vault']! as Address,
        amount: map['amount']! as BigInt,
        timestamp: map['timestamp']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() => FixedSizeDecoder<DepositRecord>(
      fixedSize: structDecoder.fixedSize,
      read: (bytes, offset) {
        final bytesLength = bytes.length - offset;
        if (bytesLength < structDecoder.fixedSize) {
          throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
        }
        return readTopLevel(bytes, offset);
      },
    ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<DepositRecord>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<DepositRecord, DepositRecord> getDepositRecordCodec() {
  return combineCodec(getDepositRecordEncoder(), getDepositRecordDecoder());
}

Account<DepositRecord> decodeDepositRecord(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getDepositRecordDecoder());
}
