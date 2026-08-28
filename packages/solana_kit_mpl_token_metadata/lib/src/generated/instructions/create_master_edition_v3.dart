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
class CreateMasterEditionV3InstructionData {
  const CreateMasterEditionV3InstructionData({
    required this.maxSupply,
  }) : discriminator = 17;

  final int discriminator;
  final BigInt? maxSupply;
}

Encoder<CreateMasterEditionV3InstructionData>
getCreateMasterEditionV3InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('maxSupply', getNullableEncoder<BigInt>(getU64Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateMasterEditionV3InstructionData value) => <String, Object?>{
      'discriminator': 17,
      'maxSupply': value.maxSupply,
    },
  );
}

Decoder<CreateMasterEditionV3InstructionData>
getCreateMasterEditionV3InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('maxSupply', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createMasterEditionV3 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateMasterEditionV3InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(17),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateMasterEditionV3InstructionData(
        maxSupply: map['maxSupply'] as BigInt?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateMasterEditionV3InstructionData>(
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
      VariableSizeDecoder<CreateMasterEditionV3InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  CreateMasterEditionV3InstructionData,
  CreateMasterEditionV3InstructionData
>
getCreateMasterEditionV3InstructionDataCodec() {
  return combineCodec(
    getCreateMasterEditionV3InstructionDataEncoder(),
    getCreateMasterEditionV3InstructionDataDecoder(),
  );
}

/// Creates a [CreateMasterEditionV3] instruction.
Instruction getCreateMasterEditionV3Instruction({
  required Address programAddress,
  required Address edition,
  required Address mint,
  required Address updateAuthority,
  required Address mintAuthority,
  required Address payer,
  required Address metadata,
  required Address tokenProgram,
  required Address systemProgram,
  Address? rent,
  required BigInt? maxSupply,
}) {
  final instructionData = CreateMasterEditionV3InstructionData(
    maxSupply: maxSupply,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: edition, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getCreateMasterEditionV3InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateMasterEditionV3] instruction from raw instruction data.
CreateMasterEditionV3InstructionData parseCreateMasterEditionV3Instruction(
  Instruction instruction,
) {
  return getCreateMasterEditionV3InstructionDataDecoder().decode(
    instruction.data!,
  );
}
