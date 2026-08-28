// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/vault_transaction_create_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class VaultTransactionCreateFromBufferInstructionData {
  VaultTransactionCreateFromBufferInstructionData({
    required this.args,
  }) : discriminator = Uint8List.fromList([
         0xde,
         0x36,
         0x95,
         0x44,
         0x57,
         0xf6,
         0x30,
         0xe7,
       ]);

  final Uint8List discriminator;
  final VaultTransactionCreateArgs args;
}

Encoder<VaultTransactionCreateFromBufferInstructionData>
getVaultTransactionCreateFromBufferInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('args', getVaultTransactionCreateArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VaultTransactionCreateFromBufferInstructionData value) =>
        <String, Object?>{
          'discriminator': Uint8List.fromList([
            0xde,
            0x36,
            0x95,
            0x44,
            0x57,
            0xf6,
            0x30,
            0xe7,
          ]),
          'args': value.args,
        },
  );
}

Decoder<VaultTransactionCreateFromBufferInstructionData>
getVaultTransactionCreateFromBufferInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('args', getVaultTransactionCreateArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'vaultTransactionCreateFromBuffer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VaultTransactionCreateFromBufferInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xde, 0x36, 0x95, 0x44, 0x57, 0xf6, 0x30, 0xe7]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      VaultTransactionCreateFromBufferInstructionData(
        args: map['args']! as VaultTransactionCreateArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VaultTransactionCreateFromBufferInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<VaultTransactionCreateFromBufferInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  VaultTransactionCreateFromBufferInstructionData,
  VaultTransactionCreateFromBufferInstructionData
>
getVaultTransactionCreateFromBufferInstructionDataCodec() {
  return combineCodec(
    getVaultTransactionCreateFromBufferInstructionDataEncoder(),
    getVaultTransactionCreateFromBufferInstructionDataDecoder(),
  );
}

/// Creates a [VaultTransactionCreateFromBuffer] instruction.
Instruction getVaultTransactionCreateFromBufferInstruction({
  required Address programAddress,
  required Address vaultTransactionCreateMultisig,
  required Address vaultTransactionCreateTransaction,
  required Address vaultTransactionCreateCreator,
  required Address vaultTransactionCreateRentPayer,
  required Address vaultTransactionCreateSystemProgram,
  required Address transactionBuffer,
  required Address creator,
  required VaultTransactionCreateArgs args,
}) {
  final instructionData = VaultTransactionCreateFromBufferInstructionData(
    args: args,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(
        address: vaultTransactionCreateMultisig,
        role: AccountRole.writable,
      ),
      AccountMeta(
        address: vaultTransactionCreateTransaction,
        role: AccountRole.writable,
      ),
      AccountMeta(
        address: vaultTransactionCreateCreator,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(
        address: vaultTransactionCreateRentPayer,
        role: AccountRole.writableSigner,
      ),
      AccountMeta(
        address: vaultTransactionCreateSystemProgram,
        role: AccountRole.readonly,
      ),
      AccountMeta(address: transactionBuffer, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.writableSigner),
    ],
    data: getVaultTransactionCreateFromBufferInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [VaultTransactionCreateFromBuffer] instruction from raw instruction data.
VaultTransactionCreateFromBufferInstructionData
parseVaultTransactionCreateFromBufferInstruction(Instruction instruction) {
  return getVaultTransactionCreateFromBufferInstructionDataDecoder().decode(
    instruction.data!,
  );
}
