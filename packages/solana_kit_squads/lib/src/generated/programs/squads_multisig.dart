// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

/// The address of the SquadsMultisig program.
const squadsMultisigProgramAddress = Address(
  'SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf',
);

/// Known accounts for the SquadsMultisig program.
enum SquadsMultisigAccount {
  batch,
  vaultBatchTransaction,
  configTransaction,
  multisig,
  programConfig,
  proposal,
  spendingLimit,
  transactionBuffer,
  vaultTransaction,
}

/// Known instructions for the SquadsMultisig program.
enum SquadsMultisigInstruction {
  programConfigInit,
  programConfigSetAuthority,
  programConfigSetMultisigCreationFee,
  programConfigSetTreasury,
  multisigCreate,
  multisigCreateV2,
  multisigAddMember,
  multisigRemoveMember,
  multisigSetTimeLock,
  multisigChangeThreshold,
  multisigSetConfigAuthority,
  multisigSetRentCollector,
  multisigAddSpendingLimit,
  multisigRemoveSpendingLimit,
  configTransactionCreate,
  configTransactionExecute,
  vaultTransactionCreate,
  transactionBufferCreate,
  transactionBufferClose,
  transactionBufferExtend,
  vaultTransactionCreateFromBuffer,
  vaultTransactionExecute,
  batchCreate,
  batchAddTransaction,
  batchExecuteTransaction,
  proposalCreate,
  proposalActivate,
  proposalApprove,
  proposalReject,
  proposalCancel,
  proposalCancelV2,
  spendingLimitUse,
  configTransactionAccountsClose,
  vaultTransactionAccountsClose,
  vaultBatchTransactionAccountClose,
  batchAccountsClose,
}

/// Identifies the type of a SquadsMultisig instruction.
SquadsMultisigInstruction identifySquadsMultisigInstruction(
  Uint8List data,
) {
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([184, 188, 198, 195, 205, 124, 117, 216])),
    0,
  )) {
    return SquadsMultisigInstruction.programConfigInit;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([238, 242, 36, 181, 32, 143, 216, 75])),
    0,
  )) {
    return SquadsMultisigInstruction.programConfigSetAuthority;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([101, 160, 249, 63, 154, 215, 153, 13])),
    0,
  )) {
    return SquadsMultisigInstruction.programConfigSetMultisigCreationFee;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([111, 46, 243, 117, 144, 188, 162, 107])),
    0,
  )) {
    return SquadsMultisigInstruction.programConfigSetTreasury;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([122, 77, 80, 159, 84, 88, 90, 197])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigCreate;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([50, 221, 199, 93, 40, 245, 139, 233])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigCreateV2;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([1, 219, 215, 108, 184, 229, 214, 8])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigAddMember;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([217, 117, 177, 210, 182, 145, 218, 72])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigRemoveMember;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([148, 154, 121, 77, 212, 254, 155, 72])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigSetTimeLock;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([141, 42, 15, 126, 169, 92, 62, 181])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigChangeThreshold;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([143, 93, 199, 143, 92, 169, 193, 232])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigSetConfigAuthority;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([48, 204, 65, 57, 210, 70, 156, 74])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigSetRentCollector;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([11, 242, 159, 42, 86, 197, 89, 115])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigAddSpendingLimit;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([228, 198, 136, 111, 123, 4, 178, 113])),
    0,
  )) {
    return SquadsMultisigInstruction.multisigRemoveSpendingLimit;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([155, 236, 87, 228, 137, 75, 81, 39])),
    0,
  )) {
    return SquadsMultisigInstruction.configTransactionCreate;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([114, 146, 244, 189, 252, 140, 36, 40])),
    0,
  )) {
    return SquadsMultisigInstruction.configTransactionExecute;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([48, 250, 78, 168, 208, 226, 218, 211])),
    0,
  )) {
    return SquadsMultisigInstruction.vaultTransactionCreate;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([245, 201, 113, 108, 37, 63, 29, 89])),
    0,
  )) {
    return SquadsMultisigInstruction.transactionBufferCreate;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([17, 182, 208, 228, 136, 24, 178, 102])),
    0,
  )) {
    return SquadsMultisigInstruction.transactionBufferClose;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([230, 157, 67, 56, 5, 238, 245, 146])),
    0,
  )) {
    return SquadsMultisigInstruction.transactionBufferExtend;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([222, 54, 149, 68, 87, 246, 48, 231])),
    0,
  )) {
    return SquadsMultisigInstruction.vaultTransactionCreateFromBuffer;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([194, 8, 161, 87, 153, 164, 25, 171])),
    0,
  )) {
    return SquadsMultisigInstruction.vaultTransactionExecute;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([194, 142, 141, 17, 55, 185, 20, 248])),
    0,
  )) {
    return SquadsMultisigInstruction.batchCreate;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([89, 100, 224, 18, 69, 70, 54, 76])),
    0,
  )) {
    return SquadsMultisigInstruction.batchAddTransaction;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([172, 44, 179, 152, 21, 127, 234, 180])),
    0,
  )) {
    return SquadsMultisigInstruction.batchExecuteTransaction;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([220, 60, 73, 224, 30, 108, 79, 159])),
    0,
  )) {
    return SquadsMultisigInstruction.proposalCreate;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([11, 34, 92, 248, 154, 27, 51, 106])),
    0,
  )) {
    return SquadsMultisigInstruction.proposalActivate;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([144, 37, 164, 136, 188, 216, 42, 248])),
    0,
  )) {
    return SquadsMultisigInstruction.proposalApprove;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([243, 62, 134, 156, 230, 106, 246, 135])),
    0,
  )) {
    return SquadsMultisigInstruction.proposalReject;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([27, 42, 127, 237, 38, 163, 84, 203])),
    0,
  )) {
    return SquadsMultisigInstruction.proposalCancel;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([205, 41, 194, 61, 220, 139, 16, 247])),
    0,
  )) {
    return SquadsMultisigInstruction.proposalCancelV2;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([16, 57, 130, 127, 193, 20, 155, 134])),
    0,
  )) {
    return SquadsMultisigInstruction.spendingLimitUse;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([80, 203, 84, 53, 151, 112, 187, 186])),
    0,
  )) {
    return SquadsMultisigInstruction.configTransactionAccountsClose;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([196, 71, 187, 176, 2, 35, 170, 165])),
    0,
  )) {
    return SquadsMultisigInstruction.vaultTransactionAccountsClose;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([134, 18, 19, 106, 129, 68, 97, 247])),
    0,
  )) {
    return SquadsMultisigInstruction.vaultBatchTransactionAccountClose;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([218, 196, 7, 175, 130, 102, 11, 255])),
    0,
  )) {
    return SquadsMultisigInstruction.batchAccountsClose;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'squadsMultisig',
    },
  );
}

/// A parsed instruction from the SquadsMultisig program.
sealed class ParsedSquadsMultisigInstruction {
  const ParsedSquadsMultisigInstruction(this.instructionType);

  final SquadsMultisigInstruction instructionType;
}

/// A parsed ProgramConfigInit instruction.
final class ParsedProgramConfigInit extends ParsedSquadsMultisigInstruction {
  const ParsedProgramConfigInit({required this.data})
    : super(SquadsMultisigInstruction.programConfigInit);

  final ProgramConfigInitInstructionData data;
}

/// A parsed ProgramConfigSetAuthority instruction.
final class ParsedProgramConfigSetAuthority
    extends ParsedSquadsMultisigInstruction {
  const ParsedProgramConfigSetAuthority({required this.data})
    : super(SquadsMultisigInstruction.programConfigSetAuthority);

  final ProgramConfigSetAuthorityInstructionData data;
}

/// A parsed ProgramConfigSetMultisigCreationFee instruction.
final class ParsedProgramConfigSetMultisigCreationFee
    extends ParsedSquadsMultisigInstruction {
  const ParsedProgramConfigSetMultisigCreationFee({required this.data})
    : super(SquadsMultisigInstruction.programConfigSetMultisigCreationFee);

  final ProgramConfigSetMultisigCreationFeeInstructionData data;
}

/// A parsed ProgramConfigSetTreasury instruction.
final class ParsedProgramConfigSetTreasury
    extends ParsedSquadsMultisigInstruction {
  const ParsedProgramConfigSetTreasury({required this.data})
    : super(SquadsMultisigInstruction.programConfigSetTreasury);

  final ProgramConfigSetTreasuryInstructionData data;
}

/// A parsed MultisigCreate instruction.
final class ParsedMultisigCreate extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigCreate({required this.data})
    : super(SquadsMultisigInstruction.multisigCreate);

  final MultisigCreateInstructionData data;
}

/// A parsed MultisigCreateV2 instruction.
final class ParsedMultisigCreateV2 extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigCreateV2({required this.data})
    : super(SquadsMultisigInstruction.multisigCreateV2);

  final MultisigCreateV2InstructionData data;
}

/// A parsed MultisigAddMember instruction.
final class ParsedMultisigAddMember extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigAddMember({required this.data})
    : super(SquadsMultisigInstruction.multisigAddMember);

  final MultisigAddMemberInstructionData data;
}

/// A parsed MultisigRemoveMember instruction.
final class ParsedMultisigRemoveMember extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigRemoveMember({required this.data})
    : super(SquadsMultisigInstruction.multisigRemoveMember);

  final MultisigRemoveMemberInstructionData data;
}

/// A parsed MultisigSetTimeLock instruction.
final class ParsedMultisigSetTimeLock extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigSetTimeLock({required this.data})
    : super(SquadsMultisigInstruction.multisigSetTimeLock);

  final MultisigSetTimeLockInstructionData data;
}

/// A parsed MultisigChangeThreshold instruction.
final class ParsedMultisigChangeThreshold
    extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigChangeThreshold({required this.data})
    : super(SquadsMultisigInstruction.multisigChangeThreshold);

  final MultisigChangeThresholdInstructionData data;
}

/// A parsed MultisigSetConfigAuthority instruction.
final class ParsedMultisigSetConfigAuthority
    extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigSetConfigAuthority({required this.data})
    : super(SquadsMultisigInstruction.multisigSetConfigAuthority);

  final MultisigSetConfigAuthorityInstructionData data;
}

/// A parsed MultisigSetRentCollector instruction.
final class ParsedMultisigSetRentCollector
    extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigSetRentCollector({required this.data})
    : super(SquadsMultisigInstruction.multisigSetRentCollector);

  final MultisigSetRentCollectorInstructionData data;
}

/// A parsed MultisigAddSpendingLimit instruction.
final class ParsedMultisigAddSpendingLimit
    extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigAddSpendingLimit({required this.data})
    : super(SquadsMultisigInstruction.multisigAddSpendingLimit);

  final MultisigAddSpendingLimitInstructionData data;
}

/// A parsed MultisigRemoveSpendingLimit instruction.
final class ParsedMultisigRemoveSpendingLimit
    extends ParsedSquadsMultisigInstruction {
  const ParsedMultisigRemoveSpendingLimit({required this.data})
    : super(SquadsMultisigInstruction.multisigRemoveSpendingLimit);

  final MultisigRemoveSpendingLimitInstructionData data;
}

/// A parsed ConfigTransactionCreate instruction.
final class ParsedConfigTransactionCreate
    extends ParsedSquadsMultisigInstruction {
  const ParsedConfigTransactionCreate({required this.data})
    : super(SquadsMultisigInstruction.configTransactionCreate);

  final ConfigTransactionCreateInstructionData data;
}

/// A parsed ConfigTransactionExecute instruction.
final class ParsedConfigTransactionExecute
    extends ParsedSquadsMultisigInstruction {
  const ParsedConfigTransactionExecute({required this.data})
    : super(SquadsMultisigInstruction.configTransactionExecute);

  final ConfigTransactionExecuteInstructionData data;
}

/// A parsed VaultTransactionCreate instruction.
final class ParsedVaultTransactionCreate
    extends ParsedSquadsMultisigInstruction {
  const ParsedVaultTransactionCreate({required this.data})
    : super(SquadsMultisigInstruction.vaultTransactionCreate);

  final VaultTransactionCreateInstructionData data;
}

/// A parsed TransactionBufferCreate instruction.
final class ParsedTransactionBufferCreate
    extends ParsedSquadsMultisigInstruction {
  const ParsedTransactionBufferCreate({required this.data})
    : super(SquadsMultisigInstruction.transactionBufferCreate);

  final TransactionBufferCreateInstructionData data;
}

/// A parsed TransactionBufferClose instruction.
final class ParsedTransactionBufferClose
    extends ParsedSquadsMultisigInstruction {
  const ParsedTransactionBufferClose({required this.data})
    : super(SquadsMultisigInstruction.transactionBufferClose);

  final TransactionBufferCloseInstructionData data;
}

/// A parsed TransactionBufferExtend instruction.
final class ParsedTransactionBufferExtend
    extends ParsedSquadsMultisigInstruction {
  const ParsedTransactionBufferExtend({required this.data})
    : super(SquadsMultisigInstruction.transactionBufferExtend);

  final TransactionBufferExtendInstructionData data;
}

/// A parsed VaultTransactionCreateFromBuffer instruction.
final class ParsedVaultTransactionCreateFromBuffer
    extends ParsedSquadsMultisigInstruction {
  const ParsedVaultTransactionCreateFromBuffer({required this.data})
    : super(SquadsMultisigInstruction.vaultTransactionCreateFromBuffer);

  final VaultTransactionCreateFromBufferInstructionData data;
}

/// A parsed VaultTransactionExecute instruction.
final class ParsedVaultTransactionExecute
    extends ParsedSquadsMultisigInstruction {
  const ParsedVaultTransactionExecute({required this.data})
    : super(SquadsMultisigInstruction.vaultTransactionExecute);

  final VaultTransactionExecuteInstructionData data;
}

/// A parsed BatchCreate instruction.
final class ParsedBatchCreate extends ParsedSquadsMultisigInstruction {
  const ParsedBatchCreate({required this.data})
    : super(SquadsMultisigInstruction.batchCreate);

  final BatchCreateInstructionData data;
}

/// A parsed BatchAddTransaction instruction.
final class ParsedBatchAddTransaction extends ParsedSquadsMultisigInstruction {
  const ParsedBatchAddTransaction({required this.data})
    : super(SquadsMultisigInstruction.batchAddTransaction);

  final BatchAddTransactionInstructionData data;
}

/// A parsed BatchExecuteTransaction instruction.
final class ParsedBatchExecuteTransaction
    extends ParsedSquadsMultisigInstruction {
  const ParsedBatchExecuteTransaction({required this.data})
    : super(SquadsMultisigInstruction.batchExecuteTransaction);

  final BatchExecuteTransactionInstructionData data;
}

/// A parsed ProposalCreate instruction.
final class ParsedProposalCreate extends ParsedSquadsMultisigInstruction {
  const ParsedProposalCreate({required this.data})
    : super(SquadsMultisigInstruction.proposalCreate);

  final ProposalCreateInstructionData data;
}

/// A parsed ProposalActivate instruction.
final class ParsedProposalActivate extends ParsedSquadsMultisigInstruction {
  const ParsedProposalActivate({required this.data})
    : super(SquadsMultisigInstruction.proposalActivate);

  final ProposalActivateInstructionData data;
}

/// A parsed ProposalApprove instruction.
final class ParsedProposalApprove extends ParsedSquadsMultisigInstruction {
  const ParsedProposalApprove({required this.data})
    : super(SquadsMultisigInstruction.proposalApprove);

  final ProposalApproveInstructionData data;
}

/// A parsed ProposalReject instruction.
final class ParsedProposalReject extends ParsedSquadsMultisigInstruction {
  const ParsedProposalReject({required this.data})
    : super(SquadsMultisigInstruction.proposalReject);

  final ProposalRejectInstructionData data;
}

/// A parsed ProposalCancel instruction.
final class ParsedProposalCancel extends ParsedSquadsMultisigInstruction {
  const ParsedProposalCancel({required this.data})
    : super(SquadsMultisigInstruction.proposalCancel);

  final ProposalCancelInstructionData data;
}

/// A parsed ProposalCancelV2 instruction.
final class ParsedProposalCancelV2 extends ParsedSquadsMultisigInstruction {
  const ParsedProposalCancelV2({required this.data})
    : super(SquadsMultisigInstruction.proposalCancelV2);

  final ProposalCancelV2InstructionData data;
}

/// A parsed SpendingLimitUse instruction.
final class ParsedSpendingLimitUse extends ParsedSquadsMultisigInstruction {
  const ParsedSpendingLimitUse({required this.data})
    : super(SquadsMultisigInstruction.spendingLimitUse);

  final SpendingLimitUseInstructionData data;
}

/// A parsed ConfigTransactionAccountsClose instruction.
final class ParsedConfigTransactionAccountsClose
    extends ParsedSquadsMultisigInstruction {
  const ParsedConfigTransactionAccountsClose({required this.data})
    : super(SquadsMultisigInstruction.configTransactionAccountsClose);

  final ConfigTransactionAccountsCloseInstructionData data;
}

/// A parsed VaultTransactionAccountsClose instruction.
final class ParsedVaultTransactionAccountsClose
    extends ParsedSquadsMultisigInstruction {
  const ParsedVaultTransactionAccountsClose({required this.data})
    : super(SquadsMultisigInstruction.vaultTransactionAccountsClose);

  final VaultTransactionAccountsCloseInstructionData data;
}

/// A parsed VaultBatchTransactionAccountClose instruction.
final class ParsedVaultBatchTransactionAccountClose
    extends ParsedSquadsMultisigInstruction {
  const ParsedVaultBatchTransactionAccountClose({required this.data})
    : super(SquadsMultisigInstruction.vaultBatchTransactionAccountClose);

  final VaultBatchTransactionAccountCloseInstructionData data;
}

/// A parsed BatchAccountsClose instruction.
final class ParsedBatchAccountsClose extends ParsedSquadsMultisigInstruction {
  const ParsedBatchAccountsClose({required this.data})
    : super(SquadsMultisigInstruction.batchAccountsClose);

  final BatchAccountsCloseInstructionData data;
}

/// Parses a SquadsMultisig instruction.
ParsedSquadsMultisigInstruction parseSquadsMultisigInstruction(
  Instruction instruction,
) {
  return switch (identifySquadsMultisigInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    SquadsMultisigInstruction.programConfigInit => ParsedProgramConfigInit(
      data: parseProgramConfigInitInstruction(instruction),
    ),
    SquadsMultisigInstruction.programConfigSetAuthority =>
      ParsedProgramConfigSetAuthority(
        data: parseProgramConfigSetAuthorityInstruction(instruction),
      ),
    SquadsMultisigInstruction.programConfigSetMultisigCreationFee =>
      ParsedProgramConfigSetMultisigCreationFee(
        data: parseProgramConfigSetMultisigCreationFeeInstruction(instruction),
      ),
    SquadsMultisigInstruction.programConfigSetTreasury =>
      ParsedProgramConfigSetTreasury(
        data: parseProgramConfigSetTreasuryInstruction(instruction),
      ),
    SquadsMultisigInstruction.multisigCreate => ParsedMultisigCreate(
      data: parseMultisigCreateInstruction(instruction),
    ),
    SquadsMultisigInstruction.multisigCreateV2 => ParsedMultisigCreateV2(
      data: parseMultisigCreateV2Instruction(instruction),
    ),
    SquadsMultisigInstruction.multisigAddMember => ParsedMultisigAddMember(
      data: parseMultisigAddMemberInstruction(instruction),
    ),
    SquadsMultisigInstruction.multisigRemoveMember =>
      ParsedMultisigRemoveMember(
        data: parseMultisigRemoveMemberInstruction(instruction),
      ),
    SquadsMultisigInstruction.multisigSetTimeLock => ParsedMultisigSetTimeLock(
      data: parseMultisigSetTimeLockInstruction(instruction),
    ),
    SquadsMultisigInstruction.multisigChangeThreshold =>
      ParsedMultisigChangeThreshold(
        data: parseMultisigChangeThresholdInstruction(instruction),
      ),
    SquadsMultisigInstruction.multisigSetConfigAuthority =>
      ParsedMultisigSetConfigAuthority(
        data: parseMultisigSetConfigAuthorityInstruction(instruction),
      ),
    SquadsMultisigInstruction.multisigSetRentCollector =>
      ParsedMultisigSetRentCollector(
        data: parseMultisigSetRentCollectorInstruction(instruction),
      ),
    SquadsMultisigInstruction.multisigAddSpendingLimit =>
      ParsedMultisigAddSpendingLimit(
        data: parseMultisigAddSpendingLimitInstruction(instruction),
      ),
    SquadsMultisigInstruction.multisigRemoveSpendingLimit =>
      ParsedMultisigRemoveSpendingLimit(
        data: parseMultisigRemoveSpendingLimitInstruction(instruction),
      ),
    SquadsMultisigInstruction.configTransactionCreate =>
      ParsedConfigTransactionCreate(
        data: parseConfigTransactionCreateInstruction(instruction),
      ),
    SquadsMultisigInstruction.configTransactionExecute =>
      ParsedConfigTransactionExecute(
        data: parseConfigTransactionExecuteInstruction(instruction),
      ),
    SquadsMultisigInstruction.vaultTransactionCreate =>
      ParsedVaultTransactionCreate(
        data: parseVaultTransactionCreateInstruction(instruction),
      ),
    SquadsMultisigInstruction.transactionBufferCreate =>
      ParsedTransactionBufferCreate(
        data: parseTransactionBufferCreateInstruction(instruction),
      ),
    SquadsMultisigInstruction.transactionBufferClose =>
      ParsedTransactionBufferClose(
        data: parseTransactionBufferCloseInstruction(instruction),
      ),
    SquadsMultisigInstruction.transactionBufferExtend =>
      ParsedTransactionBufferExtend(
        data: parseTransactionBufferExtendInstruction(instruction),
      ),
    SquadsMultisigInstruction.vaultTransactionCreateFromBuffer =>
      ParsedVaultTransactionCreateFromBuffer(
        data: parseVaultTransactionCreateFromBufferInstruction(instruction),
      ),
    SquadsMultisigInstruction.vaultTransactionExecute =>
      ParsedVaultTransactionExecute(
        data: parseVaultTransactionExecuteInstruction(instruction),
      ),
    SquadsMultisigInstruction.batchCreate => ParsedBatchCreate(
      data: parseBatchCreateInstruction(instruction),
    ),
    SquadsMultisigInstruction.batchAddTransaction => ParsedBatchAddTransaction(
      data: parseBatchAddTransactionInstruction(instruction),
    ),
    SquadsMultisigInstruction.batchExecuteTransaction =>
      ParsedBatchExecuteTransaction(
        data: parseBatchExecuteTransactionInstruction(instruction),
      ),
    SquadsMultisigInstruction.proposalCreate => ParsedProposalCreate(
      data: parseProposalCreateInstruction(instruction),
    ),
    SquadsMultisigInstruction.proposalActivate => ParsedProposalActivate(
      data: parseProposalActivateInstruction(instruction),
    ),
    SquadsMultisigInstruction.proposalApprove => ParsedProposalApprove(
      data: parseProposalApproveInstruction(instruction),
    ),
    SquadsMultisigInstruction.proposalReject => ParsedProposalReject(
      data: parseProposalRejectInstruction(instruction),
    ),
    SquadsMultisigInstruction.proposalCancel => ParsedProposalCancel(
      data: parseProposalCancelInstruction(instruction),
    ),
    SquadsMultisigInstruction.proposalCancelV2 => ParsedProposalCancelV2(
      data: parseProposalCancelV2Instruction(instruction),
    ),
    SquadsMultisigInstruction.spendingLimitUse => ParsedSpendingLimitUse(
      data: parseSpendingLimitUseInstruction(instruction),
    ),
    SquadsMultisigInstruction.configTransactionAccountsClose =>
      ParsedConfigTransactionAccountsClose(
        data: parseConfigTransactionAccountsCloseInstruction(instruction),
      ),
    SquadsMultisigInstruction.vaultTransactionAccountsClose =>
      ParsedVaultTransactionAccountsClose(
        data: parseVaultTransactionAccountsCloseInstruction(instruction),
      ),
    SquadsMultisigInstruction.vaultBatchTransactionAccountClose =>
      ParsedVaultBatchTransactionAccountClose(
        data: parseVaultBatchTransactionAccountCloseInstruction(instruction),
      ),
    SquadsMultisigInstruction.batchAccountsClose => ParsedBatchAccountsClose(
      data: parseBatchAccountsCloseInstruction(instruction),
    ),
  };
}
