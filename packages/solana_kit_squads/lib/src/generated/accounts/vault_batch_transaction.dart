// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/vault_transaction_message.dart';

@immutable
class VaultBatchTransaction {
  VaultBatchTransaction({
    required this.bump,
    required this.ephemeralSignerBumps,
    required this.message,
  }) : discriminator = Uint8List.fromList([
         0xc4,
         0x79,
         0x2e,
         0x24,
         0x0c,
         0x13,
         0xfc,
         0x07,
       ]);

  final Uint8List discriminator;
  final int bump;
  final Uint8List ephemeralSignerBumps;
  final VaultTransactionMessage message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultBatchTransaction &&
          runtimeType == other.runtimeType &&
          discriminator == other.discriminator &&
          bump == other.bump &&
          ephemeralSignerBumps == other.ephemeralSignerBumps &&
          message == other.message;

  @override
  int get hashCode =>
      Object.hash(discriminator, bump, ephemeralSignerBumps, message);

  @override
  String toString() =>
      'VaultBatchTransaction(discriminator: $discriminator, bump: $bump, ephemeralSignerBumps: $ephemeralSignerBumps, message: $message)';
}

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

Encoder<VaultBatchTransaction> getVaultBatchTransactionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('bump', getU8Encoder()),
    (
      'ephemeralSignerBumps',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
    ('message', getVaultTransactionMessageEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VaultBatchTransaction value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xc4,
        0x79,
        0x2e,
        0x24,
        0x0c,
        0x13,
        0xfc,
        0x07,
      ]),
      'bump': value.bump,
      'ephemeralSignerBumps': value.ephemeralSignerBumps,
      'message': value.message,
    },
  );
}

Decoder<VaultBatchTransaction> getVaultBatchTransactionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('bump', getU8Decoder()),
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
        'codecDescription': 'vaultBatchTransaction account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VaultBatchTransaction, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xc4, 0x79, 0x2e, 0x24, 0x0c, 0x13, 0xfc, 0x07]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      VaultBatchTransaction(
        bump: map['bump']! as int,
        ephemeralSignerBumps: map['ephemeralSignerBumps']! as Uint8List,
        message: map['message']! as VaultTransactionMessage,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VaultBatchTransaction>(
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
      VariableSizeDecoder<VaultBatchTransaction>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<VaultBatchTransaction, VaultBatchTransaction>
getVaultBatchTransactionCodec() {
  return combineCodec(
    getVaultBatchTransactionEncoder(),
    getVaultBatchTransactionDecoder(),
  );
}

Account<VaultBatchTransaction> decodeVaultBatchTransaction(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getVaultBatchTransactionDecoder());
}
