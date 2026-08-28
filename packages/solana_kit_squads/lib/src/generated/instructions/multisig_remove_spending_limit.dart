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
class MultisigRemoveSpendingLimitInstructionData {
  MultisigRemoveSpendingLimitInstructionData({
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0xe4,
         0xc6,
         0x88,
         0x6f,
         0x7b,
         0x04,
         0xb2,
         0x71,
       ]);

  final Uint8List discriminator;
  final String? memo;
}

Encoder<MultisigRemoveSpendingLimitInstructionData>
getMultisigRemoveSpendingLimitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    (
      'memo',
      getNullableEncoder<String>(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigRemoveSpendingLimitInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xe4,
        0xc6,
        0x88,
        0x6f,
        0x7b,
        0x04,
        0xb2,
        0x71,
      ]),
      'memo': value.memo,
    },
  );
}

Decoder<MultisigRemoveSpendingLimitInstructionData>
getMultisigRemoveSpendingLimitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
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
        'codecDescription': 'multisigRemoveSpendingLimit instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigRemoveSpendingLimitInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xe4, 0xc6, 0x88, 0x6f, 0x7b, 0x04, 0xb2, 0x71]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigRemoveSpendingLimitInstructionData(
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigRemoveSpendingLimitInstructionData>(
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
      VariableSizeDecoder<MultisigRemoveSpendingLimitInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  MultisigRemoveSpendingLimitInstructionData,
  MultisigRemoveSpendingLimitInstructionData
>
getMultisigRemoveSpendingLimitInstructionDataCodec() {
  return combineCodec(
    getMultisigRemoveSpendingLimitInstructionDataEncoder(),
    getMultisigRemoveSpendingLimitInstructionDataDecoder(),
  );
}

/// Creates a [MultisigRemoveSpendingLimit] instruction.
Instruction getMultisigRemoveSpendingLimitInstruction({
  required Address programAddress,
  required Address multisig,
  required Address configAuthority,
  required Address spendingLimit,
  required Address rentCollector,
  required String? memo,
}) {
  final instructionData = MultisigRemoveSpendingLimitInstructionData(
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: configAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: spendingLimit, role: AccountRole.writable),
      AccountMeta(address: rentCollector, role: AccountRole.writable),
    ],
    data: getMultisigRemoveSpendingLimitInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [MultisigRemoveSpendingLimit] instruction from raw instruction data.
MultisigRemoveSpendingLimitInstructionData
parseMultisigRemoveSpendingLimitInstruction(Instruction instruction) {
  return getMultisigRemoveSpendingLimitInstructionDataDecoder().decode(
    instruction.data!,
  );
}
