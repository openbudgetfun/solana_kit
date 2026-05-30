// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_memo/src/generated/programs/memo.dart';

/// Data for the AddMemo instruction.
@immutable
class AddMemoInstructionData {
  /// Creates [AddMemoInstructionData].
  const AddMemoInstructionData({required this.memo});

  /// Memo text encoded as raw UTF-8 instruction data.
  final String memo;

  @override
  String toString() => 'AddMemoInstructionData(memo: $memo)';

  @override
  bool operator ==(Object other) =>
      other is AddMemoInstructionData && other.memo == memo;

  @override
  int get hashCode => memo.hashCode;
}

/// Returns the encoder for [AddMemoInstructionData].
Encoder<AddMemoInstructionData> getAddMemoInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('memo', getUtf8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AddMemoInstructionData value) => <String, Object?>{'memo': value.memo},
  );
}

/// Returns the decoder for [AddMemoInstructionData].
Decoder<AddMemoInstructionData> getAddMemoInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('memo', getUtf8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        AddMemoInstructionData(memo: map['memo']! as String),
  );
}

/// Returns the codec for [AddMemoInstructionData].
Codec<AddMemoInstructionData, AddMemoInstructionData>
getAddMemoInstructionDataCodec() {
  return combineCodec(
    getAddMemoInstructionDataEncoder(),
    getAddMemoInstructionDataDecoder(),
  );
}

/// Creates an AddMemo instruction from generated instruction data.
Instruction getAddMemoInstructionFromData({
  required AddMemoInstructionData data,
  List<AccountMeta> accounts = const [],
  Address programAddress = memoProgramAddress,
}) {
  return Instruction(
    programAddress: programAddress,
    accounts: accounts,
    data: getAddMemoInstructionDataEncoder().encode(data),
  );
}

/// Parses an AddMemo instruction from [instruction].
AddMemoInstructionData parseAddMemoInstruction(Instruction instruction) {
  return getAddMemoInstructionDataDecoder().decode(instruction.data!);
}
