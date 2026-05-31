/// Solana address primitives and well-known program addresses for the Solana Kit Dart SDK.
///
/// Provides strongly typed addresses, validation helpers, base58 codecs,
/// program-derived address utilities, and constants for all native program
/// addresses, sysvar addresses, SPL program addresses, and well-known token
/// mint addresses.
///
/// <!-- {=docsAddressPrimitivesSection} -->
///
/// ## Derive and validate addresses
///
/// Use the address helpers when you need strongly typed account identifiers,
/// validation, or program-derived address derivation.
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
///
/// Future<void> main() async {
///   // Use a well-known address constant instead of hardcoding strings.
///   final pda = await getProgramDerivedAddress(
///     programAddress: systemProgramAddress,
///     seeds: ['vault', 'user-42'],
///   );
///
///   print('PDA: ${pda.$1.value}');
///   print('Bump: ${pda.$2}');
/// }
/// ```
///
/// ## Well-known addresses
///
/// This package exports constants for all Agave/Solana native program addresses,
/// sysvar addresses, SPL program addresses, Metaplex program addresses, and
/// common token mint addresses. Import them directly:
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
///
/// void main() {
///   // Native program addresses
///   print(systemProgramAddress.value); // 11111111111111111111111111111111
///
///   // SPL program addresses
///   print(tokenProgramAddress.value); // TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
///
///   // Well-known token mints
///   print(wrappedSolMintAddress.value); // So11111111111111111111111111111111111111112
/// }
/// ```
///
/// Keep raw strings at the edges. Once a value is known to be a Solana address,
/// prefer carrying it as `Address` rather than repeatedly re-validating strings.
///
/// <!-- {/docsAddressPrimitivesSection} -->
library;

export 'src/address.dart';
export 'src/address_codec.dart';
export 'src/address_comparator.dart';
export 'src/curve.dart';
export 'src/metaplex_addresses.dart';
export 'src/program_addresses.dart';
export 'src/program_derived_address.dart';
export 'src/public_key.dart';
export 'src/spl_addresses.dart';
export 'src/sysvar_addresses.dart';
export 'src/well_known_addresses.dart';
