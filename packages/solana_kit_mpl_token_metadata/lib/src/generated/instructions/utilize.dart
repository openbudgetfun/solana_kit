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
class UtilizeInstructionData {
  const UtilizeInstructionData({
    required this.numberOfUses,
  }) : discriminator = 19;

  final int discriminator;
  final BigInt numberOfUses;
}

Encoder<UtilizeInstructionData> getUtilizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('numberOfUses', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UtilizeInstructionData value) => <String, Object?>{
      'discriminator': 19,
      'numberOfUses': value.numberOfUses,
    },
  );
}

Decoder<UtilizeInstructionData> getUtilizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('numberOfUses', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'utilize instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UtilizeInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(19),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UtilizeInstructionData(
        numberOfUses: map['numberOfUses']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UtilizeInstructionData>(
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
      VariableSizeDecoder<UtilizeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UtilizeInstructionData, UtilizeInstructionData>
getUtilizeInstructionDataCodec() {
  return combineCodec(
    getUtilizeInstructionDataEncoder(),
    getUtilizeInstructionDataDecoder(),
  );
}

/// Creates a [Utilize] instruction.
Instruction getUtilizeInstruction({
  required Address programAddress,
  required Address metadata,
  required Address tokenAccount,
  required Address mint,
  required Address useAuthority,
  required Address owner,
  required Address tokenProgram,
  required Address ataProgram,
  required Address systemProgram,
  required Address rent,
  Address? useAuthorityRecord,
  Address? burner,
  required BigInt numberOfUses,
}) {
  final instructionData = UtilizeInstructionData(
    numberOfUses: numberOfUses,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: tokenAccount, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: useAuthority, role: AccountRole.writableSigner),
      AccountMeta(address: owner, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: ataProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
      if (useAuthorityRecord != null)
        AccountMeta(address: useAuthorityRecord, role: AccountRole.writable),
      if (burner != null)
        AccountMeta(address: burner, role: AccountRole.readonly),
    ],
    data: getUtilizeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Utilize] instruction from raw instruction data.
UtilizeInstructionData parseUtilizeInstruction(Instruction instruction) {
  return getUtilizeInstructionDataDecoder().decode(instruction.data!);
}
