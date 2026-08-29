// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class UseAuthorityRecord {
  const UseAuthorityRecord({
    required this.key,
    required this.allowedUses,
    required this.bump,
  });

  final Key key;
  final BigInt allowedUses;
  final int bump;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UseAuthorityRecord &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          allowedUses == other.allowedUses &&
          bump == other.bump;

  @override
  int get hashCode => Object.hash(key, allowedUses, bump);

  @override
  String toString() =>
      'UseAuthorityRecord(key: $key, allowedUses: $allowedUses, bump: $bump)';
}

/// The size of the [UseAuthorityRecord] account data in bytes.
const int useAuthorityRecordSize = 10;

Encoder<UseAuthorityRecord> getUseAuthorityRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('allowedUses', getU64Encoder()),
    ('bump', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UseAuthorityRecord value) => <String, Object?>{
      'key': value.key,
      'allowedUses': value.allowedUses,
      'bump': value.bump,
    },
  );
}

Decoder<UseAuthorityRecord> getUseAuthorityRecordDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('allowedUses', getU64Decoder()),
    ('bump', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'useAuthorityRecord account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UseAuthorityRecord, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      UseAuthorityRecord(
        key: map['key']! as Key,
        allowedUses: map['allowedUses']! as BigInt,
        bump: map['bump']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UseAuthorityRecord>(
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
      VariableSizeDecoder<UseAuthorityRecord>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UseAuthorityRecord, UseAuthorityRecord> getUseAuthorityRecordCodec() {
  return combineCodec(
    getUseAuthorityRecordEncoder(),
    getUseAuthorityRecordDecoder(),
  );
}

Account<UseAuthorityRecord> decodeUseAuthorityRecord(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getUseAuthorityRecordDecoder());
}
