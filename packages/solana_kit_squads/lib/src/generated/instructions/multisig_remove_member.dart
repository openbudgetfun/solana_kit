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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MultisigRemoveMemberInstructionData {
  MultisigRemoveMemberInstructionData({
    required this.oldMember,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0xd9,
         0x75,
         0xb1,
         0xd2,
         0xb6,
         0x91,
         0xda,
         0x48,
       ]);

  final Uint8List discriminator;
  final Address oldMember;
  final String? memo;
}

Encoder<MultisigRemoveMemberInstructionData>
getMultisigRemoveMemberInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('oldMember', getAddressEncoder()),
    (
      'memo',
      getNullableEncoder<String>(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigRemoveMemberInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xd9,
        0x75,
        0xb1,
        0xd2,
        0xb6,
        0x91,
        0xda,
        0x48,
      ]),
      'oldMember': value.oldMember,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigRemoveMemberInstructionData>
getMultisigRemoveMemberInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('oldMember', getAddressDecoder()),
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
        'codecDescription': 'multisigRemoveMember instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigRemoveMemberInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xd9, 0x75, 0xb1, 0xd2, 0xb6, 0x91, 0xda, 0x48]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigRemoveMemberInstructionData(
        oldMember: map['oldMember']! as Address,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigRemoveMemberInstructionData>(
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
      VariableSizeDecoder<MultisigRemoveMemberInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MultisigRemoveMemberInstructionData, MultisigRemoveMemberInstructionData>
getMultisigRemoveMemberInstructionDataCodec() {
  return combineCodec(
    getMultisigRemoveMemberInstructionDataEncoder(),
    getMultisigRemoveMemberInstructionDataDecoder(),
  );
}

/// Creates a [MultisigRemoveMember] instruction.
Instruction getMultisigRemoveMemberInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  Address? rentPayer,
  Address? systemProgram,
  required Address oldMember,
  required String? memo,
}) {
  final instructionData = MultisigRemoveMemberInstructionData(
    oldMember: oldMember,
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
    data: getMultisigRemoveMemberInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [MultisigRemoveMember] instruction from raw instruction data.
MultisigRemoveMemberInstructionData parseMultisigRemoveMemberInstruction(
  Instruction instruction,
) {
  return getMultisigRemoveMemberInstructionDataDecoder().decode(
    instruction.data!,
  );
}
