/// Extra account address derivation for mpl-core external plugins.
///
/// Mirrors `ExtraAccount::derive` in the mpl-core program
/// (`plugins/external_plugin_adapters.rs`): the program on-chain uses this
/// derivation to validate addresses passed for external plugin adapter
/// configurations, and clients must derive the exact same addresses.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_core/src/generated/types/extra_account.dart';
import 'package:solana_kit_mpl_core/src/generated/types/seed.dart';
import 'package:solana_kit_mpl_core/src/pda/preconfigured.dart';
import 'package:solana_kit_mpl_core/src/program_address.dart';

/// Derives the address of an [ExtraAccount] exactly like the on-chain program.
///
/// The derivation depends on the variant:
///
/// - [ExtraAccountPreconfiguredProgram]: PDA with seeds `[mpl-core]` on
///   [programAddress].
/// - [ExtraAccountPreconfiguredCollection]: PDA with seeds
///   `[mpl-core, collection]` — requires [collection].
/// - [ExtraAccountPreconfiguredOwner]: PDA with seeds `[mpl-core, owner]` —
///   requires [owner].
/// - [ExtraAccountPreconfiguredRecipient]: PDA with seeds
///   `[mpl-core, recipient]` — requires [recipient].
/// - [ExtraAccountPreconfiguredAsset]: PDA with seeds `[mpl-core, asset]` —
///   requires [asset].
/// - [ExtraAccountCustomPda]: PDA with the configured [Seed] values on
///   [ExtraAccountCustomPda.customProgramId] if set, otherwise on
///   [programAddress].
/// - [ExtraAccountAddress]: the configured address, returned as-is.
///
/// [programAddress] is the program the account is derived on. It defaults to
/// the mpl-core program, but external plugin configurations that live on a
/// separate base program (e.g. an oracle's `baseAddress`) should pass that
/// program instead.
///
/// Throws an [ArgumentError] if a variant that requires a context account
/// (e.g. [ExtraAccountPreconfiguredCollection]) is given without the matching
/// input.
Future<Address> deriveExtraAccountAddress(
  ExtraAccount account, {
  Address? programAddress,
  Address? asset,
  Address? collection,
  Address? owner,
  Address? recipient,
}) async {
  switch (account) {
    case ExtraAccountAddress(:final address):
      return address;
    case ExtraAccountPreconfiguredProgram():
      final (pda, _) = await findPreconfiguredProgramPda(
        programAddress: programAddress,
      );
      return pda;
    case ExtraAccountPreconfiguredCollection():
      final (pda, _) = await findPreconfiguredPda(
        key: _require(collection, 'collection'),
        programAddress: programAddress,
      );
      return pda;
    case ExtraAccountPreconfiguredOwner():
      final (pda, _) = await findPreconfiguredPda(
        key: _require(owner, 'owner'),
        programAddress: programAddress,
      );
      return pda;
    case ExtraAccountPreconfiguredRecipient():
      final (pda, _) = await findPreconfiguredPda(
        key: _require(recipient, 'recipient'),
        programAddress: programAddress,
      );
      return pda;
    case ExtraAccountPreconfiguredAsset():
      final (pda, _) = await findPreconfiguredPda(
        key: _require(asset, 'asset'),
        programAddress: programAddress,
      );
      return pda;
    case ExtraAccountCustomPda(:final customProgramId, :final seeds):
      final (pda, _) = await getProgramDerivedAddress(
        programAddress:
            customProgramId ?? programAddress ?? mplCoreProgramAddressObject,
        seeds: _resolveSeeds(
          seeds,
          asset: asset,
          collection: collection,
          owner: owner,
          recipient: recipient,
        ),
      );
      return pda;
  }
}

/// Converts the token [seeds] of a custom PDA into raw seed bytes.
List<Uint8List> _resolveSeeds(
  List<Seed> seeds, {
  required Address? asset,
  required Address? collection,
  required Address? owner,
  required Address? recipient,
}) {
  return [
    for (final seed in seeds)
      switch (seed) {
        SeedCollection() => getAddressEncoder().encode(
          _require(collection, 'collection'),
        ),
        SeedOwner() => getAddressEncoder().encode(_require(owner, 'owner')),
        SeedRecipient() => getAddressEncoder().encode(
          _require(recipient, 'recipient'),
        ),
        SeedAsset() => getAddressEncoder().encode(_require(asset, 'asset')),
        SeedAddress(:final value) => getAddressEncoder().encode(value),
        SeedBytes(:final value) => value,
      },
  ];
}

/// Returns [value] or throws if it is missing for the requested [variant].
Address _require(Address? value, String variant) {
  if (value == null) {
    throw ArgumentError.value(
      null,
      variant,
      'deriveExtraAccountAddress requires `$variant` for this extra account',
    );
  }
  return value;
}
