// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

/// The address of the MplCore program.
const mplCoreProgramAddress = Address(
  'CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d',
);

/// Known accounts for the MplCore program.
enum MplCoreAccount {
  pluginHeaderV1,
  pluginRegistryV1,
  assetV1,
  collectionV1,
  groupV1,
  hashedAssetV1,
}

/// Known instructions for the MplCore program.
enum MplCoreInstruction {
  createV1,
  createCollectionV1,
  addPluginV1,
  addCollectionPluginV1,
  removePluginV1,
  removeCollectionPluginV1,
  updatePluginV1,
  updateCollectionPluginV1,
  approvePluginAuthorityV1,
  approveCollectionPluginAuthorityV1,
  revokePluginAuthorityV1,
  revokeCollectionPluginAuthorityV1,
  burnV1,
  burnCollectionV1,
  transferV1,
  updateV1,
  updateCollectionV1,
  compressV1,
  decompressV1,
  collect,
  createV2,
  createCollectionV2,
  addExternalPluginAdapterV1,
  addCollectionExternalPluginAdapterV1,
  removeExternalPluginAdapterV1,
  removeCollectionExternalPluginAdapterV1,
  updateExternalPluginAdapterV1,
  updateCollectionExternalPluginAdapterV1,
  writeExternalPluginAdapterDataV1,
  writeCollectionExternalPluginAdapterDataV1,
  updateV2,
  executeV1,
  updateCollectionInfoV1,
  addCollectionsToGroupV1,
  removeCollectionsFromGroupV1,
  addAssetsToGroupV1,
  removeAssetsFromGroupV1,
  addGroupsToGroupV1,
  removeGroupsFromGroupV1,
  createGroupV1,
  closeGroupV1,
  updateGroupV1,
}

/// Identifies the type of a MplCore instruction.
MplCoreInstruction identifyMplCoreInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return MplCoreInstruction.createV1;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return MplCoreInstruction.createCollectionV1;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return MplCoreInstruction.addPluginV1;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return MplCoreInstruction.addCollectionPluginV1;
  }
  if (containsBytes(data, getU8Encoder().encode(4), 0)) {
    return MplCoreInstruction.removePluginV1;
  }
  if (containsBytes(data, getU8Encoder().encode(5), 0)) {
    return MplCoreInstruction.removeCollectionPluginV1;
  }
  if (containsBytes(data, getU8Encoder().encode(6), 0)) {
    return MplCoreInstruction.updatePluginV1;
  }
  if (containsBytes(data, getU8Encoder().encode(7), 0)) {
    return MplCoreInstruction.updateCollectionPluginV1;
  }
  if (containsBytes(data, getU8Encoder().encode(8), 0)) {
    return MplCoreInstruction.approvePluginAuthorityV1;
  }
  if (containsBytes(data, getU8Encoder().encode(9), 0)) {
    return MplCoreInstruction.approveCollectionPluginAuthorityV1;
  }
  if (containsBytes(data, getU8Encoder().encode(10), 0)) {
    return MplCoreInstruction.revokePluginAuthorityV1;
  }
  if (containsBytes(data, getU8Encoder().encode(11), 0)) {
    return MplCoreInstruction.revokeCollectionPluginAuthorityV1;
  }
  if (containsBytes(data, getU8Encoder().encode(12), 0)) {
    return MplCoreInstruction.burnV1;
  }
  if (containsBytes(data, getU8Encoder().encode(13), 0)) {
    return MplCoreInstruction.burnCollectionV1;
  }
  if (containsBytes(data, getU8Encoder().encode(14), 0)) {
    return MplCoreInstruction.transferV1;
  }
  if (containsBytes(data, getU8Encoder().encode(15), 0)) {
    return MplCoreInstruction.updateV1;
  }
  if (containsBytes(data, getU8Encoder().encode(16), 0)) {
    return MplCoreInstruction.updateCollectionV1;
  }
  if (containsBytes(data, getU8Encoder().encode(17), 0)) {
    return MplCoreInstruction.compressV1;
  }
  if (containsBytes(data, getU8Encoder().encode(18), 0)) {
    return MplCoreInstruction.decompressV1;
  }
  if (containsBytes(data, getU8Encoder().encode(19), 0)) {
    return MplCoreInstruction.collect;
  }
  if (containsBytes(data, getU8Encoder().encode(20), 0)) {
    return MplCoreInstruction.createV2;
  }
  if (containsBytes(data, getU8Encoder().encode(21), 0)) {
    return MplCoreInstruction.createCollectionV2;
  }
  if (containsBytes(data, getU8Encoder().encode(22), 0)) {
    return MplCoreInstruction.addExternalPluginAdapterV1;
  }
  if (containsBytes(data, getU8Encoder().encode(23), 0)) {
    return MplCoreInstruction.addCollectionExternalPluginAdapterV1;
  }
  if (containsBytes(data, getU8Encoder().encode(24), 0)) {
    return MplCoreInstruction.removeExternalPluginAdapterV1;
  }
  if (containsBytes(data, getU8Encoder().encode(25), 0)) {
    return MplCoreInstruction.removeCollectionExternalPluginAdapterV1;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0)) {
    return MplCoreInstruction.updateExternalPluginAdapterV1;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0)) {
    return MplCoreInstruction.updateCollectionExternalPluginAdapterV1;
  }
  if (containsBytes(data, getU8Encoder().encode(28), 0)) {
    return MplCoreInstruction.writeExternalPluginAdapterDataV1;
  }
  if (containsBytes(data, getU8Encoder().encode(29), 0)) {
    return MplCoreInstruction.writeCollectionExternalPluginAdapterDataV1;
  }
  if (containsBytes(data, getU8Encoder().encode(30), 0)) {
    return MplCoreInstruction.updateV2;
  }
  if (containsBytes(data, getU8Encoder().encode(31), 0)) {
    return MplCoreInstruction.executeV1;
  }
  if (containsBytes(data, getU8Encoder().encode(32), 0)) {
    return MplCoreInstruction.updateCollectionInfoV1;
  }
  if (containsBytes(data, getU8Encoder().encode(33), 0)) {
    return MplCoreInstruction.addCollectionsToGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(34), 0)) {
    return MplCoreInstruction.removeCollectionsFromGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(35), 0)) {
    return MplCoreInstruction.addAssetsToGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(36), 0)) {
    return MplCoreInstruction.removeAssetsFromGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0)) {
    return MplCoreInstruction.addGroupsToGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(38), 0)) {
    return MplCoreInstruction.removeGroupsFromGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(39), 0)) {
    return MplCoreInstruction.createGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(40), 0)) {
    return MplCoreInstruction.closeGroupV1;
  }
  if (containsBytes(data, getU8Encoder().encode(41), 0)) {
    return MplCoreInstruction.updateGroupV1;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'mplCore',
    },
  );
}

/// A parsed instruction from the MplCore program.
sealed class ParsedMplCoreInstruction {
  const ParsedMplCoreInstruction(this.instructionType);

  final MplCoreInstruction instructionType;
}

/// A parsed CreateV1 instruction.
final class ParsedCreateV1 extends ParsedMplCoreInstruction {
  const ParsedCreateV1({required this.data})
    : super(MplCoreInstruction.createV1);

  final CreateV1InstructionData data;
}

/// A parsed CreateCollectionV1 instruction.
final class ParsedCreateCollectionV1 extends ParsedMplCoreInstruction {
  const ParsedCreateCollectionV1({required this.data})
    : super(MplCoreInstruction.createCollectionV1);

  final CreateCollectionV1InstructionData data;
}

/// A parsed AddPluginV1 instruction.
final class ParsedAddPluginV1 extends ParsedMplCoreInstruction {
  const ParsedAddPluginV1({required this.data})
    : super(MplCoreInstruction.addPluginV1);

  final AddPluginV1InstructionData data;
}

/// A parsed AddCollectionPluginV1 instruction.
final class ParsedAddCollectionPluginV1 extends ParsedMplCoreInstruction {
  const ParsedAddCollectionPluginV1({required this.data})
    : super(MplCoreInstruction.addCollectionPluginV1);

  final AddCollectionPluginV1InstructionData data;
}

/// A parsed RemovePluginV1 instruction.
final class ParsedRemovePluginV1 extends ParsedMplCoreInstruction {
  const ParsedRemovePluginV1({required this.data})
    : super(MplCoreInstruction.removePluginV1);

  final RemovePluginV1InstructionData data;
}

/// A parsed RemoveCollectionPluginV1 instruction.
final class ParsedRemoveCollectionPluginV1 extends ParsedMplCoreInstruction {
  const ParsedRemoveCollectionPluginV1({required this.data})
    : super(MplCoreInstruction.removeCollectionPluginV1);

  final RemoveCollectionPluginV1InstructionData data;
}

/// A parsed UpdatePluginV1 instruction.
final class ParsedUpdatePluginV1 extends ParsedMplCoreInstruction {
  const ParsedUpdatePluginV1({required this.data})
    : super(MplCoreInstruction.updatePluginV1);

  final UpdatePluginV1InstructionData data;
}

/// A parsed UpdateCollectionPluginV1 instruction.
final class ParsedUpdateCollectionPluginV1 extends ParsedMplCoreInstruction {
  const ParsedUpdateCollectionPluginV1({required this.data})
    : super(MplCoreInstruction.updateCollectionPluginV1);

  final UpdateCollectionPluginV1InstructionData data;
}

/// A parsed ApprovePluginAuthorityV1 instruction.
final class ParsedApprovePluginAuthorityV1 extends ParsedMplCoreInstruction {
  const ParsedApprovePluginAuthorityV1({required this.data})
    : super(MplCoreInstruction.approvePluginAuthorityV1);

  final ApprovePluginAuthorityV1InstructionData data;
}

/// A parsed ApproveCollectionPluginAuthorityV1 instruction.
final class ParsedApproveCollectionPluginAuthorityV1
    extends ParsedMplCoreInstruction {
  const ParsedApproveCollectionPluginAuthorityV1({required this.data})
    : super(MplCoreInstruction.approveCollectionPluginAuthorityV1);

  final ApproveCollectionPluginAuthorityV1InstructionData data;
}

/// A parsed RevokePluginAuthorityV1 instruction.
final class ParsedRevokePluginAuthorityV1 extends ParsedMplCoreInstruction {
  const ParsedRevokePluginAuthorityV1({required this.data})
    : super(MplCoreInstruction.revokePluginAuthorityV1);

  final RevokePluginAuthorityV1InstructionData data;
}

/// A parsed RevokeCollectionPluginAuthorityV1 instruction.
final class ParsedRevokeCollectionPluginAuthorityV1
    extends ParsedMplCoreInstruction {
  const ParsedRevokeCollectionPluginAuthorityV1({required this.data})
    : super(MplCoreInstruction.revokeCollectionPluginAuthorityV1);

  final RevokeCollectionPluginAuthorityV1InstructionData data;
}

/// A parsed BurnV1 instruction.
final class ParsedBurnV1 extends ParsedMplCoreInstruction {
  const ParsedBurnV1({required this.data}) : super(MplCoreInstruction.burnV1);

  final BurnV1InstructionData data;
}

/// A parsed BurnCollectionV1 instruction.
final class ParsedBurnCollectionV1 extends ParsedMplCoreInstruction {
  const ParsedBurnCollectionV1({required this.data})
    : super(MplCoreInstruction.burnCollectionV1);

  final BurnCollectionV1InstructionData data;
}

/// A parsed TransferV1 instruction.
final class ParsedTransferV1 extends ParsedMplCoreInstruction {
  const ParsedTransferV1({required this.data})
    : super(MplCoreInstruction.transferV1);

  final TransferV1InstructionData data;
}

/// A parsed UpdateV1 instruction.
final class ParsedUpdateV1 extends ParsedMplCoreInstruction {
  const ParsedUpdateV1({required this.data})
    : super(MplCoreInstruction.updateV1);

  final UpdateV1InstructionData data;
}

/// A parsed UpdateCollectionV1 instruction.
final class ParsedUpdateCollectionV1 extends ParsedMplCoreInstruction {
  const ParsedUpdateCollectionV1({required this.data})
    : super(MplCoreInstruction.updateCollectionV1);

  final UpdateCollectionV1InstructionData data;
}

/// A parsed CompressV1 instruction.
final class ParsedCompressV1 extends ParsedMplCoreInstruction {
  const ParsedCompressV1({required this.data})
    : super(MplCoreInstruction.compressV1);

  final CompressV1InstructionData data;
}

/// A parsed DecompressV1 instruction.
final class ParsedDecompressV1 extends ParsedMplCoreInstruction {
  const ParsedDecompressV1({required this.data})
    : super(MplCoreInstruction.decompressV1);

  final DecompressV1InstructionData data;
}

/// A parsed Collect instruction.
final class ParsedCollect extends ParsedMplCoreInstruction {
  const ParsedCollect({required this.data}) : super(MplCoreInstruction.collect);

  final CollectInstructionData data;
}

/// A parsed CreateV2 instruction.
final class ParsedCreateV2 extends ParsedMplCoreInstruction {
  const ParsedCreateV2({required this.data})
    : super(MplCoreInstruction.createV2);

  final CreateV2InstructionData data;
}

/// A parsed CreateCollectionV2 instruction.
final class ParsedCreateCollectionV2 extends ParsedMplCoreInstruction {
  const ParsedCreateCollectionV2({required this.data})
    : super(MplCoreInstruction.createCollectionV2);

  final CreateCollectionV2InstructionData data;
}

/// A parsed AddExternalPluginAdapterV1 instruction.
final class ParsedAddExternalPluginAdapterV1 extends ParsedMplCoreInstruction {
  const ParsedAddExternalPluginAdapterV1({required this.data})
    : super(MplCoreInstruction.addExternalPluginAdapterV1);

  final AddExternalPluginAdapterV1InstructionData data;
}

/// A parsed AddCollectionExternalPluginAdapterV1 instruction.
final class ParsedAddCollectionExternalPluginAdapterV1
    extends ParsedMplCoreInstruction {
  const ParsedAddCollectionExternalPluginAdapterV1({required this.data})
    : super(MplCoreInstruction.addCollectionExternalPluginAdapterV1);

  final AddCollectionExternalPluginAdapterV1InstructionData data;
}

/// A parsed RemoveExternalPluginAdapterV1 instruction.
final class ParsedRemoveExternalPluginAdapterV1
    extends ParsedMplCoreInstruction {
  const ParsedRemoveExternalPluginAdapterV1({required this.data})
    : super(MplCoreInstruction.removeExternalPluginAdapterV1);

  final RemoveExternalPluginAdapterV1InstructionData data;
}

/// A parsed RemoveCollectionExternalPluginAdapterV1 instruction.
final class ParsedRemoveCollectionExternalPluginAdapterV1
    extends ParsedMplCoreInstruction {
  const ParsedRemoveCollectionExternalPluginAdapterV1({required this.data})
    : super(MplCoreInstruction.removeCollectionExternalPluginAdapterV1);

  final RemoveCollectionExternalPluginAdapterV1InstructionData data;
}

/// A parsed UpdateExternalPluginAdapterV1 instruction.
final class ParsedUpdateExternalPluginAdapterV1
    extends ParsedMplCoreInstruction {
  const ParsedUpdateExternalPluginAdapterV1({required this.data})
    : super(MplCoreInstruction.updateExternalPluginAdapterV1);

  final UpdateExternalPluginAdapterV1InstructionData data;
}

/// A parsed UpdateCollectionExternalPluginAdapterV1 instruction.
final class ParsedUpdateCollectionExternalPluginAdapterV1
    extends ParsedMplCoreInstruction {
  const ParsedUpdateCollectionExternalPluginAdapterV1({required this.data})
    : super(MplCoreInstruction.updateCollectionExternalPluginAdapterV1);

  final UpdateCollectionExternalPluginAdapterV1InstructionData data;
}

/// A parsed WriteExternalPluginAdapterDataV1 instruction.
final class ParsedWriteExternalPluginAdapterDataV1
    extends ParsedMplCoreInstruction {
  const ParsedWriteExternalPluginAdapterDataV1({required this.data})
    : super(MplCoreInstruction.writeExternalPluginAdapterDataV1);

  final WriteExternalPluginAdapterDataV1InstructionData data;
}

/// A parsed WriteCollectionExternalPluginAdapterDataV1 instruction.
final class ParsedWriteCollectionExternalPluginAdapterDataV1
    extends ParsedMplCoreInstruction {
  const ParsedWriteCollectionExternalPluginAdapterDataV1({required this.data})
    : super(MplCoreInstruction.writeCollectionExternalPluginAdapterDataV1);

  final WriteCollectionExternalPluginAdapterDataV1InstructionData data;
}

/// A parsed UpdateV2 instruction.
final class ParsedUpdateV2 extends ParsedMplCoreInstruction {
  const ParsedUpdateV2({required this.data})
    : super(MplCoreInstruction.updateV2);

  final UpdateV2InstructionData data;
}

/// A parsed ExecuteV1 instruction.
final class ParsedExecuteV1 extends ParsedMplCoreInstruction {
  const ParsedExecuteV1({required this.data})
    : super(MplCoreInstruction.executeV1);

  final ExecuteV1InstructionData data;
}

/// A parsed UpdateCollectionInfoV1 instruction.
final class ParsedUpdateCollectionInfoV1 extends ParsedMplCoreInstruction {
  const ParsedUpdateCollectionInfoV1({required this.data})
    : super(MplCoreInstruction.updateCollectionInfoV1);

  final UpdateCollectionInfoV1InstructionData data;
}

/// A parsed AddCollectionsToGroupV1 instruction.
final class ParsedAddCollectionsToGroupV1 extends ParsedMplCoreInstruction {
  const ParsedAddCollectionsToGroupV1({required this.data})
    : super(MplCoreInstruction.addCollectionsToGroupV1);

  final AddCollectionsToGroupV1InstructionData data;
}

/// A parsed RemoveCollectionsFromGroupV1 instruction.
final class ParsedRemoveCollectionsFromGroupV1
    extends ParsedMplCoreInstruction {
  const ParsedRemoveCollectionsFromGroupV1({required this.data})
    : super(MplCoreInstruction.removeCollectionsFromGroupV1);

  final RemoveCollectionsFromGroupV1InstructionData data;
}

/// A parsed AddAssetsToGroupV1 instruction.
final class ParsedAddAssetsToGroupV1 extends ParsedMplCoreInstruction {
  const ParsedAddAssetsToGroupV1({required this.data})
    : super(MplCoreInstruction.addAssetsToGroupV1);

  final AddAssetsToGroupV1InstructionData data;
}

/// A parsed RemoveAssetsFromGroupV1 instruction.
final class ParsedRemoveAssetsFromGroupV1 extends ParsedMplCoreInstruction {
  const ParsedRemoveAssetsFromGroupV1({required this.data})
    : super(MplCoreInstruction.removeAssetsFromGroupV1);

  final RemoveAssetsFromGroupV1InstructionData data;
}

/// A parsed AddGroupsToGroupV1 instruction.
final class ParsedAddGroupsToGroupV1 extends ParsedMplCoreInstruction {
  const ParsedAddGroupsToGroupV1({required this.data})
    : super(MplCoreInstruction.addGroupsToGroupV1);

  final AddGroupsToGroupV1InstructionData data;
}

/// A parsed RemoveGroupsFromGroupV1 instruction.
final class ParsedRemoveGroupsFromGroupV1 extends ParsedMplCoreInstruction {
  const ParsedRemoveGroupsFromGroupV1({required this.data})
    : super(MplCoreInstruction.removeGroupsFromGroupV1);

  final RemoveGroupsFromGroupV1InstructionData data;
}

/// A parsed CreateGroupV1 instruction.
final class ParsedCreateGroupV1 extends ParsedMplCoreInstruction {
  const ParsedCreateGroupV1({required this.data})
    : super(MplCoreInstruction.createGroupV1);

  final CreateGroupV1InstructionData data;
}

/// A parsed CloseGroupV1 instruction.
final class ParsedCloseGroupV1 extends ParsedMplCoreInstruction {
  const ParsedCloseGroupV1({required this.data})
    : super(MplCoreInstruction.closeGroupV1);

  final CloseGroupV1InstructionData data;
}

/// A parsed UpdateGroupV1 instruction.
final class ParsedUpdateGroupV1 extends ParsedMplCoreInstruction {
  const ParsedUpdateGroupV1({required this.data})
    : super(MplCoreInstruction.updateGroupV1);

  final UpdateGroupV1InstructionData data;
}

/// Parses a MplCore instruction.
ParsedMplCoreInstruction parseMplCoreInstruction(
  Instruction instruction,
) {
  return switch (identifyMplCoreInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    MplCoreInstruction.createV1 => ParsedCreateV1(
      data: parseCreateV1Instruction(instruction),
    ),
    MplCoreInstruction.createCollectionV1 => ParsedCreateCollectionV1(
      data: parseCreateCollectionV1Instruction(instruction),
    ),
    MplCoreInstruction.addPluginV1 => ParsedAddPluginV1(
      data: parseAddPluginV1Instruction(instruction),
    ),
    MplCoreInstruction.addCollectionPluginV1 => ParsedAddCollectionPluginV1(
      data: parseAddCollectionPluginV1Instruction(instruction),
    ),
    MplCoreInstruction.removePluginV1 => ParsedRemovePluginV1(
      data: parseRemovePluginV1Instruction(instruction),
    ),
    MplCoreInstruction.removeCollectionPluginV1 =>
      ParsedRemoveCollectionPluginV1(
        data: parseRemoveCollectionPluginV1Instruction(instruction),
      ),
    MplCoreInstruction.updatePluginV1 => ParsedUpdatePluginV1(
      data: parseUpdatePluginV1Instruction(instruction),
    ),
    MplCoreInstruction.updateCollectionPluginV1 =>
      ParsedUpdateCollectionPluginV1(
        data: parseUpdateCollectionPluginV1Instruction(instruction),
      ),
    MplCoreInstruction.approvePluginAuthorityV1 =>
      ParsedApprovePluginAuthorityV1(
        data: parseApprovePluginAuthorityV1Instruction(instruction),
      ),
    MplCoreInstruction.approveCollectionPluginAuthorityV1 =>
      ParsedApproveCollectionPluginAuthorityV1(
        data: parseApproveCollectionPluginAuthorityV1Instruction(instruction),
      ),
    MplCoreInstruction.revokePluginAuthorityV1 => ParsedRevokePluginAuthorityV1(
      data: parseRevokePluginAuthorityV1Instruction(instruction),
    ),
    MplCoreInstruction.revokeCollectionPluginAuthorityV1 =>
      ParsedRevokeCollectionPluginAuthorityV1(
        data: parseRevokeCollectionPluginAuthorityV1Instruction(instruction),
      ),
    MplCoreInstruction.burnV1 => ParsedBurnV1(
      data: parseBurnV1Instruction(instruction),
    ),
    MplCoreInstruction.burnCollectionV1 => ParsedBurnCollectionV1(
      data: parseBurnCollectionV1Instruction(instruction),
    ),
    MplCoreInstruction.transferV1 => ParsedTransferV1(
      data: parseTransferV1Instruction(instruction),
    ),
    MplCoreInstruction.updateV1 => ParsedUpdateV1(
      data: parseUpdateV1Instruction(instruction),
    ),
    MplCoreInstruction.updateCollectionV1 => ParsedUpdateCollectionV1(
      data: parseUpdateCollectionV1Instruction(instruction),
    ),
    MplCoreInstruction.compressV1 => ParsedCompressV1(
      data: parseCompressV1Instruction(instruction),
    ),
    MplCoreInstruction.decompressV1 => ParsedDecompressV1(
      data: parseDecompressV1Instruction(instruction),
    ),
    MplCoreInstruction.collect => ParsedCollect(
      data: parseCollectInstruction(instruction),
    ),
    MplCoreInstruction.createV2 => ParsedCreateV2(
      data: parseCreateV2Instruction(instruction),
    ),
    MplCoreInstruction.createCollectionV2 => ParsedCreateCollectionV2(
      data: parseCreateCollectionV2Instruction(instruction),
    ),
    MplCoreInstruction.addExternalPluginAdapterV1 =>
      ParsedAddExternalPluginAdapterV1(
        data: parseAddExternalPluginAdapterV1Instruction(instruction),
      ),
    MplCoreInstruction.addCollectionExternalPluginAdapterV1 =>
      ParsedAddCollectionExternalPluginAdapterV1(
        data: parseAddCollectionExternalPluginAdapterV1Instruction(instruction),
      ),
    MplCoreInstruction.removeExternalPluginAdapterV1 =>
      ParsedRemoveExternalPluginAdapterV1(
        data: parseRemoveExternalPluginAdapterV1Instruction(instruction),
      ),
    MplCoreInstruction.removeCollectionExternalPluginAdapterV1 =>
      ParsedRemoveCollectionExternalPluginAdapterV1(
        data: parseRemoveCollectionExternalPluginAdapterV1Instruction(
          instruction,
        ),
      ),
    MplCoreInstruction.updateExternalPluginAdapterV1 =>
      ParsedUpdateExternalPluginAdapterV1(
        data: parseUpdateExternalPluginAdapterV1Instruction(instruction),
      ),
    MplCoreInstruction.updateCollectionExternalPluginAdapterV1 =>
      ParsedUpdateCollectionExternalPluginAdapterV1(
        data: parseUpdateCollectionExternalPluginAdapterV1Instruction(
          instruction,
        ),
      ),
    MplCoreInstruction.writeExternalPluginAdapterDataV1 =>
      ParsedWriteExternalPluginAdapterDataV1(
        data: parseWriteExternalPluginAdapterDataV1Instruction(instruction),
      ),
    MplCoreInstruction.writeCollectionExternalPluginAdapterDataV1 =>
      ParsedWriteCollectionExternalPluginAdapterDataV1(
        data: parseWriteCollectionExternalPluginAdapterDataV1Instruction(
          instruction,
        ),
      ),
    MplCoreInstruction.updateV2 => ParsedUpdateV2(
      data: parseUpdateV2Instruction(instruction),
    ),
    MplCoreInstruction.executeV1 => ParsedExecuteV1(
      data: parseExecuteV1Instruction(instruction),
    ),
    MplCoreInstruction.updateCollectionInfoV1 => ParsedUpdateCollectionInfoV1(
      data: parseUpdateCollectionInfoV1Instruction(instruction),
    ),
    MplCoreInstruction.addCollectionsToGroupV1 => ParsedAddCollectionsToGroupV1(
      data: parseAddCollectionsToGroupV1Instruction(instruction),
    ),
    MplCoreInstruction.removeCollectionsFromGroupV1 =>
      ParsedRemoveCollectionsFromGroupV1(
        data: parseRemoveCollectionsFromGroupV1Instruction(instruction),
      ),
    MplCoreInstruction.addAssetsToGroupV1 => ParsedAddAssetsToGroupV1(
      data: parseAddAssetsToGroupV1Instruction(instruction),
    ),
    MplCoreInstruction.removeAssetsFromGroupV1 => ParsedRemoveAssetsFromGroupV1(
      data: parseRemoveAssetsFromGroupV1Instruction(instruction),
    ),
    MplCoreInstruction.addGroupsToGroupV1 => ParsedAddGroupsToGroupV1(
      data: parseAddGroupsToGroupV1Instruction(instruction),
    ),
    MplCoreInstruction.removeGroupsFromGroupV1 => ParsedRemoveGroupsFromGroupV1(
      data: parseRemoveGroupsFromGroupV1Instruction(instruction),
    ),
    MplCoreInstruction.createGroupV1 => ParsedCreateGroupV1(
      data: parseCreateGroupV1Instruction(instruction),
    ),
    MplCoreInstruction.closeGroupV1 => ParsedCloseGroupV1(
      data: parseCloseGroupV1Instruction(instruction),
    ),
    MplCoreInstruction.updateGroupV1 => ParsedUpdateGroupV1(
      data: parseUpdateGroupV1Instruction(instruction),
    ),
  };
}
