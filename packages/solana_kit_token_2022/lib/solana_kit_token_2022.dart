/// SPL Token 2022 client for the Solana Kit Dart SDK.
///
/// This package provides a generated low-level client for the SPL Token 2022
/// program plus a focused set of handwritten helpers for common
/// extension-aware workflows.
///
/// Associated Token Account APIs are shared from
/// `solana_kit_associated_token_account` and re-exported here for
/// convenience.
library;

export 'package:solana_kit_associated_token_account/solana_kit_associated_token_account.dart';

export 'src/generated/token_2022.dart';
export 'src/get_initialize_instructions_for_extensions.dart';
export 'src/get_mint_size.dart';
export 'src/get_token_size.dart';
