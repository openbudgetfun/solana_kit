/// Asset signer PDA derivation for mpl-core.
///
/// The asset signer is the Program Derived Address (PDA) through which an
/// asset "signs" for instructions executed with the `executeV1` instruction:
/// the on-chain program verifies that the `asset_signer` account was derived
/// with the seeds documented below (see `processor/execute.rs` in the
/// mpl-core program, prefix `mpl-core-execute`).
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_core/src/program_address.dart';

/// The prefix seed used to derive asset signer PDAs.
///
/// Matches the `PREFIX` constant in the mpl-core program's
/// `processor/execute.rs`.
const mplCoreExecuteSeed = 'mpl-core-execute';

/// Derives the asset signer PDA for the given asset.
///
/// Seeds (in order, using the mpl-core program address):
///
/// 1. the UTF-8 bytes of `mpl-core-execute`
/// 2. the 32-byte value of [asset]
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
///
/// void main() async {
///   final asset = Address('So11111111111111111111111111111111111111112');
///   final (assetSigner, bump) = await findAssetSignerPda(asset: asset);
///   print(assetSigner); // The PDA the asset signs with on executeV1
/// }
/// ```
Future<ProgramDerivedAddress> findAssetSignerPda({required Address asset}) {
  return getProgramDerivedAddress(
    programAddress: mplCoreProgramAddressObject,
    seeds: [mplCoreExecuteSeed, getAddressEncoder().encode(asset)],
  );
}
