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

import '../types/key.dart';

@immutable
class HolderDelegateRecord {
  const HolderDelegateRecord({
    required this.key,
    required this.bump,
    required this.mint,
    required this.delegate,
    required this.updateAuthority,
  });

  final Key key;
  final int bump;
  final Address mint;
  final Address delegate;
  final Address updateAuthority;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolderDelegateRecord &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          bump == other.bump &&
          mint == other.mint &&
          delegate == other.delegate &&
          updateAuthority == other.updateAuthority;

  @override
  int get hashCode => Object.hash(key, bump, mint, delegate, updateAuthority);

  @override
  String toString() =>
      'HolderDelegateRecord(key: $key, bump: $bump, mint: $mint, delegate: $delegate, updateAuthority: $updateAuthority)';
}

/// The size of the [HolderDelegateRecord] account data in bytes.
const int holderDelegateRecordSize = 98;

Encoder<HolderDelegateRecord> getHolderDelegateRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('bump', getU8Encoder()),
    ('mint', getAddressEncoder()),
    ('delegate', getAddressEncoder()),
    ('updateAuthority', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (HolderDelegateRecord value) => <String, Object?>{
      'key': value.key,
      'bump': value.bump,
      'mint': value.mint,
      'delegate': value.delegate,
      'updateAuthority': value.updateAuthority,
    },
  );
}

Decoder<HolderDelegateRecord> getHolderDelegateRecordDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('bump', getU8Decoder()),
    ('mint', getAddressDecoder()),
    ('delegate', getAddressDecoder()),
    ('updateAuthority', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'holderDelegateRecord account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (HolderDelegateRecord, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      HolderDelegateRecord(
        key: map['key']! as Key,
        bump: map['bump']! as int,
        mint: map['mint']! as Address,
        delegate: map['delegate']! as Address,
        updateAuthority: map['updateAuthority']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<HolderDelegateRecord>(
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
      VariableSizeDecoder<HolderDelegateRecord>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<HolderDelegateRecord, HolderDelegateRecord>
getHolderDelegateRecordCodec() {
  return combineCodec(
    getHolderDelegateRecordEncoder(),
    getHolderDelegateRecordDecoder(),
  );
}

Account<HolderDelegateRecord> decodeHolderDelegateRecord(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getHolderDelegateRecordDecoder());
}
