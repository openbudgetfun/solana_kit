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

import '../types/vault_transaction_message.dart';

@immutable
class VaultTransaction {
  VaultTransaction({
    required this.multisig,
    required this.creator,
    required this.index,
    required this.bump,
    required this.vaultIndex,
    required this.vaultBump,
    required this.ephemeralSignerBumps,
    required this.message,
  }) : discriminator = Uint8List.fromList([
         0xa8,
         0xfa,
         0xa2,
         0x64,
         0x51,
         0x0e,
         0xa2,
         0xcf,
       ]);

  final Uint8List discriminator;
  final Address multisig;
  final Address creator;
  final BigInt index;
  final int bump;
  final int vaultIndex;
  final int vaultBump;
  final Uint8List ephemeralSignerBumps;
  final VaultTransactionMessage message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultTransaction &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          multisig == other.multisig &&
          creator == other.creator &&
          index == other.index &&
          bump == other.bump &&
          vaultIndex == other.vaultIndex &&
          vaultBump == other.vaultBump &&
          ephemeralSignerBumps == other.ephemeralSignerBumps &&
          message == other.message;

  @override
  int get hashCode => Object.hash(
    discriminator,
    multisig,
    creator,
    index,
    bump,
    vaultIndex,
    vaultBump,
    ephemeralSignerBumps,
    message,
  );

  @override
  String toString() =>
      'VaultTransaction(discriminator: $discriminator, multisig: $multisig, creator: $creator, index: $index, bump: $bump, vaultIndex: $vaultIndex, vaultBump: $vaultBump, ephemeralSignerBumps: $ephemeralSignerBumps, message: $message)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<VaultTransaction> getVaultTransactionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('multisig', getAddressEncoder()),
    ('creator', getAddressEncoder()),
    ('index', getU64Encoder()),
    ('bump', getU8Encoder()),
    ('vaultIndex', getU8Encoder()),
    ('vaultBump', getU8Encoder()),
    (
      'ephemeralSignerBumps',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
    ('message', getVaultTransactionMessageEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VaultTransaction value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xa8,
        0xfa,
        0xa2,
        0x64,
        0x51,
        0x0e,
        0xa2,
        0xcf,
      ]),
      'multisig': value.multisig,
      'creator': value.creator,
      'index': value.index,
      'bump': value.bump,
      'vaultIndex': value.vaultIndex,
      'vaultBump': value.vaultBump,
      'ephemeralSignerBumps': value.ephemeralSignerBumps,
      'message': value.message,
    },
  );
}

Decoder<VaultTransaction> getVaultTransactionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('multisig', getAddressDecoder()),
    ('creator', getAddressDecoder()),
    ('index', getU64Decoder()),
    ('bump', getU8Decoder()),
    ('vaultIndex', getU8Decoder()),
    ('vaultBump', getU8Decoder()),
    (
      'ephemeralSignerBumps',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
    ('message', getVaultTransactionMessageDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'vaultTransaction account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VaultTransaction, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xa8, 0xfa, 0xa2, 0x64, 0x51, 0x0e, 0xa2, 0xcf]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      VaultTransaction(
        multisig: map['multisig']! as Address,
        creator: map['creator']! as Address,
        index: map['index']! as BigInt,
        bump: map['bump']! as int,
        vaultIndex: map['vaultIndex']! as int,
        vaultBump: map['vaultBump']! as int,
        ephemeralSignerBumps: map['ephemeralSignerBumps']! as Uint8List,
        message: map['message']! as VaultTransactionMessage,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VaultTransaction>(
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
      VariableSizeDecoder<VaultTransaction>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<VaultTransaction, VaultTransaction> getVaultTransactionCodec() {
  return combineCodec(
    getVaultTransactionEncoder(),
    getVaultTransactionDecoder(),
  );
}

Account<VaultTransaction> decodeVaultTransaction(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getVaultTransactionDecoder());
}
