/// Preconfigured PDA derivations for mpl-core external plugins.
///
/// External plugins (oracles, app data, lifecycle hooks, …) can request
/// additional accounts via `BaseExtraAccount` configurations. The preconfigured
/// variants are all derived from the same `mpl-core` prefix seed followed by a
/// context key, exactly as implemented by `ExtraAccount::derive` in the
/// mpl-core program (`plugins/external_plugin_adapters.rs`) and by
/// `findPreconfiguredPda` in the reference JavaScript client.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_core/src/program_address.dart';

/// The prefix seed used to derive every preconfigured extra-account PDA.
///
/// Matches the `MPL_CORE_PREFIX` constant in the mpl-core program's
/// `plugins/external_plugin_adapters.rs`.
const preconfiguredSeed = 'mpl-core';

/// Derives a preconfigured extra-account PDA for the given [key].
///
/// Seeds (in order):
///
/// 1. the UTF-8 bytes of `mpl-core`
/// 2. the 32-byte value of [key]
///
/// [programAddress] defaults to the mpl-core program; external plugins with
/// their own base program (e.g. an oracle's `baseAddress`) must derive the
/// account on that program instead.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
///
/// void main() async {
///   final owner = Address('9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM');
///   final (pda, bump) = await findPreconfiguredPda(key: owner);
///   print(pda); // The preconfigured `owner` extra-account PDA
/// }
/// ```
Future<ProgramDerivedAddress> findPreconfiguredPda({
  required Address key,
  Address? programAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress ?? mplCoreProgramAddressObject,
    seeds: [preconfiguredSeed, getAddressEncoder().encode(key)],
  );
}

/// Derives the preconfigured `program` extra-account PDA.
///
/// Seeds: `[mpl-core]` — used when an external plugin requests the
/// `PreconfiguredProgram` extra account on its base program.
Future<ProgramDerivedAddress> findPreconfiguredProgramPda({
  Address? programAddress,
}) {
  return getProgramDerivedAddress(
    programAddress: programAddress ?? mplCoreProgramAddressObject,
    seeds: [preconfiguredSeed],
  );
}

/// Derives the preconfigured `asset` extra-account PDA for [asset].
///
/// Seeds: `[mpl-core, asset]`.
Future<ProgramDerivedAddress> findPreconfiguredAssetPda({
  required Address asset,
  Address? programAddress,
}) {
  return findPreconfiguredPda(key: asset, programAddress: programAddress);
}

/// Derives the preconfigured `collection` extra-account PDA for [collection].
///
/// Seeds: `[mpl-core, collection]`.
Future<ProgramDerivedAddress> findPreconfiguredCollectionPda({
  required Address collection,
  Address? programAddress,
}) {
  return findPreconfiguredPda(key: collection, programAddress: programAddress);
}

/// Derives the preconfigured `owner` extra-account PDA for [owner].
///
/// Seeds: `[mpl-core, owner]`.
Future<ProgramDerivedAddress> findPreconfiguredOwnerPda({
  required Address owner,
  Address? programAddress,
}) {
  return findPreconfiguredPda(key: owner, programAddress: programAddress);
}

/// Derives the preconfigured `recipient` extra-account PDA for [recipient].
///
/// Seeds: `[mpl-core, recipient]`.
Future<ProgramDerivedAddress> findPreconfiguredRecipientPda({
  required Address recipient,
  Address? programAddress,
}) {
  return findPreconfiguredPda(key: recipient, programAddress: programAddress);
}
