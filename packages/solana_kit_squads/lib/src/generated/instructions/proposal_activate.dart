// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ProposalActivateInstructionData {
  ProposalActivateInstructionData()
    : discriminator = Uint8List.fromList([
        0x0b,
        0x22,
        0x5c,
        0xf8,
        0x9a,
        0x1b,
        0x33,
        0x6a,
      ]);

  final Uint8List discriminator;
}

Encoder<ProposalActivateInstructionData>
getProposalActivateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ProposalActivateInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x0b,
        0x22,
        0x5c,
        0xf8,
        0x9a,
        0x1b,
        0x33,
        0x6a,
      ]),
    },
  );
}

Decoder<ProposalActivateInstructionData>
getProposalActivateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'proposalActivate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProposalActivateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x0b, 0x22, 0x5c, 0xf8, 0x9a, 0x1b, 0x33, 0x6a]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProposalActivateInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProposalActivateInstructionData>(
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
      VariableSizeDecoder<ProposalActivateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProposalActivateInstructionData, ProposalActivateInstructionData>
getProposalActivateInstructionDataCodec() {
  return combineCodec(
    getProposalActivateInstructionDataEncoder(),
    getProposalActivateInstructionDataDecoder(),
  );
}

/// Creates a [ProposalActivate] instruction.
Instruction getProposalActivateInstruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address proposal,
}) {
  final instructionData = ProposalActivateInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.writableSigner),
      AccountMeta(address: proposal, role: AccountRole.writable),
    ],
    data: getProposalActivateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ProposalActivate] instruction from raw instruction data.
ProposalActivateInstructionData parseProposalActivateInstruction(
  Instruction instruction,
) {
  return getProposalActivateInstructionDataDecoder().decode(instruction.data!);
}
