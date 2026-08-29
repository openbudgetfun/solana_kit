/// Program addresses for the mpl-core program.
///
/// The Metaplex Core program ID constant and its [Address] representation,
/// used as the default program for every PDA derivation in this package.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// The program address for the mpl-core (Metaplex Core) program.
///
/// This is the canonical address on mainnet, devnet, and testnet.
const mplCoreProgramAddress = 'CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d';

/// The [Address] representation of the mpl-core program address.
///
/// The generated Codama program node also exposes an [Address]-typed constant
/// with the same name, `mplCoreProgramAddress`; the package barrel hides the
/// generated one and exports this pair (a `String` and an [Address]) instead.
const mplCoreProgramAddressObject = Address(mplCoreProgramAddress);
