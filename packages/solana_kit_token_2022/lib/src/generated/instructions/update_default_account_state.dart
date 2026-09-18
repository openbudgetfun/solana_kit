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
class UpdateDefaultAccountStateInstructionData {
  const UpdateDefaultAccountStateInstructionData({
    required this.state,
  }) : discriminator = 28,
       defaultAccountStateDiscriminator = 1;

  final int discriminator;
  final int defaultAccountStateDiscriminator;
  final AccountState state;
}

Encoder<UpdateDefaultAccountStateInstructionData>
getUpdateDefaultAccountStateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('defaultAccountStateDiscriminator', getU8Encoder()),
    ('state', getAccountStateEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateDefaultAccountStateInstructionData value) => <String, Object?>{
      'discriminator': 28,
      'defaultAccountStateDiscriminator': 1,
      'state': value.state,
    },
  );
}

Decoder<UpdateDefaultAccountStateInstructionData>
getUpdateDefaultAccountStateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('defaultAccountStateDiscriminator', getU8Decoder()),
    ('state', getAccountStateDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateDefaultAccountState instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateDefaultAccountStateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(28),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateDefaultAccountStateInstructionData(
        state: map['state']! as AccountState,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateDefaultAccountStateInstructionData>(
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
      VariableSizeDecoder<UpdateDefaultAccountStateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateDefaultAccountStateInstructionData,
  UpdateDefaultAccountStateInstructionData
>
getUpdateDefaultAccountStateInstructionDataCodec() {
  return combineCodec(
    getUpdateDefaultAccountStateInstructionDataEncoder(),
    getUpdateDefaultAccountStateInstructionDataDecoder(),
  );
}

/// Creates a [UpdateDefaultAccountState] instruction.
/// Set [freezeAuthorityIsSigner] to false when [freezeAuthority] does not sign (for example, a multisig authority).
Instruction getUpdateDefaultAccountStateInstruction({
  required Address programAddress,
  required Address mint,
  required Address freezeAuthority,
  required AccountState state,
  bool freezeAuthorityIsSigner = true,
}) {
  final instructionData = UpdateDefaultAccountStateInstructionData(
    state: state,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: freezeAuthority,
        role: freezeAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getUpdateDefaultAccountStateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateDefaultAccountState] instruction from raw instruction data.
UpdateDefaultAccountStateInstructionData
parseUpdateDefaultAccountStateInstruction(Instruction instruction) {
  return getUpdateDefaultAccountStateInstructionDataDecoder().decode(
    instruction.data!,
  );
}
