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
///   const programAddress = Address('11111111111111111111111111111111');
///
///   final (pda, bump) = await getProgramDerivedAddress(
///     programAddress: programAddress,
///     seeds: ['vault', 'user-42'],
///   );
///
///   print('PDA: ${pda.value}');
///   print('Bump: $bump');
/// }
/// ```
///
/// Keep raw strings at the edges. Once a value is known to be a Solana address,
/// prefer carrying it as `Address` rather than repeatedly re-validating strings.
///
/// <!-- {/docsAddressPrimitivesSection} -->
library;

export 'package:solana_kit_address/solana_kit_address.dart';
export 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
export 'src/curve.dart';
export 'src/program_derived_address.dart';
