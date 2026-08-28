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
class ProposalCancelInstructionData {
  ProposalCancelInstructionData({
    required this.args,
  }) : discriminator = Uint8List.fromList([
         0x1b,
         0x2a,
         0x7f,
         0xed,
         0x26,
         0xa3,
         0x54,
         0xcb,
       ]);

  final Uint8List discriminator;
  final ProposalVoteArgs args;
}

Encoder<ProposalCancelInstructionData>
getProposalCancelInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('args', getProposalVoteArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProposalCancelInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x1b,
        0x2a,
        0x7f,
        0xed,
        0x26,
        0xa3,
        0x54,
        0xcb,
      ]),
      'args': value.args,
    },
  );
}

Decoder<ProposalCancelInstructionData>
getProposalCancelInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('args', getProposalVoteArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'proposalCancel instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProposalCancelInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x1b, 0x2a, 0x7f, 0xed, 0x26, 0xa3, 0x54, 0xcb]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProposalCancelInstructionData(
        args: map['args']! as ProposalVoteArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProposalCancelInstructionData>(
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
      VariableSizeDecoder<ProposalCancelInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProposalCancelInstructionData, ProposalCancelInstructionData>
getProposalCancelInstructionDataCodec() {
  return combineCodec(
    getProposalCancelInstructionDataEncoder(),
    getProposalCancelInstructionDataDecoder(),
  );
}

/// Creates a [ProposalCancel] instruction.
Instruction getProposalCancelInstruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address proposal,
  required ProposalVoteArgs args,
}) {
  final instructionData = ProposalCancelInstructionData(
    args: args,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.writableSigner),
      AccountMeta(address: proposal, role: AccountRole.writable),
    ],
    data: getProposalCancelInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ProposalCancel] instruction from raw instruction data.
ProposalCancelInstructionData parseProposalCancelInstruction(
  Instruction instruction,
) {
  return getProposalCancelInstructionDataDecoder().decode(instruction.data!);
}
