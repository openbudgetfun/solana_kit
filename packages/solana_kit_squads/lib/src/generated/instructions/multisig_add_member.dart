// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/member.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MultisigAddMemberInstructionData {
  MultisigAddMemberInstructionData({
    required this.newMember,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x01,
         0xdb,
         0xd7,
         0x6c,
         0xb8,
         0xe5,
         0xd6,
         0x08,
       ]);

  final Uint8List discriminator;
  final Member newMember;
  final String? memo;
}

Encoder<MultisigAddMemberInstructionData>
getMultisigAddMemberInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('newMember', getMemberEncoder()),
    (
      'memo',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigAddMemberInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x01,
        0xdb,
        0xd7,
        0x6c,
        0xb8,
        0xe5,
        0xd6,
        0x08,
      ]),
      'newMember': value.newMember,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigAddMemberInstructionData>
getMultisigAddMemberInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('newMember', getMemberDecoder()),
    (
      'memo',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'multisigAddMember instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigAddMemberInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x01, 0xdb, 0xd7, 0x6c, 0xb8, 0xe5, 0xd6, 0x08]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigAddMemberInstructionData(
        newMember: map['newMember']! as Member,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigAddMemberInstructionData>(
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
      VariableSizeDecoder<MultisigAddMemberInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MultisigAddMemberInstructionData, MultisigAddMemberInstructionData>
getMultisigAddMemberInstructionDataCodec() {
  return combineCodec(
    getMultisigAddMemberInstructionDataEncoder(),
    getMultisigAddMemberInstructionDataDecoder(),
  );
}

/// Creates a [MultisigAddMember] instruction.
Instruction getMultisigAddMemberInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  Address? rentPayer,
  Address? systemProgram,
  required Member newMember,
  required String? memo,
}) {
  final instructionData = MultisigAddMemberInstructionData(
    newMember: newMember,
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.writable),
      AccountMeta(address: configAuthority, role: AccountRole.readonlySigner),
      if (rentPayer != null)
        AccountMeta(address: rentPayer, role: AccountRole.writableSigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (systemProgram != null)
        AccountMeta(address: systemProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getMultisigAddMemberInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MultisigAddMember] instruction from raw instruction data.
MultisigAddMemberInstructionData parseMultisigAddMemberInstruction(
  Instruction instruction,
) {
  return getMultisigAddMemberInstructionDataDecoder().decode(instruction.data!);
}
