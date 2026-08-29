// ignore_for_file: comment_references
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
library;

// Generated (Codama-style).
// Program addresses are exported directly from src/program_address.dart.
// The generated file re-exports them; hide to avoid ambiguity.
export 'package:solana_kit_mpl_token_metadata/src/generated/mpl_token_metadata.dart'
    hide mplTokenMetadataProgramAddress;

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
