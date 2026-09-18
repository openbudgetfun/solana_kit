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

import '../types/extension_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ReallocateInstructionData {
  const ReallocateInstructionData({
    required this.newExtensionTypes,
  }) : discriminator = 29;

  final int discriminator;
  final List<ExtensionType> newExtensionTypes;
}

Encoder<ReallocateInstructionData> getReallocateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'newExtensionTypes',
      getArrayEncoder(
        transformEncoder(
          getExtensionTypeEncoder(),
          (ExtensionType value) => value,
        ),
        size: RemainderArraySize(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ReallocateInstructionData value) => <String, Object?>{
      'discriminator': 29,
      'newExtensionTypes': value.newExtensionTypes,
    },
  );
}

Decoder<ReallocateInstructionData> getReallocateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'newExtensionTypes',
      getArrayDecoder(getExtensionTypeDecoder(), size: RemainderArraySize()),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'reallocate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ReallocateInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(29),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ReallocateInstructionData(
        newExtensionTypes: map['newExtensionTypes']! as List<ExtensionType>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ReallocateInstructionData>(
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
      VariableSizeDecoder<ReallocateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ReallocateInstructionData, ReallocateInstructionData>
getReallocateInstructionDataCodec() {
  return combineCodec(
    getReallocateInstructionDataEncoder(),
    getReallocateInstructionDataDecoder(),
  );
}

/// Creates a [Reallocate] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getReallocateInstruction({
  required Address programAddress,
  required Address token,
  required Address payer,
  required Address systemProgram,
  required Address owner,
  required List<ExtensionType> newExtensionTypes,
  bool ownerIsSigner = true,
}) {
  final instructionData = ReallocateInstructionData(
    newExtensionTypes: newExtensionTypes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getReallocateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Reallocate] instruction from raw instruction data.
ReallocateInstructionData parseReallocateInstruction(Instruction instruction) {
  return getReallocateInstructionDataDecoder().decode(instruction.data!);
}
