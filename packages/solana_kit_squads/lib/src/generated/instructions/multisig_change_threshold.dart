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
class MultisigChangeThresholdInstructionData {
  MultisigChangeThresholdInstructionData({
    required this.newThreshold,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x8d,
         0x2a,
         0x0f,
         0x7e,
         0xa9,
         0x5c,
         0x3e,
         0xb5,
       ]);

  final Uint8List discriminator;
  final int newThreshold;
  final String? memo;
}

Encoder<MultisigChangeThresholdInstructionData>
getMultisigChangeThresholdInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('newThreshold', getU16Encoder()),
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
    (MultisigChangeThresholdInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x8d,
        0x2a,
        0x0f,
        0x7e,
        0xa9,
        0x5c,
        0x3e,
        0xb5,
      ]),
      'newThreshold': value.newThreshold,
      'memo': value.memo,
    },
  );
}

Decoder<MultisigChangeThresholdInstructionData>
getMultisigChangeThresholdInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('newThreshold', getU16Decoder()),
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
        'codecDescription': 'multisigChangeThreshold instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigChangeThresholdInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x8d, 0x2a, 0x0f, 0x7e, 0xa9, 0x5c, 0x3e, 0xb5]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigChangeThresholdInstructionData(
        newThreshold: map['newThreshold']! as int,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigChangeThresholdInstructionData>(
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
      VariableSizeDecoder<MultisigChangeThresholdInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  MultisigChangeThresholdInstructionData,
  MultisigChangeThresholdInstructionData
>
getMultisigChangeThresholdInstructionDataCodec() {
  return combineCodec(
    getMultisigChangeThresholdInstructionDataEncoder(),
    getMultisigChangeThresholdInstructionDataDecoder(),
  );
}

/// Creates a [MultisigChangeThreshold] instruction.
Instruction getMultisigChangeThresholdInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  Address? rentPayer,
  Address? systemProgram,
  required int newThreshold,
  required String? memo,
}) {
  final instructionData = MultisigChangeThresholdInstructionData(
    newThreshold: newThreshold,
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
    data: getMultisigChangeThresholdInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [MultisigChangeThreshold] instruction from raw instruction data.
MultisigChangeThresholdInstructionData parseMultisigChangeThresholdInstruction(
  Instruction instruction,
) {
  return getMultisigChangeThresholdInstructionDataDecoder().decode(
    instruction.data!,
  );
}
