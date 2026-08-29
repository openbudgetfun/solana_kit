// ignore_for_file: comment_references
/// mpl-core client for the Solana Kit Dart SDK.
///
/// Provides instruction builders, account codecs, error helpers, and PDA
/// derivations for interacting with the
/// [Metaplex Core](https://github.com/metaplex-foundation/mpl-core)
/// program, which manages digital assets ("Core NFTs") on Solana.
///
/// ## Key features
///
/// - **Instruction builders** for creating and managing assets and
///   collections, including plugin (royalties, attributes, appendices) and
///   external plugin (Oracle) operations
/// - **Account codecs** for assets, collections, and plugin data
/// - **PDA derivation** matching the on-chain Rust program's seeds exactly,
///   including ([findAssetSignerPda], [findOracleAccount],
///   [findPreconfiguredPda], and extra-account derivations via
///   [deriveExtraAccountAddress])
/// - **Generated error helpers** ([getMplCoreErrorMessage],
///   [isMplCoreError]) plus typed error code constants
/// - **Instruction parsing** via [parseMplCoreInstruction] and
///   [identifyMplCoreInstruction]
library;

// Generated (Codama-style).
// Program addresses are exported directly from src/program_address.dart.
// The generated file re-exports them; hide to avoid ambiguity.
export 'package:solana_kit_mpl_core/src/generated/mpl_core.dart'
    hide mplCoreProgramAddress;

// PDA derivation.
export 'src/pda/asset_signer.dart';
export 'src/pda/extra_account.dart';
export 'src/pda/oracle.dart';
export 'src/pda/preconfigured.dart';

// Program addresses.
export 'src/program_address.dart';
