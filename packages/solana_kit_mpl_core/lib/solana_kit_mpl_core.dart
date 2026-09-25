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
///
/// ### Derive the asset signer PDA
///
/// External plugin execution routes through the asset signer, a PDA derived from the asset address.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
///
/// Future<void> main() async {
///   final assetSigner = await findAssetSignerPda(
///     asset: Address('Asset1111111111111111111111111111111111111'),
///   );
///
///   print(assetSigner);
/// }
/// ```
///
/// Instruction builders such as `getCreateV1Instruction`, `getCreateCollectionV1Instruction`, and `getTransferV1Instruction` give you explicit account ordering while pattern helpers like `deriveExtraAccountAddress` cover the external plugin adapter surface.
///

/// <!-- {=docsMplCoreSection -->
///
/// ### Derive the asset signer PDA
///
/// External plugin execution routes through the asset signer, a PDA derived from the asset address.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
///
/// Future<void> main() async {
///   final assetSigner = await findAssetSignerPda(
///     asset: Address('Asset1111111111111111111111111111111111111'),
///   );
///
///   print(assetSigner);
/// }
/// ```
///
/// Instruction builders such as `getCreateV1Instruction`, `getCreateCollectionV1Instruction`, and `getTransferV1Instruction` give you explicit account ordering while pattern helpers like `deriveExtraAccountAddress` cover the external plugin adapter surface.
///
/// <!-- {/docsMplCoreSection -->
library;

// ignore_for_file: comment_references

///
// Generated (Codama-style).
// Program addresses are exported directly from src/program_address.dart.
// The generated file re-exports them; hide to avoid ambiguity.
///
///
///
/// ### Derive the asset signer PDA
///
/// External plugin execution routes through the asset signer, a PDA derived from the asset address.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
///
/// Future<void> main() async {
///   final assetSigner = await findAssetSignerPda(
///     asset: Address('Asset1111111111111111111111111111111111111'),
///   );
///
///   print(assetSigner);
/// }
/// ```
///
/// Instruction builders such as `getCreateV1Instruction`, `getCreateCollectionV1Instruction`, and `getTransferV1Instruction` give you explicit account ordering while pattern helpers like `deriveExtraAccountAddress` cover the external plugin adapter surface.
///
///
export 'package:solana_kit_mpl_core/src/generated/mpl_core.dart'
    hide mplCoreProgramAddress;

///
// PDA derivation.
export 'src/pda/asset_signer.dart';
export 'src/pda/extra_account.dart';
export 'src/pda/oracle.dart';
export 'src/pda/preconfigured.dart';

// Program addresses.
export 'src/program_address.dart';
