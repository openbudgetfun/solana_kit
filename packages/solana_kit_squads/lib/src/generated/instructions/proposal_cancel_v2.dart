// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/proposal_vote_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ProposalCancelV2InstructionData {
  ProposalCancelV2InstructionData({
    required this.args,
  }) : discriminator = Uint8List.fromList([
         0xcd,
         0x29,
         0xc2,
         0x3d,
         0xdc,
         0x8b,
         0x10,
         0xf7,
       ]);

  final Uint8List discriminator;
  final ProposalVoteArgs args;
}

Encoder<ProposalCancelV2InstructionData>
getProposalCancelV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('args', getProposalVoteArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProposalCancelV2InstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xcd,
        0x29,
        0xc2,
        0x3d,
        0xdc,
        0x8b,
        0x10,
        0xf7,
      ]),
      'args': value.args,
    },
  );
}

Decoder<ProposalCancelV2InstructionData>
getProposalCancelV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('args', getProposalVoteArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'proposalCancelV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProposalCancelV2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xcd, 0x29, 0xc2, 0x3d, 0xdc, 0x8b, 0x10, 0xf7]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProposalCancelV2InstructionData(
        args: map['args']! as ProposalVoteArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProposalCancelV2InstructionData>(
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
      VariableSizeDecoder<ProposalCancelV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProposalCancelV2InstructionData, ProposalCancelV2InstructionData>
getProposalCancelV2InstructionDataCodec() {
  return combineCodec(
    getProposalCancelV2InstructionDataEncoder(),
    getProposalCancelV2InstructionDataDecoder(),
  );
}

/// Creates a [ProposalCancelV2] instruction.
Instruction getProposalCancelV2Instruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address proposal,
  required Address systemProgram,
  required ProposalVoteArgs args,
}) {
  final instructionData = ProposalCancelV2InstructionData(
    args: args,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.writableSigner),
      AccountMeta(address: proposal, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getProposalCancelV2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ProposalCancelV2] instruction from raw instruction data.
ProposalCancelV2InstructionData parseProposalCancelV2Instruction(
  Instruction instruction,
) {
  return getProposalCancelV2InstructionDataDecoder().decode(instruction.data!);
}
