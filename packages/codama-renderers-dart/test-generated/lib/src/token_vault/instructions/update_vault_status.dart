// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/vault_status.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateVaultStatusInstructionData {
  const UpdateVaultStatusInstructionData({
    required this.newStatus,
  }) : discriminator = 3;

  final int discriminator;
  final VaultStatus newStatus;
}

Encoder<UpdateVaultStatusInstructionData>
getUpdateVaultStatusInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('newStatus', getVaultStatusEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateVaultStatusInstructionData value) => <String, Object?>{
      'discriminator': 3,
      'newStatus': value.newStatus,
    },
  );
}

Decoder<UpdateVaultStatusInstructionData>
getUpdateVaultStatusInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('newStatus', getVaultStatusDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateVaultStatus instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateVaultStatusInstructionData, int) readExact(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(3),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
    return (
      UpdateVaultStatusInstructionData(
        newStatus: map['newStatus']! as VaultStatus,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateVaultStatusInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readExact(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<UpdateVaultStatusInstructionData>(
        read: readExact,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateVaultStatusInstructionData, UpdateVaultStatusInstructionData>
getUpdateVaultStatusInstructionDataCodec() {
  return combineCodec(
    getUpdateVaultStatusInstructionDataEncoder(),
    getUpdateVaultStatusInstructionDataDecoder(),
  );
}

/// Creates a [UpdateVaultStatus] instruction.
Instruction getUpdateVaultStatusInstruction({
  required Address programAddress,
  required Address vault,
  required Address authority,
  required VaultStatus newStatus,
}) {
  final instructionData = UpdateVaultStatusInstructionData(
    newStatus: newStatus,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: vault, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateVaultStatusInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateVaultStatus] instruction from raw instruction data.
UpdateVaultStatusInstructionData parseUpdateVaultStatusInstruction(
  Instruction instruction,
) {
  return getUpdateVaultStatusInstructionDataDecoder().decode(instruction.data!);
}
