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
class ProposalCreateInstructionData {
  ProposalCreateInstructionData({
    required this.transactionIndex,
    required this.draft,
  }) : discriminator = Uint8List.fromList([
         0xdc,
         0x3c,
         0x49,
         0xe0,
         0x1e,
         0x6c,
         0x4f,
         0x9f,
       ]);

  final Uint8List discriminator;
  final BigInt transactionIndex;
  final bool draft;
}

Encoder<ProposalCreateInstructionData>
getProposalCreateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('transactionIndex', getU64Encoder()),
    ('draft', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProposalCreateInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xdc,
        0x3c,
        0x49,
        0xe0,
        0x1e,
        0x6c,
        0x4f,
        0x9f,
      ]),
      'transactionIndex': value.transactionIndex,
      'draft': value.draft,
    },
  );
}

Decoder<ProposalCreateInstructionData>
getProposalCreateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('transactionIndex', getU64Decoder()),
    ('draft', getBooleanDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'proposalCreate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProposalCreateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xdc, 0x3c, 0x49, 0xe0, 0x1e, 0x6c, 0x4f, 0x9f]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProposalCreateInstructionData(
        transactionIndex: map['transactionIndex']! as BigInt,
        draft: map['draft']! as bool,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProposalCreateInstructionData>(
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
      VariableSizeDecoder<ProposalCreateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProposalCreateInstructionData, ProposalCreateInstructionData>
getProposalCreateInstructionDataCodec() {
  return combineCodec(
    getProposalCreateInstructionDataEncoder(),
    getProposalCreateInstructionDataDecoder(),
  );
}

/// Creates a [ProposalCreate] instruction.
Instruction getProposalCreateInstruction({
  required Address programAddress,
  required Address multisig,
  required Address proposal,
  required Address creator,
  required Address rentPayer,
  required Address systemProgram,
  required BigInt transactionIndex,
  required bool draft,
}) {
  final instructionData = ProposalCreateInstructionData(
    transactionIndex: transactionIndex,
    draft: draft,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: proposal, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
      AccountMeta(address: rentPayer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getProposalCreateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ProposalCreate] instruction from raw instruction data.
ProposalCreateInstructionData parseProposalCreateInstruction(
  Instruction instruction,
) {
  return getProposalCreateInstructionDataDecoder().decode(instruction.data!);
}
