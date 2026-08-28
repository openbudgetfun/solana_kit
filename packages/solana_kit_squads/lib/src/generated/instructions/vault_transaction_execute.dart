// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class VaultTransactionExecuteInstructionData {
  VaultTransactionExecuteInstructionData()
    : discriminator = Uint8List.fromList([
        0xc2,
        0x08,
        0xa1,
        0x57,
        0x99,
        0xa4,
        0x19,
        0xab,
      ]);

  final Uint8List discriminator;
}

Encoder<VaultTransactionExecuteInstructionData>
getVaultTransactionExecuteInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (VaultTransactionExecuteInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xc2,
        0x08,
        0xa1,
        0x57,
        0x99,
        0xa4,
        0x19,
        0xab,
      ]),
    },
  );
}

Decoder<VaultTransactionExecuteInstructionData>
getVaultTransactionExecuteInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'vaultTransactionExecute instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VaultTransactionExecuteInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xc2, 0x08, 0xa1, 0x57, 0x99, 0xa4, 0x19, 0xab]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      VaultTransactionExecuteInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VaultTransactionExecuteInstructionData>(
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
      VariableSizeDecoder<VaultTransactionExecuteInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  VaultTransactionExecuteInstructionData,
  VaultTransactionExecuteInstructionData
>
getVaultTransactionExecuteInstructionDataCodec() {
  return combineCodec(
    getVaultTransactionExecuteInstructionDataEncoder(),
    getVaultTransactionExecuteInstructionDataDecoder(),
  );
}

/// Creates a [VaultTransactionExecute] instruction.
Instruction getVaultTransactionExecuteInstruction({
  required Address programAddress,
  required Address multisig,
  required Address proposal,
  required Address transaction,
  required Address member,
}) {
  final instructionData = VaultTransactionExecuteInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: proposal, role: AccountRole.writable),
      AccountMeta(address: transaction, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.readonlySigner),
    ],
    data: getVaultTransactionExecuteInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [VaultTransactionExecute] instruction from raw instruction data.
VaultTransactionExecuteInstructionData parseVaultTransactionExecuteInstruction(
  Instruction instruction,
) {
  return getVaultTransactionExecuteInstructionDataDecoder().decode(
    instruction.data!,
  );
}
