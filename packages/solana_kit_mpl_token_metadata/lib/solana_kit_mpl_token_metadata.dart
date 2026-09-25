/// mpl-token-metadata client for the Solana Kit Dart SDK.
///
/// Provides instruction builders, account codecs, error helpers, and PDA
/// derivations for interacting with the
/// [Metaplex Token Metadata](https://github.com/metaplex-foundation/mpl-token-metadata)
/// program, which manages the metadata of mint accounts on Solana.
///
/// ## Key features
///
/// - **Instruction builders** for creating and managing metadata, master
///   editions, delegates, and programmable assets
/// - **Account codecs** for metadata, master editions, edition markers,
///   delegate records, token records, and more
/// - **PDA derivation** helpers matching the on-chain Rust program's
///   seeds exactly, including ([findMetadataPda],
///   [findMasterEditionPda], [findEditionMarkerPda],
///   [findCollectionAuthorityRecordPda], [findUseAuthorityRecordPda],
///   [findTokenRecordPda], [findMetadataDelegateRecordPda],
///   [findHolderDelegateRecordPda], and [findProgramAsBurnerPda])
/// - **Generated error helpers** ([getMplTokenMetadataErrorMessage] and
///   [isMplTokenMetadataError]) plus typed error code constants
/// - **Instruction parsing** via [parseMplTokenMetadataInstruction] and
///   [identifyMplTokenMetadataInstruction]
///
/// ### Derive the metadata PDA
///
/// Token metadata lives in a PDA derived from the mint. Hero derivation helpers mirror the on-chain seed structure exactly.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// Future<void> main() async {
///   final mint = Address('So11111111111111111111111111111111111111111');
///   final (metadata, bump) = await findMetadataPda(mint: mint);
///
///   print(metadata);
///   print(bump);
/// }
/// ```
///
/// Instruction builders such as `getCreateMetadataAccountV3Instruction`, `getUpdateMetadataAccountV2Instruction`, and `getVerifyCollectionInstruction` take explicit program and account addresses, keeping fee payment, signing, and account ordering visible in your transaction messages.
///

/// <!-- {=docsMplTokenMetadataSection -->
///
/// ### Derive the metadata PDA
///
/// Token metadata lives in a PDA derived from the mint. Hero derivation helpers mirror the on-chain seed structure exactly.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// Future<void> main() async {
///   final mint = Address('So11111111111111111111111111111111111111111');
///   final (metadata, bump) = await findMetadataPda(mint: mint);
///
///   print(metadata);
///   print(bump);
/// }
/// ```
///
/// Instruction builders such as `getCreateMetadataAccountV3Instruction`, `getUpdateMetadataAccountV2Instruction`, and `getVerifyCollectionInstruction` take explicit program and account addresses, keeping fee payment, signing, and account ordering visible in your transaction messages.
///
/// <!-- {/docsMplTokenMetadataSection -->
library;

// ignore_for_file: comment_references

///
// Generated (Codama-style).
// Program addresses are exported directly from src/program_address.dart.
// The generated file re-exports them; hide to avoid ambiguity.
///
///
///
/// ### Derive the metadata PDA
///
/// Token metadata lives in a PDA derived from the mint. Hero derivation helpers mirror the on-chain seed structure exactly.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// Future<void> main() async {
///   final mint = Address('So11111111111111111111111111111111111111111');
///   final (metadata, bump) = await findMetadataPda(mint: mint);
///
///   print(metadata);
///   print(bump);
/// }
/// ```
///
/// Instruction builders such as `getCreateMetadataAccountV3Instruction`, `getUpdateMetadataAccountV2Instruction`, and `getVerifyCollectionInstruction` take explicit program and account addresses, keeping fee payment, signing, and account ordering visible in your transaction messages.
///
///
export 'package:solana_kit_mpl_token_metadata/src/generated/mpl_token_metadata.dart'
    hide mplTokenMetadataProgramAddress;

///
// PDA derivation.
export 'src/pda/collection_authority_record.dart';
export 'src/pda/edition_marker.dart';
export 'src/pda/holder_delegate_record.dart';
export 'src/pda/master_edition.dart';
export 'src/pda/metadata.dart';
export 'src/pda/metadata_delegate_record.dart';
export 'src/pda/program_as_burner.dart';
export 'src/pda/token_record.dart';
export 'src/pda/use_authority_record.dart';

// Program addresses.
export 'src/program_address.dart';
