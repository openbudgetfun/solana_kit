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
class CloseAttestationInstructionData {
  const CloseAttestationInstructionData() : discriminator = 7;

  final int discriminator;
}

Encoder<CloseAttestationInstructionData>
getCloseAttestationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseAttestationInstructionData value) => <String, Object?>{
      'discriminator': 7,
    },
  );
}

Decoder<CloseAttestationInstructionData>
getCloseAttestationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'closeAttestation instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (CloseAttestationInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(7)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (CloseAttestationInstructionData(), newOffset);
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CloseAttestationInstructionData>(
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
      VariableSizeDecoder<CloseAttestationInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CloseAttestationInstructionData, CloseAttestationInstructionData>
getCloseAttestationInstructionDataCodec() {
  return combineCodec(
    getCloseAttestationInstructionDataEncoder(),
    getCloseAttestationInstructionDataDecoder(),
  );
}

/// Creates a [CloseAttestation] instruction.
Instruction getCloseAttestationInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address attestation,
  required Address eventAuthority,
  required Address systemProgram,
  required Address attestationProgram,
}) {
  final instructionData = CloseAttestationInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: credential, role: AccountRole.readonly),
      AccountMeta(address: attestation, role: AccountRole.writable),
      AccountMeta(address: eventAuthority, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: attestationProgram, role: AccountRole.readonly),
    ],
    data: getCloseAttestationInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseAttestation] instruction from raw instruction data.
CloseAttestationInstructionData parseCloseAttestationInstruction(
  Instruction instruction,
) {
  return getCloseAttestationInstructionDataDecoder().decode(instruction.data!);
}
