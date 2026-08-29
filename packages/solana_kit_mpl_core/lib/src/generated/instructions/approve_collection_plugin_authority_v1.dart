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

import '../types/authority.dart';
import '../types/plugin_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ApproveCollectionPluginAuthorityV1InstructionData {
  const ApproveCollectionPluginAuthorityV1InstructionData({
    required this.pluginType,
    required this.newAuthority,
  }) : discriminator = 9;

  final int discriminator;
  final PluginType pluginType;
  final Authority newAuthority;
}

Encoder<ApproveCollectionPluginAuthorityV1InstructionData>
getApproveCollectionPluginAuthorityV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pluginType', getPluginTypeEncoder()),
    ('newAuthority', getAuthorityEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveCollectionPluginAuthorityV1InstructionData value) =>
        <String, Object?>{
          'discriminator': 9,
          'pluginType': value.pluginType,
          'newAuthority': value.newAuthority,
        },
  );
}

Decoder<ApproveCollectionPluginAuthorityV1InstructionData>
getApproveCollectionPluginAuthorityV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pluginType', getPluginTypeDecoder()),
    ('newAuthority', getAuthorityDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'approveCollectionPluginAuthorityV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApproveCollectionPluginAuthorityV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(9),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApproveCollectionPluginAuthorityV1InstructionData(
        pluginType: map['pluginType']! as PluginType,
        newAuthority: map['newAuthority']! as Authority,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApproveCollectionPluginAuthorityV1InstructionData>(
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
      VariableSizeDecoder<ApproveCollectionPluginAuthorityV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ApproveCollectionPluginAuthorityV1InstructionData,
  ApproveCollectionPluginAuthorityV1InstructionData
>
getApproveCollectionPluginAuthorityV1InstructionDataCodec() {
  return combineCodec(
    getApproveCollectionPluginAuthorityV1InstructionDataEncoder(),
    getApproveCollectionPluginAuthorityV1InstructionDataDecoder(),
  );
}

/// Creates a [ApproveCollectionPluginAuthorityV1] instruction.
Instruction getApproveCollectionPluginAuthorityV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required PluginType pluginType,
  required Authority newAuthority,
}) {
  final instructionData = ApproveCollectionPluginAuthorityV1InstructionData(
    pluginType: pluginType,
    newAuthority: newAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collection, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getApproveCollectionPluginAuthorityV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ApproveCollectionPluginAuthorityV1] instruction from raw instruction data.
ApproveCollectionPluginAuthorityV1InstructionData
parseApproveCollectionPluginAuthorityV1Instruction(Instruction instruction) {
  return getApproveCollectionPluginAuthorityV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
