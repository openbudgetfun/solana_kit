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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class InitializeVaultInstructionData {
  const InitializeVaultInstructionData({
    required this.maxCapacity,
    required this.bumpSeed,
  }) : discriminator = 0;

  final int discriminator;
  final BigInt maxCapacity;
  final int bumpSeed;
}

Encoder<InitializeVaultInstructionData>
getInitializeVaultInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('maxCapacity', getU64Encoder()),
    ('bumpSeed', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeVaultInstructionData value) => <String, Object?>{
      'discriminator': 0,
      'maxCapacity': value.maxCapacity,
      'bumpSeed': value.bumpSeed,
    },
  );
}

Decoder<InitializeVaultInstructionData>
getInitializeVaultInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('maxCapacity', getU64Decoder()),
    ('bumpSeed', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeVault instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeVaultInstructionData, int) readExact(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
    return (
      InitializeVaultInstructionData(
        maxCapacity: map['maxCapacity']! as BigInt,
        bumpSeed: map['bumpSeed']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeVaultInstructionData>(
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
      VariableSizeDecoder<InitializeVaultInstructionData>(
        read: readExact,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializeVaultInstructionData, InitializeVaultInstructionData>
getInitializeVaultInstructionDataCodec() {
  return combineCodec(
    getInitializeVaultInstructionDataEncoder(),
    getInitializeVaultInstructionDataDecoder(),
  );
}

/// Creates a [InitializeVault] instruction.
Instruction getInitializeVaultInstruction({
  required Address programAddress,
  required Address vault,
  required Address authority,
  required Address tokenMint,
  required Address systemProgram,
  required BigInt maxCapacity,
  required int bumpSeed,
}) {
  final instructionData = InitializeVaultInstructionData(
    maxCapacity: maxCapacity,
    bumpSeed: bumpSeed,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: vault, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: tokenMint, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getInitializeVaultInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeVault] instruction from raw instruction data.
InitializeVaultInstructionData parseInitializeVaultInstruction(
  Instruction instruction,
) {
  return getInitializeVaultInstructionDataDecoder().decode(instruction.data!);
}
