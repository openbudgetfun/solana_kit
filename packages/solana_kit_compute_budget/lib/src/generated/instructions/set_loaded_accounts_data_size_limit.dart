// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_compute_budget/src/generated/programs/compute_budget.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Discriminator byte for the SetLoadedAccountsDataSizeLimit instruction.
const setLoadedAccountsDataSizeLimitDiscriminator = 4;

/// Data for the SetLoadedAccountsDataSizeLimit instruction.
@immutable
class SetLoadedAccountsDataSizeLimitInstructionData {
  /// Creates [SetLoadedAccountsDataSizeLimitInstructionData].
  const SetLoadedAccountsDataSizeLimitInstructionData({
    required this.accountDataSizeLimit, this.discriminator = setLoadedAccountsDataSizeLimitDiscriminator,
  });

  /// The instruction discriminator byte.
  final int discriminator;

  /// Maximum total bytes of account data that can be loaded.
  final int accountDataSizeLimit;

  @override
  String toString() =>
      'SetLoadedAccountsDataSizeLimitInstructionData('
      'discriminator: $discriminator, '
      'accountDataSizeLimit: $accountDataSizeLimit)';

  @override
  bool operator ==(Object other) =>
      other is SetLoadedAccountsDataSizeLimitInstructionData &&
      other.discriminator == discriminator &&
      other.accountDataSizeLimit == accountDataSizeLimit;

  @override
  int get hashCode => Object.hash(discriminator, accountDataSizeLimit);
}

/// Returns the encoder for [SetLoadedAccountsDataSizeLimitInstructionData].
Encoder<SetLoadedAccountsDataSizeLimitInstructionData>
getSetLoadedAccountsDataSizeLimitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('accountDataSizeLimit', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetLoadedAccountsDataSizeLimitInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'accountDataSizeLimit': value.accountDataSizeLimit,
    },
  );
}

/// Returns the decoder for [SetLoadedAccountsDataSizeLimitInstructionData].
Decoder<SetLoadedAccountsDataSizeLimitInstructionData>
getSetLoadedAccountsDataSizeLimitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('accountDataSizeLimit', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        SetLoadedAccountsDataSizeLimitInstructionData(
          discriminator: map['discriminator']! as int,
          accountDataSizeLimit: map['accountDataSizeLimit']! as int,
        ),
  );
}

/// Returns the codec for [SetLoadedAccountsDataSizeLimitInstructionData].
Codec<
  SetLoadedAccountsDataSizeLimitInstructionData,
  SetLoadedAccountsDataSizeLimitInstructionData
>
getSetLoadedAccountsDataSizeLimitInstructionDataCodec() {
  return combineCodec(
    getSetLoadedAccountsDataSizeLimitInstructionDataEncoder(),
    getSetLoadedAccountsDataSizeLimitInstructionDataDecoder(),
  );
}

/// Creates a SetLoadedAccountsDataSizeLimit instruction.
///
/// Limits the total bytes of account data loaded by the transaction to
/// [accountDataSizeLimit].
Instruction getSetLoadedAccountsDataSizeLimitInstruction({
  required int accountDataSizeLimit,
  Address programAddress = computeBudgetProgramAddress,
}) {
  final data = SetLoadedAccountsDataSizeLimitInstructionData(
    accountDataSizeLimit: accountDataSizeLimit,
  );
  return Instruction(
    programAddress: programAddress,
    accounts: const [],
    data: getSetLoadedAccountsDataSizeLimitInstructionDataEncoder().encode(
      data,
    ),
  );
}

/// Parses a SetLoadedAccountsDataSizeLimit instruction from [instruction].
SetLoadedAccountsDataSizeLimitInstructionData
parseSetLoadedAccountsDataSizeLimitInstruction(Instruction instruction) {
  return getSetLoadedAccountsDataSizeLimitInstructionDataDecoder().decode(
    instruction.data!,
  );
}
