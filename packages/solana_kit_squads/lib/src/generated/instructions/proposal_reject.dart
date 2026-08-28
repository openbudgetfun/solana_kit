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
class ProposalRejectInstructionData {
  ProposalRejectInstructionData({
    required this.args,
  }) : discriminator = Uint8List.fromList([
         0xf3,
         0x3e,
         0x86,
         0x9c,
         0xe6,
         0x6a,
         0xf6,
         0x87,
       ]);

  final Uint8List discriminator;
  final ProposalVoteArgs args;
}

Encoder<ProposalRejectInstructionData>
getProposalRejectInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('args', getProposalVoteArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProposalRejectInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xf3,
        0x3e,
        0x86,
        0x9c,
        0xe6,
        0x6a,
        0xf6,
        0x87,
      ]),
      'args': value.args,
    },
  );
}

Decoder<ProposalRejectInstructionData>
getProposalRejectInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('args', getProposalVoteArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'proposalReject instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProposalRejectInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xf3, 0x3e, 0x86, 0x9c, 0xe6, 0x6a, 0xf6, 0x87]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProposalRejectInstructionData(
        args: map['args']! as ProposalVoteArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProposalRejectInstructionData>(
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
      VariableSizeDecoder<ProposalRejectInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProposalRejectInstructionData, ProposalRejectInstructionData>
getProposalRejectInstructionDataCodec() {
  return combineCodec(
    getProposalRejectInstructionDataEncoder(),
    getProposalRejectInstructionDataDecoder(),
  );
}

/// Creates a [ProposalReject] instruction.
Instruction getProposalRejectInstruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address proposal,
  required ProposalVoteArgs args,
}) {
  final instructionData = ProposalRejectInstructionData(
    args: args,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.writableSigner),
      AccountMeta(address: proposal, role: AccountRole.writable),
    ],
    data: getProposalRejectInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ProposalReject] instruction from raw instruction data.
ProposalRejectInstructionData parseProposalRejectInstruction(
  Instruction instruction,
) {
  return getProposalRejectInstructionDataDecoder().decode(instruction.data!);
}
