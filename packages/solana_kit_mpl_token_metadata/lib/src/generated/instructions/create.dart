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

import '../types/create_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateInstructionData {
  const CreateInstructionData({
    required this.createArgs,
  }) : discriminator = 42;

  final int discriminator;
  final CreateArgs createArgs;
}

Encoder<CreateInstructionData> getCreateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('createArgs', getCreateArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateInstructionData value) => <String, Object?>{
      'discriminator': 42,
      'createArgs': value.createArgs,
    },
  );
}

Decoder<CreateInstructionData> getCreateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('createArgs', getCreateArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'create instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(42),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateInstructionData(
        createArgs: map['createArgs']! as CreateArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateInstructionData>(
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
      VariableSizeDecoder<CreateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateInstructionData, CreateInstructionData>
getCreateInstructionDataCodec() {
  return combineCodec(
    getCreateInstructionDataEncoder(),
    getCreateInstructionDataDecoder(),
  );
}

/// Creates a [Create] instruction.
Instruction getCreateInstruction({
  required Address programAddress,
  required Address metadata,
  Address? masterEdition,
  required Address mint,
  required Address authority,
  required Address payer,
  required Address updateAuthority,
  required Address systemProgram,
  required Address sysvarInstructions,
  Address? splTokenProgram,
  required CreateArgs createArgs,
}) {
  final instructionData = CreateInstructionData(
    createArgs: createArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (masterEdition != null)
        AccountMeta(address: masterEdition, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: updateAuthority, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      if (splTokenProgram != null)
        AccountMeta(address: splTokenProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getCreateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Create] instruction from raw instruction data.
CreateInstructionData parseCreateInstruction(Instruction instruction) {
  return getCreateInstructionDataDecoder().decode(instruction.data!);
}
