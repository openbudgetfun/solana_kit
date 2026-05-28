// ignore_for_file: comment_references
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
/// - **Composite helpers** ([getCreateTreeInstructionPlan],
///   [getMintV1InstructionPlan], [getBurnInstructionPlan],
///   [getTransferInstructionPlan], [getDelegateInstructionPlan])
///
/// ## Dependencies
///
/// This package depends on [solana_kit_spl_account_compression] for Merkle
/// tree size calculations and program addresses, and on
/// [solana_kit_codecs_core] for the Keccak-256 hash function.
library;

// Burn asset composite helper.
export 'src/burn_asset.dart';
// Can transfer.
export 'src/can_transfer.dart';
// Create tree composite helper.
export 'src/create_tree.dart';
// Create tree V2 composite helper.
export 'src/create_tree_v2.dart';
// DAS API abstraction.
export 'src/das_api.dart';
// Delegate asset composite helper.
export 'src/delegate_asset.dart';
// Flags.
export 'src/flags/leaf_schema_flags.dart';
// Generated (Codama-style).
export 'src/generated/mpl_bubblegum.dart';
// Hand-written hashing utilities.
export 'src/hashing/hash.dart';
export 'src/hashing/hash_leaf.dart';
// Helius DAS API client.
export 'src/helius_das_client.dart';
// Leaf schema.
export 'src/leaf/leaf_schema.dart';
// Merkle tree.
export 'src/merkle/merkle_tree.dart';
// Mint to collection composite helper.
export 'src/mint_to_collection.dart';
// Mint V1 composite helper.
export 'src/mint_v1.dart';
// Mint V2 composite helper.
export 'src/mint_v2.dart';
// PDA derivation.
export 'src/pda/bubblegum_signer.dart';
export 'src/pda/leaf_asset_id.dart';
export 'src/pda/tree_authority.dart';
// Program addresses.
export 'src/program_address.dart';
// Transfer asset composite helper.
export 'src/transfer_asset.dart';

// Byte utilities.
export 'src/utils/bytes.dart';
