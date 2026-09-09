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
class CloseTokenizedAttestationInstructionData {
  const CloseTokenizedAttestationInstructionData() : discriminator = 11;

  final int discriminator;
}

Encoder<CloseTokenizedAttestationInstructionData>
getCloseTokenizedAttestationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseTokenizedAttestationInstructionData value) => <String, Object?>{
      'discriminator': 11,
    },
  );
}

Decoder<CloseTokenizedAttestationInstructionData>
getCloseTokenizedAttestationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'closeTokenizedAttestation instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (CloseTokenizedAttestationInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(11)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (CloseTokenizedAttestationInstructionData(), newOffset);
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CloseTokenizedAttestationInstructionData>(
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
      VariableSizeDecoder<CloseTokenizedAttestationInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  CloseTokenizedAttestationInstructionData,
  CloseTokenizedAttestationInstructionData
>
getCloseTokenizedAttestationInstructionDataCodec() {
  return combineCodec(
    getCloseTokenizedAttestationInstructionDataEncoder(),
    getCloseTokenizedAttestationInstructionDataDecoder(),
  );
}

/// Creates a [CloseTokenizedAttestation] instruction.
Instruction getCloseTokenizedAttestationInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address attestation,
  required Address eventAuthority,
  required Address systemProgram,
  required Address attestationProgram,
  required Address attestationMint,
  required Address sasPda,
  required Address attestationTokenAccount,
  required Address tokenProgram,
}) {
  final instructionData = CloseTokenizedAttestationInstructionData();

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
      AccountMeta(address: attestationMint, role: AccountRole.writable),
      AccountMeta(address: sasPda, role: AccountRole.readonly),
      AccountMeta(address: attestationTokenAccount, role: AccountRole.writable),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getCloseTokenizedAttestationInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CloseTokenizedAttestation] instruction from raw instruction data.
CloseTokenizedAttestationInstructionData
parseCloseTokenizedAttestationInstruction(Instruction instruction) {
  return getCloseTokenizedAttestationInstructionDataDecoder().decode(
    instruction.data!,
  );
}
