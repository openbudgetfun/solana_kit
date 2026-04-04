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

/// The discriminator field name: 'transferHookDiscriminator'.
/// Offset: 1.

@immutable
class InitializeTransferHookInstructionData {
  const InitializeTransferHookInstructionData({
    this.discriminator = 36,
    this.transferHookDiscriminator = 0,
    required this.authority,
    required this.programId,
  });

  final int discriminator;
  final int transferHookDiscriminator;
  final Address? authority;
  final Address? programId;
}

Encoder<InitializeTransferHookInstructionData> getInitializeTransferHookInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferHookDiscriminator', getU8Encoder()),
    ('authority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('programId', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTransferHookInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferHookDiscriminator': value.transferHookDiscriminator,
      'authority': value.authority,
      'programId': value.programId,
    },
  );
}

Decoder<InitializeTransferHookInstructionData> getInitializeTransferHookInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferHookDiscriminator', getU8Decoder()),
    ('authority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('programId', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeTransferHookInstructionData(
      discriminator: map['discriminator']! as int,
      transferHookDiscriminator: map['transferHookDiscriminator']! as int,
      authority: map['authority'] as Address?,
      programId: map['programId'] as Address?,
    ),
  );
}

Codec<InitializeTransferHookInstructionData, InitializeTransferHookInstructionData> getInitializeTransferHookInstructionDataCodec() {
  return combineCodec(getInitializeTransferHookInstructionDataEncoder(), getInitializeTransferHookInstructionDataDecoder());
}

/// Creates a [InitializeTransferHook] instruction.
Instruction getInitializeTransferHookInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required Address? programId,
}) {
  final instructionData = InitializeTransferHookInstructionData(
      authority: authority,
      programId: programId,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeTransferHookInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeTransferHook] instruction from raw instruction data.
InitializeTransferHookInstructionData parseInitializeTransferHookInstruction(Instruction instruction) {
  return getInitializeTransferHookInstructionDataDecoder().decode(instruction.data!);
}
