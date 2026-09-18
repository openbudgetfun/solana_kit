// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the Token2022 program.

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show token2022ProgramAddress;

/// Known accounts for the Token2022 program.
enum Token2022Account {
  mint,
  token,
  multisig,
}

/// Known instructions for the Token2022 program.
enum Token2022Instruction {
  initializeMint,
  initializeAccount,
  initializeMultisig,
  transfer,
  approve,
  revoke,
  setAuthority,
  mintTo,
  burn,
  closeAccount,
  freezeAccount,
  thawAccount,
  transferChecked,
  approveChecked,
  mintToChecked,
  burnChecked,
  initializeAccount2,
  syncNative,
  initializeAccount3,
  initializeMultisig2,
  initializeMint2,
  getAccountDataSize,
  initializeImmutableOwner,
  amountToUiAmount,
  uiAmountToAmount,
  initializeMintCloseAuthority,
  initializeTransferFeeConfig,
  transferCheckedWithFee,
  withdrawWithheldTokensFromMint,
  withdrawWithheldTokensFromAccounts,
  harvestWithheldTokensToMint,
  setTransferFee,
  initializeConfidentialTransferMint,
  updateConfidentialTransferMint,
  configureConfidentialTransferAccount,
  approveConfidentialTransferAccount,
  emptyConfidentialTransferAccount,
  confidentialDeposit,
  confidentialWithdraw,
  confidentialTransfer,
  applyConfidentialPendingBalance,
  enableConfidentialCredits,
  disableConfidentialCredits,
  enableNonConfidentialCredits,
  disableNonConfidentialCredits,
  confidentialTransferWithFee,
  configureConfidentialTransferAccountWithRegistry,
  initializeDefaultAccountState,
  updateDefaultAccountState,
  reallocate,
  enableMemoTransfers,
  disableMemoTransfers,
  createNativeMint,
  initializeNonTransferableMint,
  initializeInterestBearingMint,
  updateRateInterestBearingMint,
  enableCpiGuard,
  disableCpiGuard,
  initializePermanentDelegate,
  initializeTransferHook,
  updateTransferHook,
  initializeConfidentialTransferFee,
  withdrawWithheldTokensFromMintForConfidentialTransferFee,
  withdrawWithheldTokensFromAccountsForConfidentialTransferFee,
  harvestWithheldTokensToMintForConfidentialTransferFee,
  enableHarvestToMint,
  disableHarvestToMint,
  withdrawExcessLamports,
  initializeMetadataPointer,
  updateMetadataPointer,
  initializeGroupPointer,
  updateGroupPointer,
  initializeGroupMemberPointer,
  updateGroupMemberPointer,
  initializeConfidentialMintBurn,
  rotateSupplyElgamalPubkey,
  updateConfidentialMintBurnDecryptableSupply,
  confidentialMint,
  confidentialBurn,
  applyConfidentialPendingBurn,
  initializeScaledUiAmountMint,
  updateMultiplierScaledUiMint,
  initializePausableConfig,
  pause,
  resume,
  initializeTokenMetadata,
  updateTokenMetadataField,
  removeTokenMetadataKey,
  updateTokenMetadataUpdateAuthority,
  emitTokenMetadata,
  initializeTokenGroup,
  updateTokenGroupMaxSize,
  updateTokenGroupUpdateAuthority,
  initializeTokenGroupMember,
  unwrapLamports,
  initializePermissionedBurn,
  permissionedBurn,
  permissionedBurnChecked,
  permissionedConfidentialBurn,
  batch,
}

/// Identifies the type of a Token2022 instruction.
Token2022Instruction identifyToken2022Instruction(
  Uint8List data,
) {
  if (containsBytes(data, getU8Encoder().encode(0), 0)) {
    return Token2022Instruction.initializeMint;
  }
  if (containsBytes(data, getU8Encoder().encode(1), 0)) {
    return Token2022Instruction.initializeAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(2), 0)) {
    return Token2022Instruction.initializeMultisig;
  }
  if (containsBytes(data, getU8Encoder().encode(3), 0)) {
    return Token2022Instruction.transfer;
  }
  if (containsBytes(data, getU8Encoder().encode(4), 0)) {
    return Token2022Instruction.approve;
  }
  if (containsBytes(data, getU8Encoder().encode(5), 0)) {
    return Token2022Instruction.revoke;
  }
  if (containsBytes(data, getU8Encoder().encode(6), 0)) {
    return Token2022Instruction.setAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(7), 0)) {
    return Token2022Instruction.mintTo;
  }
  if (containsBytes(data, getU8Encoder().encode(8), 0)) {
    return Token2022Instruction.burn;
  }
  if (containsBytes(data, getU8Encoder().encode(9), 0)) {
    return Token2022Instruction.closeAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(10), 0)) {
    return Token2022Instruction.freezeAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(11), 0)) {
    return Token2022Instruction.thawAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(12), 0)) {
    return Token2022Instruction.transferChecked;
  }
  if (containsBytes(data, getU8Encoder().encode(13), 0)) {
    return Token2022Instruction.approveChecked;
  }
  if (containsBytes(data, getU8Encoder().encode(14), 0)) {
    return Token2022Instruction.mintToChecked;
  }
  if (containsBytes(data, getU8Encoder().encode(15), 0)) {
    return Token2022Instruction.burnChecked;
  }
  if (containsBytes(data, getU8Encoder().encode(16), 0)) {
    return Token2022Instruction.initializeAccount2;
  }
  if (containsBytes(data, getU8Encoder().encode(17), 0)) {
    return Token2022Instruction.syncNative;
  }
  if (containsBytes(data, getU8Encoder().encode(18), 0)) {
    return Token2022Instruction.initializeAccount3;
  }
  if (containsBytes(data, getU8Encoder().encode(19), 0)) {
    return Token2022Instruction.initializeMultisig2;
  }
  if (containsBytes(data, getU8Encoder().encode(20), 0)) {
    return Token2022Instruction.initializeMint2;
  }
  if (containsBytes(data, getU8Encoder().encode(21), 0)) {
    return Token2022Instruction.getAccountDataSize;
  }
  if (containsBytes(data, getU8Encoder().encode(22), 0)) {
    return Token2022Instruction.initializeImmutableOwner;
  }
  if (containsBytes(data, getU8Encoder().encode(23), 0)) {
    return Token2022Instruction.amountToUiAmount;
  }
  if (containsBytes(data, getU8Encoder().encode(24), 0)) {
    return Token2022Instruction.uiAmountToAmount;
  }
  if (containsBytes(data, getU8Encoder().encode(25), 0)) {
    return Token2022Instruction.initializeMintCloseAuthority;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeTransferFeeConfig;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.transferCheckedWithFee;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0) &&
      containsBytes(data, getU8Encoder().encode(2), 1)) {
    return Token2022Instruction.withdrawWithheldTokensFromMint;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0) &&
      containsBytes(data, getU8Encoder().encode(3), 1)) {
    return Token2022Instruction.withdrawWithheldTokensFromAccounts;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0) &&
      containsBytes(data, getU8Encoder().encode(4), 1)) {
    return Token2022Instruction.harvestWithheldTokensToMint;
  }
  if (containsBytes(data, getU8Encoder().encode(26), 0) &&
      containsBytes(data, getU8Encoder().encode(5), 1)) {
    return Token2022Instruction.setTransferFee;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeConfidentialTransferMint;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateConfidentialTransferMint;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(2), 1)) {
    return Token2022Instruction.configureConfidentialTransferAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(3), 1)) {
    return Token2022Instruction.approveConfidentialTransferAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(4), 1)) {
    return Token2022Instruction.emptyConfidentialTransferAccount;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(5), 1)) {
    return Token2022Instruction.confidentialDeposit;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(6), 1)) {
    return Token2022Instruction.confidentialWithdraw;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(7), 1)) {
    return Token2022Instruction.confidentialTransfer;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(8), 1)) {
    return Token2022Instruction.applyConfidentialPendingBalance;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(9), 1)) {
    return Token2022Instruction.enableConfidentialCredits;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(10), 1)) {
    return Token2022Instruction.disableConfidentialCredits;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(11), 1)) {
    return Token2022Instruction.enableNonConfidentialCredits;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(12), 1)) {
    return Token2022Instruction.disableNonConfidentialCredits;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(13), 1)) {
    return Token2022Instruction.confidentialTransferWithFee;
  }
  if (containsBytes(data, getU8Encoder().encode(27), 0) &&
      containsBytes(data, getU8Encoder().encode(14), 1)) {
    return Token2022Instruction
        .configureConfidentialTransferAccountWithRegistry;
  }
  if (containsBytes(data, getU8Encoder().encode(28), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeDefaultAccountState;
  }
  if (containsBytes(data, getU8Encoder().encode(28), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateDefaultAccountState;
  }
  if (containsBytes(data, getU8Encoder().encode(29), 0)) {
    return Token2022Instruction.reallocate;
  }
  if (containsBytes(data, getU8Encoder().encode(30), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.enableMemoTransfers;
  }
  if (containsBytes(data, getU8Encoder().encode(30), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.disableMemoTransfers;
  }
  if (containsBytes(data, getU8Encoder().encode(31), 0)) {
    return Token2022Instruction.createNativeMint;
  }
  if (containsBytes(data, getU8Encoder().encode(32), 0)) {
    return Token2022Instruction.initializeNonTransferableMint;
  }
  if (containsBytes(data, getU8Encoder().encode(33), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeInterestBearingMint;
  }
  if (containsBytes(data, getU8Encoder().encode(33), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateRateInterestBearingMint;
  }
  if (containsBytes(data, getU8Encoder().encode(34), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.enableCpiGuard;
  }
  if (containsBytes(data, getU8Encoder().encode(34), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.disableCpiGuard;
  }
  if (containsBytes(data, getU8Encoder().encode(35), 0)) {
    return Token2022Instruction.initializePermanentDelegate;
  }
  if (containsBytes(data, getU8Encoder().encode(36), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeTransferHook;
  }
  if (containsBytes(data, getU8Encoder().encode(36), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateTransferHook;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeConfidentialTransferFee;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction
        .withdrawWithheldTokensFromMintForConfidentialTransferFee;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0) &&
      containsBytes(data, getU8Encoder().encode(2), 1)) {
    return Token2022Instruction
        .withdrawWithheldTokensFromAccountsForConfidentialTransferFee;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0) &&
      containsBytes(data, getU8Encoder().encode(3), 1)) {
    return Token2022Instruction
        .harvestWithheldTokensToMintForConfidentialTransferFee;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0) &&
      containsBytes(data, getU8Encoder().encode(4), 1)) {
    return Token2022Instruction.enableHarvestToMint;
  }
  if (containsBytes(data, getU8Encoder().encode(37), 0) &&
      containsBytes(data, getU8Encoder().encode(5), 1)) {
    return Token2022Instruction.disableHarvestToMint;
  }
  if (containsBytes(data, getU8Encoder().encode(38), 0)) {
    return Token2022Instruction.withdrawExcessLamports;
  }
  if (containsBytes(data, getU8Encoder().encode(39), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeMetadataPointer;
  }
  if (containsBytes(data, getU8Encoder().encode(39), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateMetadataPointer;
  }
  if (containsBytes(data, getU8Encoder().encode(40), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeGroupPointer;
  }
  if (containsBytes(data, getU8Encoder().encode(40), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateGroupPointer;
  }
  if (containsBytes(data, getU8Encoder().encode(41), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeGroupMemberPointer;
  }
  if (containsBytes(data, getU8Encoder().encode(41), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateGroupMemberPointer;
  }
  if (containsBytes(data, getU8Encoder().encode(42), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeConfidentialMintBurn;
  }
  if (containsBytes(data, getU8Encoder().encode(42), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.rotateSupplyElgamalPubkey;
  }
  if (containsBytes(data, getU8Encoder().encode(42), 0) &&
      containsBytes(data, getU8Encoder().encode(2), 1)) {
    return Token2022Instruction.updateConfidentialMintBurnDecryptableSupply;
  }
  if (containsBytes(data, getU8Encoder().encode(42), 0) &&
      containsBytes(data, getU8Encoder().encode(3), 1)) {
    return Token2022Instruction.confidentialMint;
  }
  if (containsBytes(data, getU8Encoder().encode(42), 0) &&
      containsBytes(data, getU8Encoder().encode(4), 1)) {
    return Token2022Instruction.confidentialBurn;
  }
  if (containsBytes(data, getU8Encoder().encode(42), 0) &&
      containsBytes(data, getU8Encoder().encode(5), 1)) {
    return Token2022Instruction.applyConfidentialPendingBurn;
  }
  if (containsBytes(data, getU8Encoder().encode(43), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializeScaledUiAmountMint;
  }
  if (containsBytes(data, getU8Encoder().encode(43), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.updateMultiplierScaledUiMint;
  }
  if (containsBytes(data, getU8Encoder().encode(44), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializePausableConfig;
  }
  if (containsBytes(data, getU8Encoder().encode(44), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.pause;
  }
  if (containsBytes(data, getU8Encoder().encode(44), 0) &&
      containsBytes(data, getU8Encoder().encode(2), 1)) {
    return Token2022Instruction.resume;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([210, 225, 30, 162, 88, 184, 77, 141])),
    0,
  )) {
    return Token2022Instruction.initializeTokenMetadata;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([221, 233, 49, 45, 181, 202, 220, 200])),
    0,
  )) {
    return Token2022Instruction.updateTokenMetadataField;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([234, 18, 32, 56, 89, 141, 37, 181])),
    0,
  )) {
    return Token2022Instruction.removeTokenMetadataKey;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([215, 228, 166, 228, 84, 100, 86, 123])),
    0,
  )) {
    return Token2022Instruction.updateTokenMetadataUpdateAuthority;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([250, 166, 180, 250, 13, 12, 184, 70])),
    0,
  )) {
    return Token2022Instruction.emitTokenMetadata;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([121, 113, 108, 39, 54, 51, 0, 4])),
    0,
  )) {
    return Token2022Instruction.initializeTokenGroup;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([108, 37, 171, 143, 248, 30, 18, 110])),
    0,
  )) {
    return Token2022Instruction.updateTokenGroupMaxSize;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([161, 105, 88, 1, 237, 221, 216, 203])),
    0,
  )) {
    return Token2022Instruction.updateTokenGroupUpdateAuthority;
  }
  if (containsBytes(
    data,
    fixEncoderSize(
      getBytesEncoder(),
      8,
      allowTruncation: false,
    ).encode(Uint8List.fromList([152, 32, 222, 176, 223, 237, 116, 134])),
    0,
  )) {
    return Token2022Instruction.initializeTokenGroupMember;
  }
  if (containsBytes(data, getU8Encoder().encode(45), 0)) {
    return Token2022Instruction.unwrapLamports;
  }
  if (containsBytes(data, getU8Encoder().encode(46), 0) &&
      containsBytes(data, getU8Encoder().encode(0), 1)) {
    return Token2022Instruction.initializePermissionedBurn;
  }
  if (containsBytes(data, getU8Encoder().encode(46), 0) &&
      containsBytes(data, getU8Encoder().encode(1), 1)) {
    return Token2022Instruction.permissionedBurn;
  }
  if (containsBytes(data, getU8Encoder().encode(46), 0) &&
      containsBytes(data, getU8Encoder().encode(2), 1)) {
    return Token2022Instruction.permissionedBurnChecked;
  }
  if (containsBytes(data, getU8Encoder().encode(46), 0) &&
      containsBytes(data, getU8Encoder().encode(3), 1)) {
    return Token2022Instruction.permissionedConfidentialBurn;
  }
  if (containsBytes(data, getU8Encoder().encode(255), 0)) {
    return Token2022Instruction.batch;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'token2022',
    },
  );
}

/// A parsed instruction from the Token2022 program.
sealed class ParsedToken2022Instruction {
  const ParsedToken2022Instruction(this.instructionType);

  final Token2022Instruction instructionType;
}

/// A parsed InitializeMint instruction.
final class ParsedInitializeMint extends ParsedToken2022Instruction {
  const ParsedInitializeMint({required this.data})
    : super(Token2022Instruction.initializeMint);

  final InitializeMintInstructionData data;
}

/// A parsed InitializeAccount instruction.
final class ParsedInitializeAccount extends ParsedToken2022Instruction {
  const ParsedInitializeAccount({required this.data})
    : super(Token2022Instruction.initializeAccount);

  final InitializeAccountInstructionData data;
}

/// A parsed InitializeMultisig instruction.
final class ParsedInitializeMultisig extends ParsedToken2022Instruction {
  const ParsedInitializeMultisig({required this.data})
    : super(Token2022Instruction.initializeMultisig);

  final InitializeMultisigInstructionData data;
}

/// A parsed Transfer instruction.
final class ParsedTransfer extends ParsedToken2022Instruction {
  const ParsedTransfer({required this.data})
    : super(Token2022Instruction.transfer);

  final TransferInstructionData data;
}

/// A parsed Approve instruction.
final class ParsedApprove extends ParsedToken2022Instruction {
  const ParsedApprove({required this.data})
    : super(Token2022Instruction.approve);

  final ApproveInstructionData data;
}

/// A parsed Revoke instruction.
final class ParsedRevoke extends ParsedToken2022Instruction {
  const ParsedRevoke({required this.data}) : super(Token2022Instruction.revoke);

  final RevokeInstructionData data;
}

/// A parsed SetAuthority instruction.
final class ParsedSetAuthority extends ParsedToken2022Instruction {
  const ParsedSetAuthority({required this.data})
    : super(Token2022Instruction.setAuthority);

  final SetAuthorityInstructionData data;
}

/// A parsed MintTo instruction.
final class ParsedMintTo extends ParsedToken2022Instruction {
  const ParsedMintTo({required this.data}) : super(Token2022Instruction.mintTo);

  final MintToInstructionData data;
}

/// A parsed Burn instruction.
final class ParsedBurn extends ParsedToken2022Instruction {
  const ParsedBurn({required this.data}) : super(Token2022Instruction.burn);

  final BurnInstructionData data;
}

/// A parsed CloseAccount instruction.
final class ParsedCloseAccount extends ParsedToken2022Instruction {
  const ParsedCloseAccount({required this.data})
    : super(Token2022Instruction.closeAccount);

  final CloseAccountInstructionData data;
}

/// A parsed FreezeAccount instruction.
final class ParsedFreezeAccount extends ParsedToken2022Instruction {
  const ParsedFreezeAccount({required this.data})
    : super(Token2022Instruction.freezeAccount);

  final FreezeAccountInstructionData data;
}

/// A parsed ThawAccount instruction.
final class ParsedThawAccount extends ParsedToken2022Instruction {
  const ParsedThawAccount({required this.data})
    : super(Token2022Instruction.thawAccount);

  final ThawAccountInstructionData data;
}

/// A parsed TransferChecked instruction.
final class ParsedTransferChecked extends ParsedToken2022Instruction {
  const ParsedTransferChecked({required this.data})
    : super(Token2022Instruction.transferChecked);

  final TransferCheckedInstructionData data;
}

/// A parsed ApproveChecked instruction.
final class ParsedApproveChecked extends ParsedToken2022Instruction {
  const ParsedApproveChecked({required this.data})
    : super(Token2022Instruction.approveChecked);

  final ApproveCheckedInstructionData data;
}

/// A parsed MintToChecked instruction.
final class ParsedMintToChecked extends ParsedToken2022Instruction {
  const ParsedMintToChecked({required this.data})
    : super(Token2022Instruction.mintToChecked);

  final MintToCheckedInstructionData data;
}

/// A parsed BurnChecked instruction.
final class ParsedBurnChecked extends ParsedToken2022Instruction {
  const ParsedBurnChecked({required this.data})
    : super(Token2022Instruction.burnChecked);

  final BurnCheckedInstructionData data;
}

/// A parsed InitializeAccount2 instruction.
final class ParsedInitializeAccount2 extends ParsedToken2022Instruction {
  const ParsedInitializeAccount2({required this.data})
    : super(Token2022Instruction.initializeAccount2);

  final InitializeAccount2InstructionData data;
}

/// A parsed SyncNative instruction.
final class ParsedSyncNative extends ParsedToken2022Instruction {
  const ParsedSyncNative({required this.data})
    : super(Token2022Instruction.syncNative);

  final SyncNativeInstructionData data;
}

/// A parsed InitializeAccount3 instruction.
final class ParsedInitializeAccount3 extends ParsedToken2022Instruction {
  const ParsedInitializeAccount3({required this.data})
    : super(Token2022Instruction.initializeAccount3);

  final InitializeAccount3InstructionData data;
}

/// A parsed InitializeMultisig2 instruction.
final class ParsedInitializeMultisig2 extends ParsedToken2022Instruction {
  const ParsedInitializeMultisig2({required this.data})
    : super(Token2022Instruction.initializeMultisig2);

  final InitializeMultisig2InstructionData data;
}

/// A parsed InitializeMint2 instruction.
final class ParsedInitializeMint2 extends ParsedToken2022Instruction {
  const ParsedInitializeMint2({required this.data})
    : super(Token2022Instruction.initializeMint2);

  final InitializeMint2InstructionData data;
}

/// A parsed GetAccountDataSize instruction.
final class ParsedGetAccountDataSize extends ParsedToken2022Instruction {
  const ParsedGetAccountDataSize({required this.data})
    : super(Token2022Instruction.getAccountDataSize);

  final GetAccountDataSizeInstructionData data;
}

/// A parsed InitializeImmutableOwner instruction.
final class ParsedInitializeImmutableOwner extends ParsedToken2022Instruction {
  const ParsedInitializeImmutableOwner({required this.data})
    : super(Token2022Instruction.initializeImmutableOwner);

  final InitializeImmutableOwnerInstructionData data;
}

/// A parsed AmountToUiAmount instruction.
final class ParsedAmountToUiAmount extends ParsedToken2022Instruction {
  const ParsedAmountToUiAmount({required this.data})
    : super(Token2022Instruction.amountToUiAmount);

  final AmountToUiAmountInstructionData data;
}

/// A parsed UiAmountToAmount instruction.
final class ParsedUiAmountToAmount extends ParsedToken2022Instruction {
  const ParsedUiAmountToAmount({required this.data})
    : super(Token2022Instruction.uiAmountToAmount);

  final UiAmountToAmountInstructionData data;
}

/// A parsed InitializeMintCloseAuthority instruction.
final class ParsedInitializeMintCloseAuthority
    extends ParsedToken2022Instruction {
  const ParsedInitializeMintCloseAuthority({required this.data})
    : super(Token2022Instruction.initializeMintCloseAuthority);

  final InitializeMintCloseAuthorityInstructionData data;
}

/// A parsed InitializeTransferFeeConfig instruction.
final class ParsedInitializeTransferFeeConfig
    extends ParsedToken2022Instruction {
  const ParsedInitializeTransferFeeConfig({required this.data})
    : super(Token2022Instruction.initializeTransferFeeConfig);

  final InitializeTransferFeeConfigInstructionData data;
}

/// A parsed TransferCheckedWithFee instruction.
final class ParsedTransferCheckedWithFee extends ParsedToken2022Instruction {
  const ParsedTransferCheckedWithFee({required this.data})
    : super(Token2022Instruction.transferCheckedWithFee);

  final TransferCheckedWithFeeInstructionData data;
}

/// A parsed WithdrawWithheldTokensFromMint instruction.
final class ParsedWithdrawWithheldTokensFromMint
    extends ParsedToken2022Instruction {
  const ParsedWithdrawWithheldTokensFromMint({required this.data})
    : super(Token2022Instruction.withdrawWithheldTokensFromMint);

  final WithdrawWithheldTokensFromMintInstructionData data;
}

/// A parsed WithdrawWithheldTokensFromAccounts instruction.
final class ParsedWithdrawWithheldTokensFromAccounts
    extends ParsedToken2022Instruction {
  const ParsedWithdrawWithheldTokensFromAccounts({required this.data})
    : super(Token2022Instruction.withdrawWithheldTokensFromAccounts);

  final WithdrawWithheldTokensFromAccountsInstructionData data;
}

/// A parsed HarvestWithheldTokensToMint instruction.
final class ParsedHarvestWithheldTokensToMint
    extends ParsedToken2022Instruction {
  const ParsedHarvestWithheldTokensToMint({required this.data})
    : super(Token2022Instruction.harvestWithheldTokensToMint);

  final HarvestWithheldTokensToMintInstructionData data;
}

/// A parsed SetTransferFee instruction.
final class ParsedSetTransferFee extends ParsedToken2022Instruction {
  const ParsedSetTransferFee({required this.data})
    : super(Token2022Instruction.setTransferFee);

  final SetTransferFeeInstructionData data;
}

/// A parsed InitializeConfidentialTransferMint instruction.
final class ParsedInitializeConfidentialTransferMint
    extends ParsedToken2022Instruction {
  const ParsedInitializeConfidentialTransferMint({required this.data})
    : super(Token2022Instruction.initializeConfidentialTransferMint);

  final InitializeConfidentialTransferMintInstructionData data;
}

/// A parsed UpdateConfidentialTransferMint instruction.
final class ParsedUpdateConfidentialTransferMint
    extends ParsedToken2022Instruction {
  const ParsedUpdateConfidentialTransferMint({required this.data})
    : super(Token2022Instruction.updateConfidentialTransferMint);

  final UpdateConfidentialTransferMintInstructionData data;
}

/// A parsed ConfigureConfidentialTransferAccount instruction.
final class ParsedConfigureConfidentialTransferAccount
    extends ParsedToken2022Instruction {
  const ParsedConfigureConfidentialTransferAccount({required this.data})
    : super(Token2022Instruction.configureConfidentialTransferAccount);

  final ConfigureConfidentialTransferAccountInstructionData data;
}

/// A parsed ApproveConfidentialTransferAccount instruction.
final class ParsedApproveConfidentialTransferAccount
    extends ParsedToken2022Instruction {
  const ParsedApproveConfidentialTransferAccount({required this.data})
    : super(Token2022Instruction.approveConfidentialTransferAccount);

  final ApproveConfidentialTransferAccountInstructionData data;
}

/// A parsed EmptyConfidentialTransferAccount instruction.
final class ParsedEmptyConfidentialTransferAccount
    extends ParsedToken2022Instruction {
  const ParsedEmptyConfidentialTransferAccount({required this.data})
    : super(Token2022Instruction.emptyConfidentialTransferAccount);

  final EmptyConfidentialTransferAccountInstructionData data;
}

/// A parsed ConfidentialDeposit instruction.
final class ParsedConfidentialDeposit extends ParsedToken2022Instruction {
  const ParsedConfidentialDeposit({required this.data})
    : super(Token2022Instruction.confidentialDeposit);

  final ConfidentialDepositInstructionData data;
}

/// A parsed ConfidentialWithdraw instruction.
final class ParsedConfidentialWithdraw extends ParsedToken2022Instruction {
  const ParsedConfidentialWithdraw({required this.data})
    : super(Token2022Instruction.confidentialWithdraw);

  final ConfidentialWithdrawInstructionData data;
}

/// A parsed ConfidentialTransfer instruction.
final class ParsedConfidentialTransfer extends ParsedToken2022Instruction {
  const ParsedConfidentialTransfer({required this.data})
    : super(Token2022Instruction.confidentialTransfer);

  final ConfidentialTransferInstructionData data;
}

/// A parsed ApplyConfidentialPendingBalance instruction.
final class ParsedApplyConfidentialPendingBalance
    extends ParsedToken2022Instruction {
  const ParsedApplyConfidentialPendingBalance({required this.data})
    : super(Token2022Instruction.applyConfidentialPendingBalance);

  final ApplyConfidentialPendingBalanceInstructionData data;
}

/// A parsed EnableConfidentialCredits instruction.
final class ParsedEnableConfidentialCredits extends ParsedToken2022Instruction {
  const ParsedEnableConfidentialCredits({required this.data})
    : super(Token2022Instruction.enableConfidentialCredits);

  final EnableConfidentialCreditsInstructionData data;
}

/// A parsed DisableConfidentialCredits instruction.
final class ParsedDisableConfidentialCredits
    extends ParsedToken2022Instruction {
  const ParsedDisableConfidentialCredits({required this.data})
    : super(Token2022Instruction.disableConfidentialCredits);

  final DisableConfidentialCreditsInstructionData data;
}

/// A parsed EnableNonConfidentialCredits instruction.
final class ParsedEnableNonConfidentialCredits
    extends ParsedToken2022Instruction {
  const ParsedEnableNonConfidentialCredits({required this.data})
    : super(Token2022Instruction.enableNonConfidentialCredits);

  final EnableNonConfidentialCreditsInstructionData data;
}

/// A parsed DisableNonConfidentialCredits instruction.
final class ParsedDisableNonConfidentialCredits
    extends ParsedToken2022Instruction {
  const ParsedDisableNonConfidentialCredits({required this.data})
    : super(Token2022Instruction.disableNonConfidentialCredits);

  final DisableNonConfidentialCreditsInstructionData data;
}

/// A parsed ConfidentialTransferWithFee instruction.
final class ParsedConfidentialTransferWithFee
    extends ParsedToken2022Instruction {
  const ParsedConfidentialTransferWithFee({required this.data})
    : super(Token2022Instruction.confidentialTransferWithFee);

  final ConfidentialTransferWithFeeInstructionData data;
}

/// A parsed ConfigureConfidentialTransferAccountWithRegistry instruction.
final class ParsedConfigureConfidentialTransferAccountWithRegistry
    extends ParsedToken2022Instruction {
  const ParsedConfigureConfidentialTransferAccountWithRegistry({
    required this.data,
  }) : super(
         Token2022Instruction.configureConfidentialTransferAccountWithRegistry,
       );

  final ConfigureConfidentialTransferAccountWithRegistryInstructionData data;
}

/// A parsed InitializeDefaultAccountState instruction.
final class ParsedInitializeDefaultAccountState
    extends ParsedToken2022Instruction {
  const ParsedInitializeDefaultAccountState({required this.data})
    : super(Token2022Instruction.initializeDefaultAccountState);

  final InitializeDefaultAccountStateInstructionData data;
}

/// A parsed UpdateDefaultAccountState instruction.
final class ParsedUpdateDefaultAccountState extends ParsedToken2022Instruction {
  const ParsedUpdateDefaultAccountState({required this.data})
    : super(Token2022Instruction.updateDefaultAccountState);

  final UpdateDefaultAccountStateInstructionData data;
}

/// A parsed Reallocate instruction.
final class ParsedReallocate extends ParsedToken2022Instruction {
  const ParsedReallocate({required this.data})
    : super(Token2022Instruction.reallocate);

  final ReallocateInstructionData data;
}

/// A parsed EnableMemoTransfers instruction.
final class ParsedEnableMemoTransfers extends ParsedToken2022Instruction {
  const ParsedEnableMemoTransfers({required this.data})
    : super(Token2022Instruction.enableMemoTransfers);

  final EnableMemoTransfersInstructionData data;
}

/// A parsed DisableMemoTransfers instruction.
final class ParsedDisableMemoTransfers extends ParsedToken2022Instruction {
  const ParsedDisableMemoTransfers({required this.data})
    : super(Token2022Instruction.disableMemoTransfers);

  final DisableMemoTransfersInstructionData data;
}

/// A parsed CreateNativeMint instruction.
final class ParsedCreateNativeMint extends ParsedToken2022Instruction {
  const ParsedCreateNativeMint({required this.data})
    : super(Token2022Instruction.createNativeMint);

  final CreateNativeMintInstructionData data;
}

/// A parsed InitializeNonTransferableMint instruction.
final class ParsedInitializeNonTransferableMint
    extends ParsedToken2022Instruction {
  const ParsedInitializeNonTransferableMint({required this.data})
    : super(Token2022Instruction.initializeNonTransferableMint);

  final InitializeNonTransferableMintInstructionData data;
}

/// A parsed InitializeInterestBearingMint instruction.
final class ParsedInitializeInterestBearingMint
    extends ParsedToken2022Instruction {
  const ParsedInitializeInterestBearingMint({required this.data})
    : super(Token2022Instruction.initializeInterestBearingMint);

  final InitializeInterestBearingMintInstructionData data;
}

/// A parsed UpdateRateInterestBearingMint instruction.
final class ParsedUpdateRateInterestBearingMint
    extends ParsedToken2022Instruction {
  const ParsedUpdateRateInterestBearingMint({required this.data})
    : super(Token2022Instruction.updateRateInterestBearingMint);

  final UpdateRateInterestBearingMintInstructionData data;
}

/// A parsed EnableCpiGuard instruction.
final class ParsedEnableCpiGuard extends ParsedToken2022Instruction {
  const ParsedEnableCpiGuard({required this.data})
    : super(Token2022Instruction.enableCpiGuard);

  final EnableCpiGuardInstructionData data;
}

/// A parsed DisableCpiGuard instruction.
final class ParsedDisableCpiGuard extends ParsedToken2022Instruction {
  const ParsedDisableCpiGuard({required this.data})
    : super(Token2022Instruction.disableCpiGuard);

  final DisableCpiGuardInstructionData data;
}

/// A parsed InitializePermanentDelegate instruction.
final class ParsedInitializePermanentDelegate
    extends ParsedToken2022Instruction {
  const ParsedInitializePermanentDelegate({required this.data})
    : super(Token2022Instruction.initializePermanentDelegate);

  final InitializePermanentDelegateInstructionData data;
}

/// A parsed InitializeTransferHook instruction.
final class ParsedInitializeTransferHook extends ParsedToken2022Instruction {
  const ParsedInitializeTransferHook({required this.data})
    : super(Token2022Instruction.initializeTransferHook);

  final InitializeTransferHookInstructionData data;
}

/// A parsed UpdateTransferHook instruction.
final class ParsedUpdateTransferHook extends ParsedToken2022Instruction {
  const ParsedUpdateTransferHook({required this.data})
    : super(Token2022Instruction.updateTransferHook);

  final UpdateTransferHookInstructionData data;
}

/// A parsed InitializeConfidentialTransferFee instruction.
final class ParsedInitializeConfidentialTransferFee
    extends ParsedToken2022Instruction {
  const ParsedInitializeConfidentialTransferFee({required this.data})
    : super(Token2022Instruction.initializeConfidentialTransferFee);

  final InitializeConfidentialTransferFeeInstructionData data;
}

/// A parsed WithdrawWithheldTokensFromMintForConfidentialTransferFee instruction.
final class ParsedWithdrawWithheldTokensFromMintForConfidentialTransferFee
    extends ParsedToken2022Instruction {
  const ParsedWithdrawWithheldTokensFromMintForConfidentialTransferFee({
    required this.data,
  }) : super(
         Token2022Instruction
             .withdrawWithheldTokensFromMintForConfidentialTransferFee,
       );

  final WithdrawWithheldTokensFromMintForConfidentialTransferFeeInstructionData
  data;
}

/// A parsed WithdrawWithheldTokensFromAccountsForConfidentialTransferFee instruction.
final class ParsedWithdrawWithheldTokensFromAccountsForConfidentialTransferFee
    extends ParsedToken2022Instruction {
  const ParsedWithdrawWithheldTokensFromAccountsForConfidentialTransferFee({
    required this.data,
  }) : super(
         Token2022Instruction
             .withdrawWithheldTokensFromAccountsForConfidentialTransferFee,
       );

  final WithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstructionData
  data;
}

/// A parsed HarvestWithheldTokensToMintForConfidentialTransferFee instruction.
final class ParsedHarvestWithheldTokensToMintForConfidentialTransferFee
    extends ParsedToken2022Instruction {
  const ParsedHarvestWithheldTokensToMintForConfidentialTransferFee({
    required this.data,
  }) : super(
         Token2022Instruction
             .harvestWithheldTokensToMintForConfidentialTransferFee,
       );

  final HarvestWithheldTokensToMintForConfidentialTransferFeeInstructionData
  data;
}

/// A parsed EnableHarvestToMint instruction.
final class ParsedEnableHarvestToMint extends ParsedToken2022Instruction {
  const ParsedEnableHarvestToMint({required this.data})
    : super(Token2022Instruction.enableHarvestToMint);

  final EnableHarvestToMintInstructionData data;
}

/// A parsed DisableHarvestToMint instruction.
final class ParsedDisableHarvestToMint extends ParsedToken2022Instruction {
  const ParsedDisableHarvestToMint({required this.data})
    : super(Token2022Instruction.disableHarvestToMint);

  final DisableHarvestToMintInstructionData data;
}

/// A parsed WithdrawExcessLamports instruction.
final class ParsedWithdrawExcessLamports extends ParsedToken2022Instruction {
  const ParsedWithdrawExcessLamports({required this.data})
    : super(Token2022Instruction.withdrawExcessLamports);

  final WithdrawExcessLamportsInstructionData data;
}

/// A parsed InitializeMetadataPointer instruction.
final class ParsedInitializeMetadataPointer extends ParsedToken2022Instruction {
  const ParsedInitializeMetadataPointer({required this.data})
    : super(Token2022Instruction.initializeMetadataPointer);

  final InitializeMetadataPointerInstructionData data;
}

/// A parsed UpdateMetadataPointer instruction.
final class ParsedUpdateMetadataPointer extends ParsedToken2022Instruction {
  const ParsedUpdateMetadataPointer({required this.data})
    : super(Token2022Instruction.updateMetadataPointer);

  final UpdateMetadataPointerInstructionData data;
}

/// A parsed InitializeGroupPointer instruction.
final class ParsedInitializeGroupPointer extends ParsedToken2022Instruction {
  const ParsedInitializeGroupPointer({required this.data})
    : super(Token2022Instruction.initializeGroupPointer);

  final InitializeGroupPointerInstructionData data;
}

/// A parsed UpdateGroupPointer instruction.
final class ParsedUpdateGroupPointer extends ParsedToken2022Instruction {
  const ParsedUpdateGroupPointer({required this.data})
    : super(Token2022Instruction.updateGroupPointer);

  final UpdateGroupPointerInstructionData data;
}

/// A parsed InitializeGroupMemberPointer instruction.
final class ParsedInitializeGroupMemberPointer
    extends ParsedToken2022Instruction {
  const ParsedInitializeGroupMemberPointer({required this.data})
    : super(Token2022Instruction.initializeGroupMemberPointer);

  final InitializeGroupMemberPointerInstructionData data;
}

/// A parsed UpdateGroupMemberPointer instruction.
final class ParsedUpdateGroupMemberPointer extends ParsedToken2022Instruction {
  const ParsedUpdateGroupMemberPointer({required this.data})
    : super(Token2022Instruction.updateGroupMemberPointer);

  final UpdateGroupMemberPointerInstructionData data;
}

/// A parsed InitializeConfidentialMintBurn instruction.
final class ParsedInitializeConfidentialMintBurn
    extends ParsedToken2022Instruction {
  const ParsedInitializeConfidentialMintBurn({required this.data})
    : super(Token2022Instruction.initializeConfidentialMintBurn);

  final InitializeConfidentialMintBurnInstructionData data;
}

/// A parsed RotateSupplyElgamalPubkey instruction.
final class ParsedRotateSupplyElgamalPubkey extends ParsedToken2022Instruction {
  const ParsedRotateSupplyElgamalPubkey({required this.data})
    : super(Token2022Instruction.rotateSupplyElgamalPubkey);

  final RotateSupplyElgamalPubkeyInstructionData data;
}

/// A parsed UpdateConfidentialMintBurnDecryptableSupply instruction.
final class ParsedUpdateConfidentialMintBurnDecryptableSupply
    extends ParsedToken2022Instruction {
  const ParsedUpdateConfidentialMintBurnDecryptableSupply({required this.data})
    : super(Token2022Instruction.updateConfidentialMintBurnDecryptableSupply);

  final UpdateConfidentialMintBurnDecryptableSupplyInstructionData data;
}

/// A parsed ConfidentialMint instruction.
final class ParsedConfidentialMint extends ParsedToken2022Instruction {
  const ParsedConfidentialMint({required this.data})
    : super(Token2022Instruction.confidentialMint);

  final ConfidentialMintInstructionData data;
}

/// A parsed ConfidentialBurn instruction.
final class ParsedConfidentialBurn extends ParsedToken2022Instruction {
  const ParsedConfidentialBurn({required this.data})
    : super(Token2022Instruction.confidentialBurn);

  final ConfidentialBurnInstructionData data;
}

/// A parsed ApplyConfidentialPendingBurn instruction.
final class ParsedApplyConfidentialPendingBurn
    extends ParsedToken2022Instruction {
  const ParsedApplyConfidentialPendingBurn({required this.data})
    : super(Token2022Instruction.applyConfidentialPendingBurn);

  final ApplyConfidentialPendingBurnInstructionData data;
}

/// A parsed InitializeScaledUiAmountMint instruction.
final class ParsedInitializeScaledUiAmountMint
    extends ParsedToken2022Instruction {
  const ParsedInitializeScaledUiAmountMint({required this.data})
    : super(Token2022Instruction.initializeScaledUiAmountMint);

  final InitializeScaledUiAmountMintInstructionData data;
}

/// A parsed UpdateMultiplierScaledUiMint instruction.
final class ParsedUpdateMultiplierScaledUiMint
    extends ParsedToken2022Instruction {
  const ParsedUpdateMultiplierScaledUiMint({required this.data})
    : super(Token2022Instruction.updateMultiplierScaledUiMint);

  final UpdateMultiplierScaledUiMintInstructionData data;
}

/// A parsed InitializePausableConfig instruction.
final class ParsedInitializePausableConfig extends ParsedToken2022Instruction {
  const ParsedInitializePausableConfig({required this.data})
    : super(Token2022Instruction.initializePausableConfig);

  final InitializePausableConfigInstructionData data;
}

/// A parsed Pause instruction.
final class ParsedPause extends ParsedToken2022Instruction {
  const ParsedPause({required this.data}) : super(Token2022Instruction.pause);

  final PauseInstructionData data;
}

/// A parsed Resume instruction.
final class ParsedResume extends ParsedToken2022Instruction {
  const ParsedResume({required this.data}) : super(Token2022Instruction.resume);

  final ResumeInstructionData data;
}

/// A parsed InitializeTokenMetadata instruction.
final class ParsedInitializeTokenMetadata extends ParsedToken2022Instruction {
  const ParsedInitializeTokenMetadata({required this.data})
    : super(Token2022Instruction.initializeTokenMetadata);

  final InitializeTokenMetadataInstructionData data;
}

/// A parsed UpdateTokenMetadataField instruction.
final class ParsedUpdateTokenMetadataField extends ParsedToken2022Instruction {
  const ParsedUpdateTokenMetadataField({required this.data})
    : super(Token2022Instruction.updateTokenMetadataField);

  final UpdateTokenMetadataFieldInstructionData data;
}

/// A parsed RemoveTokenMetadataKey instruction.
final class ParsedRemoveTokenMetadataKey extends ParsedToken2022Instruction {
  const ParsedRemoveTokenMetadataKey({required this.data})
    : super(Token2022Instruction.removeTokenMetadataKey);

  final RemoveTokenMetadataKeyInstructionData data;
}

/// A parsed UpdateTokenMetadataUpdateAuthority instruction.
final class ParsedUpdateTokenMetadataUpdateAuthority
    extends ParsedToken2022Instruction {
  const ParsedUpdateTokenMetadataUpdateAuthority({required this.data})
    : super(Token2022Instruction.updateTokenMetadataUpdateAuthority);

  final UpdateTokenMetadataUpdateAuthorityInstructionData data;
}

/// A parsed EmitTokenMetadata instruction.
final class ParsedEmitTokenMetadata extends ParsedToken2022Instruction {
  const ParsedEmitTokenMetadata({required this.data})
    : super(Token2022Instruction.emitTokenMetadata);

  final EmitTokenMetadataInstructionData data;
}

/// A parsed InitializeTokenGroup instruction.
final class ParsedInitializeTokenGroup extends ParsedToken2022Instruction {
  const ParsedInitializeTokenGroup({required this.data})
    : super(Token2022Instruction.initializeTokenGroup);

  final InitializeTokenGroupInstructionData data;
}

/// A parsed UpdateTokenGroupMaxSize instruction.
final class ParsedUpdateTokenGroupMaxSize extends ParsedToken2022Instruction {
  const ParsedUpdateTokenGroupMaxSize({required this.data})
    : super(Token2022Instruction.updateTokenGroupMaxSize);

  final UpdateTokenGroupMaxSizeInstructionData data;
}

/// A parsed UpdateTokenGroupUpdateAuthority instruction.
final class ParsedUpdateTokenGroupUpdateAuthority
    extends ParsedToken2022Instruction {
  const ParsedUpdateTokenGroupUpdateAuthority({required this.data})
    : super(Token2022Instruction.updateTokenGroupUpdateAuthority);

  final UpdateTokenGroupUpdateAuthorityInstructionData data;
}

/// A parsed InitializeTokenGroupMember instruction.
final class ParsedInitializeTokenGroupMember
    extends ParsedToken2022Instruction {
  const ParsedInitializeTokenGroupMember({required this.data})
    : super(Token2022Instruction.initializeTokenGroupMember);

  final InitializeTokenGroupMemberInstructionData data;
}

/// A parsed UnwrapLamports instruction.
final class ParsedUnwrapLamports extends ParsedToken2022Instruction {
  const ParsedUnwrapLamports({required this.data})
    : super(Token2022Instruction.unwrapLamports);

  final UnwrapLamportsInstructionData data;
}

/// A parsed InitializePermissionedBurn instruction.
final class ParsedInitializePermissionedBurn
    extends ParsedToken2022Instruction {
  const ParsedInitializePermissionedBurn({required this.data})
    : super(Token2022Instruction.initializePermissionedBurn);

  final InitializePermissionedBurnInstructionData data;
}

/// A parsed PermissionedBurn instruction.
final class ParsedPermissionedBurn extends ParsedToken2022Instruction {
  const ParsedPermissionedBurn({required this.data})
    : super(Token2022Instruction.permissionedBurn);

  final PermissionedBurnInstructionData data;
}

/// A parsed PermissionedBurnChecked instruction.
final class ParsedPermissionedBurnChecked extends ParsedToken2022Instruction {
  const ParsedPermissionedBurnChecked({required this.data})
    : super(Token2022Instruction.permissionedBurnChecked);

  final PermissionedBurnCheckedInstructionData data;
}

/// A parsed PermissionedConfidentialBurn instruction.
final class ParsedPermissionedConfidentialBurn
    extends ParsedToken2022Instruction {
  const ParsedPermissionedConfidentialBurn({required this.data})
    : super(Token2022Instruction.permissionedConfidentialBurn);

  final PermissionedConfidentialBurnInstructionData data;
}

/// A parsed Batch instruction.
final class ParsedBatch extends ParsedToken2022Instruction {
  const ParsedBatch({required this.data}) : super(Token2022Instruction.batch);

  final BatchInstructionData data;
}

/// Parses a Token2022 instruction.
ParsedToken2022Instruction parseToken2022Instruction(
  Instruction instruction,
) {
  return switch (identifyToken2022Instruction(
    instruction.data ?? Uint8List(0),
  )) {
    Token2022Instruction.initializeMint => ParsedInitializeMint(
      data: parseInitializeMintInstruction(instruction),
    ),
    Token2022Instruction.initializeAccount => ParsedInitializeAccount(
      data: parseInitializeAccountInstruction(instruction),
    ),
    Token2022Instruction.initializeMultisig => ParsedInitializeMultisig(
      data: parseInitializeMultisigInstruction(instruction),
    ),
    Token2022Instruction.transfer => ParsedTransfer(
      data: parseTransferInstruction(instruction),
    ),
    Token2022Instruction.approve => ParsedApprove(
      data: parseApproveInstruction(instruction),
    ),
    Token2022Instruction.revoke => ParsedRevoke(
      data: parseRevokeInstruction(instruction),
    ),
    Token2022Instruction.setAuthority => ParsedSetAuthority(
      data: parseSetAuthorityInstruction(instruction),
    ),
    Token2022Instruction.mintTo => ParsedMintTo(
      data: parseMintToInstruction(instruction),
    ),
    Token2022Instruction.burn => ParsedBurn(
      data: parseBurnInstruction(instruction),
    ),
    Token2022Instruction.closeAccount => ParsedCloseAccount(
      data: parseCloseAccountInstruction(instruction),
    ),
    Token2022Instruction.freezeAccount => ParsedFreezeAccount(
      data: parseFreezeAccountInstruction(instruction),
    ),
    Token2022Instruction.thawAccount => ParsedThawAccount(
      data: parseThawAccountInstruction(instruction),
    ),
    Token2022Instruction.transferChecked => ParsedTransferChecked(
      data: parseTransferCheckedInstruction(instruction),
    ),
    Token2022Instruction.approveChecked => ParsedApproveChecked(
      data: parseApproveCheckedInstruction(instruction),
    ),
    Token2022Instruction.mintToChecked => ParsedMintToChecked(
      data: parseMintToCheckedInstruction(instruction),
    ),
    Token2022Instruction.burnChecked => ParsedBurnChecked(
      data: parseBurnCheckedInstruction(instruction),
    ),
    Token2022Instruction.initializeAccount2 => ParsedInitializeAccount2(
      data: parseInitializeAccount2Instruction(instruction),
    ),
    Token2022Instruction.syncNative => ParsedSyncNative(
      data: parseSyncNativeInstruction(instruction),
    ),
    Token2022Instruction.initializeAccount3 => ParsedInitializeAccount3(
      data: parseInitializeAccount3Instruction(instruction),
    ),
    Token2022Instruction.initializeMultisig2 => ParsedInitializeMultisig2(
      data: parseInitializeMultisig2Instruction(instruction),
    ),
    Token2022Instruction.initializeMint2 => ParsedInitializeMint2(
      data: parseInitializeMint2Instruction(instruction),
    ),
    Token2022Instruction.getAccountDataSize => ParsedGetAccountDataSize(
      data: parseGetAccountDataSizeInstruction(instruction),
    ),
    Token2022Instruction.initializeImmutableOwner =>
      ParsedInitializeImmutableOwner(
        data: parseInitializeImmutableOwnerInstruction(instruction),
      ),
    Token2022Instruction.amountToUiAmount => ParsedAmountToUiAmount(
      data: parseAmountToUiAmountInstruction(instruction),
    ),
    Token2022Instruction.uiAmountToAmount => ParsedUiAmountToAmount(
      data: parseUiAmountToAmountInstruction(instruction),
    ),
    Token2022Instruction.initializeMintCloseAuthority =>
      ParsedInitializeMintCloseAuthority(
        data: parseInitializeMintCloseAuthorityInstruction(instruction),
      ),
    Token2022Instruction.initializeTransferFeeConfig =>
      ParsedInitializeTransferFeeConfig(
        data: parseInitializeTransferFeeConfigInstruction(instruction),
      ),
    Token2022Instruction.transferCheckedWithFee => ParsedTransferCheckedWithFee(
      data: parseTransferCheckedWithFeeInstruction(instruction),
    ),
    Token2022Instruction.withdrawWithheldTokensFromMint =>
      ParsedWithdrawWithheldTokensFromMint(
        data: parseWithdrawWithheldTokensFromMintInstruction(instruction),
      ),
    Token2022Instruction.withdrawWithheldTokensFromAccounts =>
      ParsedWithdrawWithheldTokensFromAccounts(
        data: parseWithdrawWithheldTokensFromAccountsInstruction(instruction),
      ),
    Token2022Instruction.harvestWithheldTokensToMint =>
      ParsedHarvestWithheldTokensToMint(
        data: parseHarvestWithheldTokensToMintInstruction(instruction),
      ),
    Token2022Instruction.setTransferFee => ParsedSetTransferFee(
      data: parseSetTransferFeeInstruction(instruction),
    ),
    Token2022Instruction.initializeConfidentialTransferMint =>
      ParsedInitializeConfidentialTransferMint(
        data: parseInitializeConfidentialTransferMintInstruction(instruction),
      ),
    Token2022Instruction.updateConfidentialTransferMint =>
      ParsedUpdateConfidentialTransferMint(
        data: parseUpdateConfidentialTransferMintInstruction(instruction),
      ),
    Token2022Instruction.configureConfidentialTransferAccount =>
      ParsedConfigureConfidentialTransferAccount(
        data: parseConfigureConfidentialTransferAccountInstruction(instruction),
      ),
    Token2022Instruction.approveConfidentialTransferAccount =>
      ParsedApproveConfidentialTransferAccount(
        data: parseApproveConfidentialTransferAccountInstruction(instruction),
      ),
    Token2022Instruction.emptyConfidentialTransferAccount =>
      ParsedEmptyConfidentialTransferAccount(
        data: parseEmptyConfidentialTransferAccountInstruction(instruction),
      ),
    Token2022Instruction.confidentialDeposit => ParsedConfidentialDeposit(
      data: parseConfidentialDepositInstruction(instruction),
    ),
    Token2022Instruction.confidentialWithdraw => ParsedConfidentialWithdraw(
      data: parseConfidentialWithdrawInstruction(instruction),
    ),
    Token2022Instruction.confidentialTransfer => ParsedConfidentialTransfer(
      data: parseConfidentialTransferInstruction(instruction),
    ),
    Token2022Instruction.applyConfidentialPendingBalance =>
      ParsedApplyConfidentialPendingBalance(
        data: parseApplyConfidentialPendingBalanceInstruction(instruction),
      ),
    Token2022Instruction.enableConfidentialCredits =>
      ParsedEnableConfidentialCredits(
        data: parseEnableConfidentialCreditsInstruction(instruction),
      ),
    Token2022Instruction.disableConfidentialCredits =>
      ParsedDisableConfidentialCredits(
        data: parseDisableConfidentialCreditsInstruction(instruction),
      ),
    Token2022Instruction.enableNonConfidentialCredits =>
      ParsedEnableNonConfidentialCredits(
        data: parseEnableNonConfidentialCreditsInstruction(instruction),
      ),
    Token2022Instruction.disableNonConfidentialCredits =>
      ParsedDisableNonConfidentialCredits(
        data: parseDisableNonConfidentialCreditsInstruction(instruction),
      ),
    Token2022Instruction.confidentialTransferWithFee =>
      ParsedConfidentialTransferWithFee(
        data: parseConfidentialTransferWithFeeInstruction(instruction),
      ),
    Token2022Instruction.configureConfidentialTransferAccountWithRegistry =>
      ParsedConfigureConfidentialTransferAccountWithRegistry(
        data: parseConfigureConfidentialTransferAccountWithRegistryInstruction(
          instruction,
        ),
      ),
    Token2022Instruction.initializeDefaultAccountState =>
      ParsedInitializeDefaultAccountState(
        data: parseInitializeDefaultAccountStateInstruction(instruction),
      ),
    Token2022Instruction.updateDefaultAccountState =>
      ParsedUpdateDefaultAccountState(
        data: parseUpdateDefaultAccountStateInstruction(instruction),
      ),
    Token2022Instruction.reallocate => ParsedReallocate(
      data: parseReallocateInstruction(instruction),
    ),
    Token2022Instruction.enableMemoTransfers => ParsedEnableMemoTransfers(
      data: parseEnableMemoTransfersInstruction(instruction),
    ),
    Token2022Instruction.disableMemoTransfers => ParsedDisableMemoTransfers(
      data: parseDisableMemoTransfersInstruction(instruction),
    ),
    Token2022Instruction.createNativeMint => ParsedCreateNativeMint(
      data: parseCreateNativeMintInstruction(instruction),
    ),
    Token2022Instruction.initializeNonTransferableMint =>
      ParsedInitializeNonTransferableMint(
        data: parseInitializeNonTransferableMintInstruction(instruction),
      ),
    Token2022Instruction.initializeInterestBearingMint =>
      ParsedInitializeInterestBearingMint(
        data: parseInitializeInterestBearingMintInstruction(instruction),
      ),
    Token2022Instruction.updateRateInterestBearingMint =>
      ParsedUpdateRateInterestBearingMint(
        data: parseUpdateRateInterestBearingMintInstruction(instruction),
      ),
    Token2022Instruction.enableCpiGuard => ParsedEnableCpiGuard(
      data: parseEnableCpiGuardInstruction(instruction),
    ),
    Token2022Instruction.disableCpiGuard => ParsedDisableCpiGuard(
      data: parseDisableCpiGuardInstruction(instruction),
    ),
    Token2022Instruction.initializePermanentDelegate =>
      ParsedInitializePermanentDelegate(
        data: parseInitializePermanentDelegateInstruction(instruction),
      ),
    Token2022Instruction.initializeTransferHook => ParsedInitializeTransferHook(
      data: parseInitializeTransferHookInstruction(instruction),
    ),
    Token2022Instruction.updateTransferHook => ParsedUpdateTransferHook(
      data: parseUpdateTransferHookInstruction(instruction),
    ),
    Token2022Instruction.initializeConfidentialTransferFee =>
      ParsedInitializeConfidentialTransferFee(
        data: parseInitializeConfidentialTransferFeeInstruction(instruction),
      ),
    Token2022Instruction
        .withdrawWithheldTokensFromMintForConfidentialTransferFee =>
      ParsedWithdrawWithheldTokensFromMintForConfidentialTransferFee(
        data:
            parseWithdrawWithheldTokensFromMintForConfidentialTransferFeeInstruction(
              instruction,
            ),
      ),
    Token2022Instruction
        .withdrawWithheldTokensFromAccountsForConfidentialTransferFee =>
      ParsedWithdrawWithheldTokensFromAccountsForConfidentialTransferFee(
        data:
            parseWithdrawWithheldTokensFromAccountsForConfidentialTransferFeeInstruction(
              instruction,
            ),
      ),
    Token2022Instruction
        .harvestWithheldTokensToMintForConfidentialTransferFee =>
      ParsedHarvestWithheldTokensToMintForConfidentialTransferFee(
        data:
            parseHarvestWithheldTokensToMintForConfidentialTransferFeeInstruction(
              instruction,
            ),
      ),
    Token2022Instruction.enableHarvestToMint => ParsedEnableHarvestToMint(
      data: parseEnableHarvestToMintInstruction(instruction),
    ),
    Token2022Instruction.disableHarvestToMint => ParsedDisableHarvestToMint(
      data: parseDisableHarvestToMintInstruction(instruction),
    ),
    Token2022Instruction.withdrawExcessLamports => ParsedWithdrawExcessLamports(
      data: parseWithdrawExcessLamportsInstruction(instruction),
    ),
    Token2022Instruction.initializeMetadataPointer =>
      ParsedInitializeMetadataPointer(
        data: parseInitializeMetadataPointerInstruction(instruction),
      ),
    Token2022Instruction.updateMetadataPointer => ParsedUpdateMetadataPointer(
      data: parseUpdateMetadataPointerInstruction(instruction),
    ),
    Token2022Instruction.initializeGroupPointer => ParsedInitializeGroupPointer(
      data: parseInitializeGroupPointerInstruction(instruction),
    ),
    Token2022Instruction.updateGroupPointer => ParsedUpdateGroupPointer(
      data: parseUpdateGroupPointerInstruction(instruction),
    ),
    Token2022Instruction.initializeGroupMemberPointer =>
      ParsedInitializeGroupMemberPointer(
        data: parseInitializeGroupMemberPointerInstruction(instruction),
      ),
    Token2022Instruction.updateGroupMemberPointer =>
      ParsedUpdateGroupMemberPointer(
        data: parseUpdateGroupMemberPointerInstruction(instruction),
      ),
    Token2022Instruction.initializeConfidentialMintBurn =>
      ParsedInitializeConfidentialMintBurn(
        data: parseInitializeConfidentialMintBurnInstruction(instruction),
      ),
    Token2022Instruction.rotateSupplyElgamalPubkey =>
      ParsedRotateSupplyElgamalPubkey(
        data: parseRotateSupplyElgamalPubkeyInstruction(instruction),
      ),
    Token2022Instruction.updateConfidentialMintBurnDecryptableSupply =>
      ParsedUpdateConfidentialMintBurnDecryptableSupply(
        data: parseUpdateConfidentialMintBurnDecryptableSupplyInstruction(
          instruction,
        ),
      ),
    Token2022Instruction.confidentialMint => ParsedConfidentialMint(
      data: parseConfidentialMintInstruction(instruction),
    ),
    Token2022Instruction.confidentialBurn => ParsedConfidentialBurn(
      data: parseConfidentialBurnInstruction(instruction),
    ),
    Token2022Instruction.applyConfidentialPendingBurn =>
      ParsedApplyConfidentialPendingBurn(
        data: parseApplyConfidentialPendingBurnInstruction(instruction),
      ),
    Token2022Instruction.initializeScaledUiAmountMint =>
      ParsedInitializeScaledUiAmountMint(
        data: parseInitializeScaledUiAmountMintInstruction(instruction),
      ),
    Token2022Instruction.updateMultiplierScaledUiMint =>
      ParsedUpdateMultiplierScaledUiMint(
        data: parseUpdateMultiplierScaledUiMintInstruction(instruction),
      ),
    Token2022Instruction.initializePausableConfig =>
      ParsedInitializePausableConfig(
        data: parseInitializePausableConfigInstruction(instruction),
      ),
    Token2022Instruction.pause => ParsedPause(
      data: parsePauseInstruction(instruction),
    ),
    Token2022Instruction.resume => ParsedResume(
      data: parseResumeInstruction(instruction),
    ),
    Token2022Instruction.initializeTokenMetadata =>
      ParsedInitializeTokenMetadata(
        data: parseInitializeTokenMetadataInstruction(instruction),
      ),
    Token2022Instruction.updateTokenMetadataField =>
      ParsedUpdateTokenMetadataField(
        data: parseUpdateTokenMetadataFieldInstruction(instruction),
      ),
    Token2022Instruction.removeTokenMetadataKey => ParsedRemoveTokenMetadataKey(
      data: parseRemoveTokenMetadataKeyInstruction(instruction),
    ),
    Token2022Instruction.updateTokenMetadataUpdateAuthority =>
      ParsedUpdateTokenMetadataUpdateAuthority(
        data: parseUpdateTokenMetadataUpdateAuthorityInstruction(instruction),
      ),
    Token2022Instruction.emitTokenMetadata => ParsedEmitTokenMetadata(
      data: parseEmitTokenMetadataInstruction(instruction),
    ),
    Token2022Instruction.initializeTokenGroup => ParsedInitializeTokenGroup(
      data: parseInitializeTokenGroupInstruction(instruction),
    ),
    Token2022Instruction.updateTokenGroupMaxSize =>
      ParsedUpdateTokenGroupMaxSize(
        data: parseUpdateTokenGroupMaxSizeInstruction(instruction),
      ),
    Token2022Instruction.updateTokenGroupUpdateAuthority =>
      ParsedUpdateTokenGroupUpdateAuthority(
        data: parseUpdateTokenGroupUpdateAuthorityInstruction(instruction),
      ),
    Token2022Instruction.initializeTokenGroupMember =>
      ParsedInitializeTokenGroupMember(
        data: parseInitializeTokenGroupMemberInstruction(instruction),
      ),
    Token2022Instruction.unwrapLamports => ParsedUnwrapLamports(
      data: parseUnwrapLamportsInstruction(instruction),
    ),
    Token2022Instruction.initializePermissionedBurn =>
      ParsedInitializePermissionedBurn(
        data: parseInitializePermissionedBurnInstruction(instruction),
      ),
    Token2022Instruction.permissionedBurn => ParsedPermissionedBurn(
      data: parsePermissionedBurnInstruction(instruction),
    ),
    Token2022Instruction.permissionedBurnChecked =>
      ParsedPermissionedBurnChecked(
        data: parsePermissionedBurnCheckedInstruction(instruction),
      ),
    Token2022Instruction.permissionedConfidentialBurn =>
      ParsedPermissionedConfidentialBurn(
        data: parsePermissionedConfidentialBurnInstruction(instruction),
      ),
    Token2022Instruction.batch => ParsedBatch(
      data: parseBatchInstruction(instruction),
    ),
  };
}
