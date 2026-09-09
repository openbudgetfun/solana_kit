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
class ChangeAuthorizedSignersInstructionData {
  const ChangeAuthorizedSignersInstructionData({required this.signers})
    : discriminator = 3;

  final int discriminator;
  final List<Address> signers;
}

Encoder<ChangeAuthorizedSignersInstructionData>
getChangeAuthorizedSignersInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'signers',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ChangeAuthorizedSignersInstructionData value) => <String, Object?>{
      'discriminator': 3,
      'signers': value.signers,
    },
  );
}

Decoder<ChangeAuthorizedSignersInstructionData>
getChangeAuthorizedSignersInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('signers', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'changeAuthorizedSigners instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (ChangeAuthorizedSignersInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(3)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ChangeAuthorizedSignersInstructionData(
        signers: map['signers']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ChangeAuthorizedSignersInstructionData>(
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
      VariableSizeDecoder<ChangeAuthorizedSignersInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ChangeAuthorizedSignersInstructionData,
  ChangeAuthorizedSignersInstructionData
>
getChangeAuthorizedSignersInstructionDataCodec() {
  return combineCodec(
    getChangeAuthorizedSignersInstructionDataEncoder(),
    getChangeAuthorizedSignersInstructionDataDecoder(),
  );
}

/// Creates a [ChangeAuthorizedSigners] instruction.
Instruction getChangeAuthorizedSignersInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address systemProgram,
  required List<Address> signers,
}) {
  final instructionData = ChangeAuthorizedSignersInstructionData(
    signers: signers,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: credential, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getChangeAuthorizedSignersInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ChangeAuthorizedSigners] instruction from raw instruction data.
ChangeAuthorizedSignersInstructionData parseChangeAuthorizedSignersInstruction(
  Instruction instruction,
) {
  return getChangeAuthorizedSignersInstructionDataDecoder().decode(
    instruction.data!,
  );
}
