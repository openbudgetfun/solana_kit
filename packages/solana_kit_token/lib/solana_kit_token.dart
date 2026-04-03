/// SPL Token and Associated Token Account client for the Solana Kit Dart SDK.
///
/// This package provides a generated low-level client for the SPL Token
/// program and the Associated Token Account program, plus handwritten
/// ergonomic helpers for common workflows like creating mints, minting
/// to ATAs, and transferring to ATAs.
///
/// ## Generated layer
///
/// The generated code under `src/generated/` is produced from the upstream
/// Codama IDL at `solana-program/token`. It includes typed account structs,
/// instruction builders, codec functions, error definitions, PDA helpers,
/// and program address constants.
///
/// ```dart
/// import 'package:solana_kit_token/solana_kit_token.dart';
///
/// // Use generated instruction builders directly
/// final ix = getTransferInstruction(
///   programAddress: tokenProgramAddress,
///   source: sourceAccount,
///   destination: destAccount,
///   owner: ownerAddress,
///   amount: BigInt.from(1000),
/// );
/// ```
///
/// ## Ergonomic helpers
///
/// Higher-level functions compose generated instructions into common
/// workflows:
///
/// - `getCreateMintInstructionPlan` — create a new token mint
/// - `getMintToAtaInstructionPlan` — mint tokens to an ATA (created if needed)
/// - `getTransferToAtaInstructionPlan` — transfer to a recipient's ATA
library;

export 'src/create_mint.dart';
export 'src/generated/associated_token.dart';
export 'src/generated/token.dart';
export 'src/mint_to_ata.dart';
export 'src/transfer_to_ata.dart';
