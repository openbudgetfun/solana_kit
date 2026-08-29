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
class ExecuteV1InstructionData {
  const ExecuteV1InstructionData({
    required this.instructionData,
  }) : discriminator = 31;

  final int discriminator;
  final Uint8List instructionData;
}

Encoder<ExecuteV1InstructionData> getExecuteV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'instructionData',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ExecuteV1InstructionData value) => <String, Object?>{
      'discriminator': 31,
      'instructionData': value.instructionData,
    },
  );
}

Decoder<ExecuteV1InstructionData> getExecuteV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'instructionData',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'executeV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ExecuteV1InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(31),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ExecuteV1InstructionData(
        instructionData: map['instructionData']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ExecuteV1InstructionData>(
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
      VariableSizeDecoder<ExecuteV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ExecuteV1InstructionData, ExecuteV1InstructionData>
getExecuteV1InstructionDataCodec() {
  return combineCodec(
    getExecuteV1InstructionDataEncoder(),
    getExecuteV1InstructionDataDecoder(),
  );
}

/// Creates a [ExecuteV1] instruction.
Instruction getExecuteV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address assetSigner,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  required Address programId,
  required Uint8List instructionData,
}) {
  final instructionData_ = ExecuteV1InstructionData(
    instructionData: instructionData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: asset, role: AccountRole.writable),
      if (collection != null)
        AccountMeta(address: collection, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: assetSigner, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: programId, role: AccountRole.readonly),
    ],
    data: getExecuteV1InstructionDataEncoder().encode(instructionData_),
  );
}

/// Parses a [ExecuteV1] instruction from raw instruction data.
ExecuteV1InstructionData parseExecuteV1Instruction(Instruction instruction) {
  return getExecuteV1InstructionDataDecoder().decode(instruction.data!);
}
