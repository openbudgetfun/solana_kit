// ignore_for_file: comment_references
/// Squads V4 multisig client for the Solana Kit Dart SDK.
///
/// Provides instruction builders, account codecs, error helpers, and PDA
/// derivations for interacting with the
/// [Squads V4](https://github.com/Squads-App/squads-mpl) multisig program,
/// which manages programmable multisig wallets on Solana.
///
/// ## Key features
///
/// - **Instruction builders** for creating and managing multisigs,
///   proposals, batch transactions, and spending limits
/// - **Account codecs** for multisig, vault, proposal, and transaction
///   accounts
/// - **PDA derivation** matching the Squads V4 Rust crates and the upstream
///   TypeScript SDK exactly, including ([findMultisigPda],
///   [findVaultPda], [findProposalPda], [findTransactionPda],
///   [findBatchTransactionPda], [findSpendingLimitPda],
///   [findEphemeralSignerPda], and [findProgramConfigPda])
/// - **Generated error helpers** ([isSquadsMultisigError]) plus typed
///   error code constants
/// - **Instruction parsing** via [parseSquadsMultisigInstruction] and
///   [identifySquadsMultisigInstruction]
library;

// Generated (Codama-style).
// Program addresses are exported directly from src/program_address.dart.
// The generated file re-exports them; hide to avoid ambiguity.
export 'package:solana_kit_squads/src/generated/squads_multisig.dart'
    hide squadsMultisigProgramAddress;

// PDA derivation.
export 'src/pda/batch_transaction.dart';
export 'src/pda/ephemeral_signer.dart';
export 'src/pda/multisig.dart';
export 'src/pda/program_config.dart';
export 'src/pda/proposal.dart';
export 'src/pda/spending_limit.dart';
export 'src/pda/transaction.dart';
export 'src/pda/vault.dart';

// Program addresses.
export 'src/program_address.dart';
