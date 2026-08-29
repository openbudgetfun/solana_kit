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

import '../types/config_action.dart';

@immutable
class ConfigTransaction {
  ConfigTransaction({
    required this.multisig,
    required this.creator,
    required this.index,
    required this.bump,
    required this.actions,
  }) : discriminator = Uint8List.fromList([
         0x5e,
         0x08,
         0x04,
         0x23,
         0x71,
         0x8b,
         0x8b,
         0x70,
       ]);

  final Uint8List discriminator;
  final Address multisig;
  final Address creator;
  final BigInt index;
  final int bump;
  final List<ConfigAction> actions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigTransaction &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          multisig == other.multisig &&
          creator == other.creator &&
          index == other.index &&
          bump == other.bump &&
          actions == other.actions;

  @override
  int get hashCode =>
      Object.hash(discriminator, multisig, creator, index, bump, actions);

  @override
  String toString() =>
      'ConfigTransaction(discriminator: $discriminator, multisig: $multisig, creator: $creator, index: $index, bump: $bump, actions: $actions)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<ConfigTransaction> getConfigTransactionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('multisig', getAddressEncoder()),
    ('creator', getAddressEncoder()),
    ('index', getU64Encoder()),
    ('bump', getU8Encoder()),
    (
      'actions',
      getArrayEncoder(
        transformEncoder(
          getConfigActionEncoder(),
          (ConfigAction value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigTransaction value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x5e,
        0x08,
        0x04,
        0x23,
        0x71,
        0x8b,
        0x8b,
        0x70,
      ]),
      'multisig': value.multisig,
      'creator': value.creator,
      'index': value.index,
      'bump': value.bump,
      'actions': value.actions,
    },
  );
}

Decoder<ConfigTransaction> getConfigTransactionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('multisig', getAddressDecoder()),
    ('creator', getAddressDecoder()),
    ('index', getU64Decoder()),
    ('bump', getU8Decoder()),
    ('actions', getArrayDecoder(getConfigActionDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'configTransaction account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfigTransaction, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x5e, 0x08, 0x04, 0x23, 0x71, 0x8b, 0x8b, 0x70]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      ConfigTransaction(
        multisig: map['multisig']! as Address,
        creator: map['creator']! as Address,
        index: map['index']! as BigInt,
        bump: map['bump']! as int,
        actions: map['actions']! as List<ConfigAction>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConfigTransaction>(
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
      VariableSizeDecoder<ConfigTransaction>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ConfigTransaction, ConfigTransaction> getConfigTransactionCodec() {
  return combineCodec(
    getConfigTransactionEncoder(),
    getConfigTransactionDecoder(),
  );
}

Account<ConfigTransaction> decodeConfigTransaction(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getConfigTransactionDecoder());
}
