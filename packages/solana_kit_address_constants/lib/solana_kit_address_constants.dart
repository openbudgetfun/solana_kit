/// Well-known Solana address constants for programs, sysvars, SPL programs,
/// Metaplex programs, and token mints.
///
/// These constants provide convenient access to commonly-used on-chain addresses
/// without requiring a dependency on the full domain packages (e.g. the sysvar
/// or SPL program packages).
///
/// ```dart
/// import 'package:solana_kit_address_constants/solana_kit_address_constants.dart';
///
/// // Use native program addresses
/// final system = systemProgramAddress;
/// final stake = stakeProgramAddress;
///
/// // Use sysvar addresses
/// final rent = sysvarRentAddress;
/// final clock = sysvarClockAddress;
///
/// // Use SPL program addresses
/// final token = tokenProgramAddress;
/// final ata = associatedTokenProgramAddress;
/// ```
library;

export 'src/metaplex_addresses.dart';
export 'src/program_addresses.dart';
export 'src/spl_addresses.dart';
export 'src/sysvar_addresses.dart';
export 'src/well_known_addresses.dart';