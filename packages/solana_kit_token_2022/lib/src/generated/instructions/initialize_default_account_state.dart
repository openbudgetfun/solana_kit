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

import '../types/account_state.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'defaultAccountStateDiscriminator'.
/// Offset: 1.

@immutable
class InitializeDefaultAccountStateInstructionData {
  const InitializeDefaultAccountStateInstructionData({
    required this.state,
  }) : discriminator = 28,
       defaultAccountStateDiscriminator = 0;

  final int discriminator;
  final int defaultAccountStateDiscriminator;
  final AccountState state;
}

Encoder<InitializeDefaultAccountStateInstructionData>
getInitializeDefaultAccountStateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('defaultAccountStateDiscriminator', getU8Encoder()),
    ('state', getAccountStateEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeDefaultAccountStateInstructionData value) => <String, Object?>{
      'discriminator': 28,
      'defaultAccountStateDiscriminator': 0,
      'state': value.state,
    },
  );
}

Decoder<InitializeDefaultAccountStateInstructionData>
getInitializeDefaultAccountStateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('defaultAccountStateDiscriminator', getU8Decoder()),
    ('state', getAccountStateDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeDefaultAccountState instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeDefaultAccountStateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(28),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeDefaultAccountStateInstructionData(
        state: map['state']! as AccountState,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeDefaultAccountStateInstructionData>(
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
      VariableSizeDecoder<InitializeDefaultAccountStateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeDefaultAccountStateInstructionData,
  InitializeDefaultAccountStateInstructionData
>
getInitializeDefaultAccountStateInstructionDataCodec() {
  return combineCodec(
    getInitializeDefaultAccountStateInstructionDataEncoder(),
    getInitializeDefaultAccountStateInstructionDataDecoder(),
  );
}

/// Creates a [InitializeDefaultAccountState] instruction.
Instruction getInitializeDefaultAccountStateInstruction({
  required Address programAddress,
  required Address mint,
  required AccountState state,
}) {
  final instructionData = InitializeDefaultAccountStateInstructionData(
    state: state,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeDefaultAccountStateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeDefaultAccountState] instruction from raw instruction data.
InitializeDefaultAccountStateInstructionData
parseInitializeDefaultAccountStateInstruction(Instruction instruction) {
  return getInitializeDefaultAccountStateInstructionDataDecoder().decode(
    instruction.data!,
  );
}
