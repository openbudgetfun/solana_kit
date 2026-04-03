import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';

import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_token/src/generated/accounts/mint.dart';
import 'package:solana_kit_token/src/generated/instructions/initialize_mint2.dart';
import 'package:solana_kit_token/src/generated/programs/token.dart';

/// Input for [getCreateMintInstructionPlan].
class CreateMintInput {
  /// Creates a [CreateMintInput].
  const CreateMintInput({
    required this.payer,
    required this.newMint,
    required this.decimals,
    required this.mintAuthority,
    this.freezeAuthority,
    this.mintAccountLamports,
  });

  /// Funding account address (must be a system account).
  final Address payer;

  /// New mint account address.
  final Address newMint;

  /// Number of base 10 digits to the right of the decimal place.
  final int decimals;

  /// The authority that can mint new tokens.
  final Address mintAuthority;

  /// Optional authority that can freeze token accounts.
  final Address? freezeAuthority;

  /// Optional override for the amount of lamports to fund the mint with.
  ///
  /// Defaults to the minimum balance for rent exemption (currently 1,461,600).
  final BigInt? mintAccountLamports;
}

/// Configuration for [getCreateMintInstructionPlan].
class CreateMintConfig {
  /// Creates a [CreateMintConfig].
  const CreateMintConfig({
    this.tokenProgram,
    this.systemProgram,
  });

  /// Token program address. Defaults to [tokenProgramAddress].
  final Address? tokenProgram;

  /// System program address. Defaults to [systemProgramAddress].
  final Address? systemProgram;
}

/// Creates an instruction plan that creates and initialises a new SPL Token
/// mint.
///
/// The plan contains two sequential instructions:
/// 1. System Program `CreateAccount` — allocates the mint account.
/// 2. Token Program `InitializeMint2` — initialises the mint data.
///
/// ```dart
/// final plan = getCreateMintInstructionPlan(
///   CreateMintInput(
///     payer: payer,
///     newMint: mintKeypair,
///     decimals: 6,
///     mintAuthority: payer.address,
///   ),
/// );
/// ```
InstructionPlan getCreateMintInstructionPlan(
  CreateMintInput input, [
  CreateMintConfig config = const CreateMintConfig(),
]) {
  final tokenProgram = config.tokenProgram ?? tokenProgramAddress;
  final systemProgram = config.systemProgram ?? systemProgramAddress;

  // Rent-exempt balance: (128 + 82) * 3480 * 2 = 1_461_600
  final lamports = input.mintAccountLamports ?? BigInt.from(1461600);

  return sequentialInstructionPlan([
    getCreateAccountInstruction(
      instructionProgramAddress: systemProgram,
      payer: input.payer,
      newAccount: input.newMint,
      lamports: lamports,
      space: BigInt.from(mintSize),
      programAddress: tokenProgram,
    ),
    getInitializeMint2Instruction(
      programAddress: tokenProgram,
      mint: input.newMint,
      decimals: input.decimals,
      mintAuthority: input.mintAuthority,
      freezeAuthority: input.freezeAuthority,
    ),
  ]);
}
