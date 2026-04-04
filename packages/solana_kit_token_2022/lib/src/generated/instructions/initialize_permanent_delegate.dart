// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class InitializePermanentDelegateInstructionData {
  const InitializePermanentDelegateInstructionData({
    this.discriminator = 35,
    required this.delegate,
  });

  final int discriminator;
  final Address delegate;
}

Encoder<InitializePermanentDelegateInstructionData> getInitializePermanentDelegateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('delegate', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializePermanentDelegateInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'delegate': value.delegate,
    },
  );
}

Decoder<InitializePermanentDelegateInstructionData> getInitializePermanentDelegateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('delegate', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializePermanentDelegateInstructionData(
      discriminator: map['discriminator']! as int,
      delegate: map['delegate']! as Address,
    ),
  );
}

Codec<InitializePermanentDelegateInstructionData, InitializePermanentDelegateInstructionData> getInitializePermanentDelegateInstructionDataCodec() {
  return combineCodec(getInitializePermanentDelegateInstructionDataEncoder(), getInitializePermanentDelegateInstructionDataDecoder());
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
    data: getInitializePermanentDelegateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializePermanentDelegate] instruction from raw instruction data.
InitializePermanentDelegateInstructionData parseInitializePermanentDelegateInstruction(Instruction instruction) {
  return getInitializePermanentDelegateInstructionDataDecoder().decode(instruction.data!);
}
