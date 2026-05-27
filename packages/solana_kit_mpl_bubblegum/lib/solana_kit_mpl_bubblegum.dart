/// mpl-bubblegum client for the Solana Kit Dart SDK.
///
/// Provides instruction builders and helpers for interacting with the
/// [Metaplex Bubblegum](https://github.com/metaplex-foundation/mpl-bubblegum)
/// program, which manages compressed NFTs on Solana.
///
/// ## Key features
///
/// - **V1 & V2 instruction builders** for minting, transferring, burning,
///   and managing compressed NFTs
/// - **Hashing utilities** ([hashLeafV1], [hashLeafV2], [bubblegumHash])
///   using Keccak-256, matching the on-chain program's hashing logic
/// - **Merkle tree** construction and proof verification
/// - **PDA derivation** for tree authority, leaf asset ID (V2), and
///   bubblegum signer
/// - **Flag utilities** for leaf schema and asset metadata parsing
///
/// ## Dependencies
///
/// This package depends on [solana_kit_spl_account_compression] for Merkle
/// tree size calculations and program addresses, and on
/// [solana_kit_codecs_core] for the Keccak-256 hash function.
library;

// Generated (Codama) — will be populated by IDL → Dart code generation.
export 'src/generated/mpl_bubblegum.dart';

// Hand-written hashing utilities.
export 'src/hashing/hash.dart';
export 'src/hashing/hash_leaf.dart';

// Merkle tree.
export 'src/merkle/merkle_tree.dart';

// PDA derivation.
export 'src/pda/tree_authority.dart';
export 'src/pda/leaf_asset_id.dart';
export 'src/pda/bubblegum_signer.dart';

// Flags.
export 'src/flags/leaf_schema_flags.dart';

// Leaf schema.
export 'src/leaf/leaf_schema.dart';

// Program addresses.
export 'src/program_address.dart';
