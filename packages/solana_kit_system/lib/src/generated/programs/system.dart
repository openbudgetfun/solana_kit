// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the System program.

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../instructions/instructions.dart';

export 'package:solana_kit_addresses/solana_kit_addresses.dart'
    show systemProgramAddress;

/// Known accounts for the System program.
enum SystemAccount {
  nonce,
}

/// Known instructions for the System program.
enum SystemInstruction {
  createAccount,
  assign,
  transferSol,
  createAccountWithSeed,
  advanceNonceAccount,
  withdrawNonceAccount,
  initializeNonceAccount,
  authorizeNonceAccount,
  allocate,
  allocateWithSeed,
  assignWithSeed,
  transferSolWithSeed,
  upgradeNonceAccount,
  createAccountAllowPrefund,
}

/// Identifies the type of a System instruction.
SystemInstruction identifySystemInstruction(
  Uint8List data,
) {
  if (containsBytes(data, getU32Encoder().encode(0), 0)) {
    return SystemInstruction.createAccount;
  }
  if (containsBytes(data, getU32Encoder().encode(1), 0)) {
    return SystemInstruction.assign;
  }
  if (containsBytes(data, getU32Encoder().encode(2), 0)) {
    return SystemInstruction.transferSol;
  }
  if (containsBytes(data, getU32Encoder().encode(3), 0)) {
    return SystemInstruction.createAccountWithSeed;
  }
  if (containsBytes(data, getU32Encoder().encode(4), 0)) {
    return SystemInstruction.advanceNonceAccount;
  }
  if (containsBytes(data, getU32Encoder().encode(5), 0)) {
    return SystemInstruction.withdrawNonceAccount;
  }
  if (containsBytes(data, getU32Encoder().encode(6), 0)) {
    return SystemInstruction.initializeNonceAccount;
  }
  if (containsBytes(data, getU32Encoder().encode(7), 0)) {
    return SystemInstruction.authorizeNonceAccount;
  }
  if (containsBytes(data, getU32Encoder().encode(8), 0)) {
    return SystemInstruction.allocate;
  }
  if (containsBytes(data, getU32Encoder().encode(9), 0)) {
    return SystemInstruction.allocateWithSeed;
  }
  if (containsBytes(data, getU32Encoder().encode(10), 0)) {
    return SystemInstruction.assignWithSeed;
  }
  if (containsBytes(data, getU32Encoder().encode(11), 0)) {
    return SystemInstruction.transferSolWithSeed;
  }
  if (containsBytes(data, getU32Encoder().encode(12), 0)) {
    return SystemInstruction.upgradeNonceAccount;
  }
  if (containsBytes(data, getU32Encoder().encode(13), 0)) {
    return SystemInstruction.createAccountAllowPrefund;
  }

  throw SolanaError(
    SolanaErrorCode.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': 'system',
    },
  );
}

/// A parsed instruction from the System program.
sealed class ParsedSystemInstruction {
  const ParsedSystemInstruction(this.instructionType);

  final SystemInstruction instructionType;
}

/// A parsed CreateAccount instruction.
final class ParsedCreateAccount extends ParsedSystemInstruction {
  const ParsedCreateAccount({required this.data})
    : super(SystemInstruction.createAccount);

  final CreateAccountInstructionData data;
}

/// A parsed Assign instruction.
final class ParsedAssign extends ParsedSystemInstruction {
  const ParsedAssign({required this.data}) : super(SystemInstruction.assign);

  final AssignInstructionData data;
}

/// A parsed TransferSol instruction.
final class ParsedTransferSol extends ParsedSystemInstruction {
  const ParsedTransferSol({required this.data})
    : super(SystemInstruction.transferSol);

  final TransferSolInstructionData data;
}

/// A parsed CreateAccountWithSeed instruction.
final class ParsedCreateAccountWithSeed extends ParsedSystemInstruction {
  const ParsedCreateAccountWithSeed({required this.data})
    : super(SystemInstruction.createAccountWithSeed);

  final CreateAccountWithSeedInstructionData data;
}

/// A parsed AdvanceNonceAccount instruction.
final class ParsedAdvanceNonceAccount extends ParsedSystemInstruction {
  const ParsedAdvanceNonceAccount({required this.data})
    : super(SystemInstruction.advanceNonceAccount);

  final AdvanceNonceAccountInstructionData data;
}

/// A parsed WithdrawNonceAccount instruction.
final class ParsedWithdrawNonceAccount extends ParsedSystemInstruction {
  const ParsedWithdrawNonceAccount({required this.data})
    : super(SystemInstruction.withdrawNonceAccount);

  final WithdrawNonceAccountInstructionData data;
}

/// A parsed InitializeNonceAccount instruction.
final class ParsedInitializeNonceAccount extends ParsedSystemInstruction {
  const ParsedInitializeNonceAccount({required this.data})
    : super(SystemInstruction.initializeNonceAccount);

  final InitializeNonceAccountInstructionData data;
}

/// A parsed AuthorizeNonceAccount instruction.
final class ParsedAuthorizeNonceAccount extends ParsedSystemInstruction {
  const ParsedAuthorizeNonceAccount({required this.data})
    : super(SystemInstruction.authorizeNonceAccount);

  final AuthorizeNonceAccountInstructionData data;
}

/// A parsed Allocate instruction.
final class ParsedAllocate extends ParsedSystemInstruction {
  const ParsedAllocate({required this.data})
    : super(SystemInstruction.allocate);

  final AllocateInstructionData data;
}

/// A parsed AllocateWithSeed instruction.
final class ParsedAllocateWithSeed extends ParsedSystemInstruction {
  const ParsedAllocateWithSeed({required this.data})
    : super(SystemInstruction.allocateWithSeed);

  final AllocateWithSeedInstructionData data;
}

/// A parsed AssignWithSeed instruction.
final class ParsedAssignWithSeed extends ParsedSystemInstruction {
  const ParsedAssignWithSeed({required this.data})
    : super(SystemInstruction.assignWithSeed);

  final AssignWithSeedInstructionData data;
}

/// A parsed TransferSolWithSeed instruction.
final class ParsedTransferSolWithSeed extends ParsedSystemInstruction {
  const ParsedTransferSolWithSeed({required this.data})
    : super(SystemInstruction.transferSolWithSeed);

  final TransferSolWithSeedInstructionData data;
}

/// A parsed UpgradeNonceAccount instruction.
final class ParsedUpgradeNonceAccount extends ParsedSystemInstruction {
  const ParsedUpgradeNonceAccount({required this.data})
    : super(SystemInstruction.upgradeNonceAccount);

  final UpgradeNonceAccountInstructionData data;
}

/// A parsed CreateAccountAllowPrefund instruction.
final class ParsedCreateAccountAllowPrefund extends ParsedSystemInstruction {
  const ParsedCreateAccountAllowPrefund({required this.data})
    : super(SystemInstruction.createAccountAllowPrefund);

  final CreateAccountAllowPrefundInstructionData data;
}

/// Parses a System instruction.
ParsedSystemInstruction parseSystemInstruction(
  Instruction instruction,
) {
  return switch (identifySystemInstruction(
    instruction.data ?? Uint8List(0),
  )) {
    SystemInstruction.createAccount => ParsedCreateAccount(
      data: parseCreateAccountInstruction(instruction),
    ),
    SystemInstruction.assign => ParsedAssign(
      data: parseAssignInstruction(instruction),
    ),
    SystemInstruction.transferSol => ParsedTransferSol(
      data: parseTransferSolInstruction(instruction),
    ),
    SystemInstruction.createAccountWithSeed => ParsedCreateAccountWithSeed(
      data: parseCreateAccountWithSeedInstruction(instruction),
    ),
    SystemInstruction.advanceNonceAccount => ParsedAdvanceNonceAccount(
      data: parseAdvanceNonceAccountInstruction(instruction),
    ),
    SystemInstruction.withdrawNonceAccount => ParsedWithdrawNonceAccount(
      data: parseWithdrawNonceAccountInstruction(instruction),
    ),
    SystemInstruction.initializeNonceAccount => ParsedInitializeNonceAccount(
      data: parseInitializeNonceAccountInstruction(instruction),
    ),
    SystemInstruction.authorizeNonceAccount => ParsedAuthorizeNonceAccount(
      data: parseAuthorizeNonceAccountInstruction(instruction),
    ),
    SystemInstruction.allocate => ParsedAllocate(
      data: parseAllocateInstruction(instruction),
    ),
    SystemInstruction.allocateWithSeed => ParsedAllocateWithSeed(
      data: parseAllocateWithSeedInstruction(instruction),
    ),
    SystemInstruction.assignWithSeed => ParsedAssignWithSeed(
      data: parseAssignWithSeedInstruction(instruction),
    ),
    SystemInstruction.transferSolWithSeed => ParsedTransferSolWithSeed(
      data: parseTransferSolWithSeedInstruction(instruction),
    ),
    SystemInstruction.upgradeNonceAccount => ParsedUpgradeNonceAccount(
      data: parseUpgradeNonceAccountInstruction(instruction),
    ),
    SystemInstruction.createAccountAllowPrefund =>
      ParsedCreateAccountAllowPrefund(
        data: parseCreateAccountAllowPrefundInstruction(instruction),
      ),
  };
}
