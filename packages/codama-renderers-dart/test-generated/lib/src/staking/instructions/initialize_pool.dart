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
class InitializePoolInstructionData {
  const InitializePoolInstructionData({
    required this.rewardRate,
    required this.minStakeDuration,
    required this.maxStakers,
  }) : discriminator = 0;

  final int discriminator;
  final BigInt rewardRate;
  final BigInt minStakeDuration;
  final int maxStakers;
}

Encoder<InitializePoolInstructionData>
getInitializePoolInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('rewardRate', getU64Encoder()),
    ('minStakeDuration', getI64Encoder()),
    ('maxStakers', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializePoolInstructionData value) => <String, Object?>{
      'discriminator': 0,
      'rewardRate': value.rewardRate,
      'minStakeDuration': value.minStakeDuration,
      'maxStakers': value.maxStakers,
    },
  );
}

Decoder<InitializePoolInstructionData>
getInitializePoolInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('rewardRate', getU64Decoder()),
    ('minStakeDuration', getI64Decoder()),
    ('maxStakers', getU32Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializePool instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializePoolInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializePoolInstructionData(
        rewardRate: map['rewardRate']! as BigInt,
        minStakeDuration: map['minStakeDuration']! as BigInt,
        maxStakers: map['maxStakers']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializePoolInstructionData>(
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
      VariableSizeDecoder<InitializePoolInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializePoolInstructionData, InitializePoolInstructionData>
getInitializePoolInstructionDataCodec() {
  return combineCodec(
    getInitializePoolInstructionDataEncoder(),
    getInitializePoolInstructionDataDecoder(),
  );
}

/// Creates a [InitializePool] instruction.
Instruction getInitializePoolInstruction({
  required Address programAddress,
  required Address pool,
  required Address admin,
  required Address rewardMint,
  required Address stakeMint,
  required Address systemProgram,
  required BigInt rewardRate,
  required BigInt minStakeDuration,
  required int maxStakers,
}) {
  final instructionData = InitializePoolInstructionData(
    rewardRate: rewardRate,
    minStakeDuration: minStakeDuration,
    maxStakers: maxStakers,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: pool, role: AccountRole.writable),
      AccountMeta(address: admin, role: AccountRole.writableSigner),
      AccountMeta(address: rewardMint, role: AccountRole.readonly),
      AccountMeta(address: stakeMint, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getInitializePoolInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializePool] instruction from raw instruction data.
InitializePoolInstructionData parseInitializePoolInstruction(
  Instruction instruction,
) {
  return getInitializePoolInstructionDataDecoder().decode(instruction.data!);
}
