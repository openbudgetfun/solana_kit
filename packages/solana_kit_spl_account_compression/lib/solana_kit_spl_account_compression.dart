// ignore_for_file: comment_references
/// SPL Account Compression Program client for the Solana Kit Dart SDK.
///
/// Provides instruction builders and helpers for interacting with the
/// [SPL Account Compression](https://github.com/solana-labs/solana-program-library/tree/master/account-compression)
/// program, which manages concurrent Merkle trees used by compressed NFTs.
///
/// This package is a low-level dependency of [solana_kit_mpl_bubblegum],
/// which provides the higher-level CNFT helpers (createTree, mintV1, etc.).
/// This package can be used independently for low-level tree operations.
library;

export 'src/generated/spl_account_compression.dart';
export 'src/merkle_tree_size.dart';
export 'src/program_address.dart';
