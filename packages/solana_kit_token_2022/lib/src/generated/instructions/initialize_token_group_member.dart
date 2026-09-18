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
class InitializeTokenGroupMemberInstructionData {
  InitializeTokenGroupMemberInstructionData()
    : discriminator = Uint8List.fromList([
        0x98,
        0x20,
        0xde,
        0xb0,
        0xdf,
        0xed,
        0x74,
        0x86,
      ]);

  final Uint8List discriminator;
}

Encoder<InitializeTokenGroupMemberInstructionData>
getInitializeTokenGroupMemberInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTokenGroupMemberInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x98,
        0x20,
        0xde,
        0xb0,
        0xdf,
        0xed,
        0x74,
        0x86,
      ]),
    },
  );
}

Decoder<InitializeTokenGroupMemberInstructionData>
getInitializeTokenGroupMemberInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeTokenGroupMember instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeTokenGroupMemberInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x98, 0x20, 0xde, 0xb0, 0xdf, 0xed, 0x74, 0x86]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeTokenGroupMemberInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeTokenGroupMemberInstructionData>(
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
      VariableSizeDecoder<InitializeTokenGroupMemberInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeTokenGroupMemberInstructionData,
  InitializeTokenGroupMemberInstructionData
>
getInitializeTokenGroupMemberInstructionDataCodec() {
  return combineCodec(
    getInitializeTokenGroupMemberInstructionDataEncoder(),
    getInitializeTokenGroupMemberInstructionDataDecoder(),
  );
}

/// Creates a [InitializeTokenGroupMember] instruction.
Instruction getInitializeTokenGroupMemberInstruction({
  required Address programAddress,
  required Address member,
  required Address memberMint,
  required Address memberMintAuthority,
  required Address group,
  required Address groupUpdateAuthority,
}) {
  final instructionData = InitializeTokenGroupMemberInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: member, role: AccountRole.writable),
      AccountMeta(address: memberMint, role: AccountRole.readonly),
      AccountMeta(
        address: memberMintAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(
        address: groupUpdateAuthority,
        role: AccountRole.readonlySigner,
      ),
    ],
    data: getInitializeTokenGroupMemberInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeTokenGroupMember] instruction from raw instruction data.
InitializeTokenGroupMemberInstructionData
parseInitializeTokenGroupMemberInstruction(Instruction instruction) {
  return getInitializeTokenGroupMemberInstructionDataDecoder().decode(
    instruction.data!,
  );
}
