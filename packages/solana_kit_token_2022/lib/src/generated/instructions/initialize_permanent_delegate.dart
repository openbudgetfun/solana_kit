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
class InitializePermanentDelegateInstructionData {
  const InitializePermanentDelegateInstructionData({
    required this.delegate,
  }) : discriminator = 35;

  final int discriminator;
  final Address delegate;
}

Encoder<InitializePermanentDelegateInstructionData>
getInitializePermanentDelegateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('delegate', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializePermanentDelegateInstructionData value) => <String, Object?>{
      'discriminator': 35,
      'delegate': value.delegate,
    },
  );
}

Decoder<InitializePermanentDelegateInstructionData>
getInitializePermanentDelegateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('delegate', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializePermanentDelegate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializePermanentDelegateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(35),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializePermanentDelegateInstructionData(
        delegate: map['delegate']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializePermanentDelegateInstructionData>(
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
      VariableSizeDecoder<InitializePermanentDelegateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializePermanentDelegateInstructionData,
  InitializePermanentDelegateInstructionData
>
getInitializePermanentDelegateInstructionDataCodec() {
  return combineCodec(
    getInitializePermanentDelegateInstructionDataEncoder(),
    getInitializePermanentDelegateInstructionDataDecoder(),
  );
}

/// Creates a [InitializePermanentDelegate] instruction.
Instruction getInitializePermanentDelegateInstruction({
  required Address programAddress,
  required Address mint,
  required Address delegate,
}) {
  final instructionData = InitializePermanentDelegateInstructionData(
    delegate: delegate,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializePermanentDelegateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializePermanentDelegate] instruction from raw instruction data.
InitializePermanentDelegateInstructionData
parseInitializePermanentDelegateInstruction(Instruction instruction) {
  return getInitializePermanentDelegateInstructionDataDecoder().decode(
    instruction.data!,
  );
}
