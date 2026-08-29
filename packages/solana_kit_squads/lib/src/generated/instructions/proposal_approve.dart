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
class ProposalApproveInstructionData {
  ProposalApproveInstructionData({
    required this.args,
  }) : discriminator = Uint8List.fromList([
         0x90,
         0x25,
         0xa4,
         0x88,
         0xbc,
         0xd8,
         0x2a,
         0xf8,
       ]);

  final Uint8List discriminator;
  final ProposalVoteArgs args;
}

Encoder<ProposalApproveInstructionData>
getProposalApproveInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('args', getProposalVoteArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProposalApproveInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x90,
        0x25,
        0xa4,
        0x88,
        0xbc,
        0xd8,
        0x2a,
        0xf8,
      ]),
      'args': value.args,
    },
  );
}

Decoder<ProposalApproveInstructionData>
getProposalApproveInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('args', getProposalVoteArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'proposalApprove instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProposalApproveInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x90, 0x25, 0xa4, 0x88, 0xbc, 0xd8, 0x2a, 0xf8]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProposalApproveInstructionData(
        args: map['args']! as ProposalVoteArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProposalApproveInstructionData>(
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
      VariableSizeDecoder<ProposalApproveInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProposalApproveInstructionData, ProposalApproveInstructionData>
getProposalApproveInstructionDataCodec() {
  return combineCodec(
    getProposalApproveInstructionDataEncoder(),
    getProposalApproveInstructionDataDecoder(),
  );
}

/// Creates a [ProposalApprove] instruction.
Instruction getProposalApproveInstruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address proposal,
  required ProposalVoteArgs args,
}) {
  final instructionData = ProposalApproveInstructionData(
    args: args,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.writableSigner),
      AccountMeta(address: proposal, role: AccountRole.writable),
    ],
    data: getProposalApproveInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ProposalApprove] instruction from raw instruction data.
ProposalApproveInstructionData parseProposalApproveInstruction(
  Instruction instruction,
) {
  return getProposalApproveInstructionDataDecoder().decode(instruction.data!);
}
