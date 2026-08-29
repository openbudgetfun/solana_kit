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
class VaultTransactionCreateInstructionData {
  VaultTransactionCreateInstructionData({
    required this.args,
  }) : discriminator = Uint8List.fromList([
         0x30,
         0xfa,
         0x4e,
         0xa8,
         0xd0,
         0xe2,
         0xda,
         0xd3,
       ]);

  final Uint8List discriminator;
  final VaultTransactionCreateArgs args;
}

Encoder<VaultTransactionCreateInstructionData>
getVaultTransactionCreateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('args', getVaultTransactionCreateArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VaultTransactionCreateInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x30,
        0xfa,
        0x4e,
        0xa8,
        0xd0,
        0xe2,
        0xda,
        0xd3,
      ]),
      'args': value.args,
    },
  );
}

Decoder<VaultTransactionCreateInstructionData>
getVaultTransactionCreateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('args', getVaultTransactionCreateArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'vaultTransactionCreate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VaultTransactionCreateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x30, 0xfa, 0x4e, 0xa8, 0xd0, 0xe2, 0xda, 0xd3]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      VaultTransactionCreateInstructionData(
        args: map['args']! as VaultTransactionCreateArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VaultTransactionCreateInstructionData>(
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
      VariableSizeDecoder<VaultTransactionCreateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  VaultTransactionCreateInstructionData,
  VaultTransactionCreateInstructionData
>
getVaultTransactionCreateInstructionDataCodec() {
  return combineCodec(
    getVaultTransactionCreateInstructionDataEncoder(),
    getVaultTransactionCreateInstructionDataDecoder(),
  );
}

/// Creates a [VaultTransactionCreate] instruction.
Instruction getVaultTransactionCreateInstruction({
  required Address programAddress,
  required Address multisig,
  required Address transaction,
  required Address creator,
  required Address rentPayer,
  required Address systemProgram,
  required VaultTransactionCreateArgs args,
}) {
  final instructionData = VaultTransactionCreateInstructionData(
    args: args,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.writable),
      AccountMeta(address: transaction, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
      AccountMeta(address: rentPayer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getVaultTransactionCreateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [VaultTransactionCreate] instruction from raw instruction data.
VaultTransactionCreateInstructionData parseVaultTransactionCreateInstruction(
  Instruction instruction,
) {
  return getVaultTransactionCreateInstructionDataDecoder().decode(
    instruction.data!,
  );
}
