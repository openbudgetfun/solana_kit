/// Associated Token Account client for the Solana Kit Dart SDK.
///
/// Provides the canonical ATA program address, PDA derivation helpers, and
/// handwritten instruction builders shared by `solana_kit_token` and
/// `solana_kit_token_2022`.
library;

export 'src/errors.dart';
export 'src/instructions/create_associated_token.dart';
export 'src/instructions/create_associated_token_idempotent.dart';
export 'src/instructions/recover_nested_associated_token.dart';
export 'src/pdas.dart';
export 'src/program.dart';
