/// Metadata delegate record PDA derivation for mpl-token-metadata.
///
/// The metadata delegate record PDA stores metadata-level delegations,
/// such as collection, use, data, and programmable config delegates.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_token_metadata/src/generated/types/metadata_delegate_role.dart';

import 'package:solana_kit_mpl_token_metadata/src/program_address.dart';

/// Returns the PDA seed string for a [MetadataDelegateRole].
///
/// This matches the Rust program's `Display` implementation of
/// `MetadataDelegateRole`, which is used to derive delegate record PDAs.
String _metadataDelegateRoleSeed(MetadataDelegateRole role) {
  return switch (role) {
    MetadataDelegateRole.authorityItem => 'authority_item_delegate',
    MetadataDelegateRole.collection => 'collection_delegate',
    MetadataDelegateRole.use => 'use_delegate',
    MetadataDelegateRole.data => 'data_delegate',
    MetadataDelegateRole.programmableConfig => 'programmable_config_delegate',
    MetadataDelegateRole.dataItem => 'data_item_delegate',
    MetadataDelegateRole.collectionItem => 'collection_item_delegate',
    MetadataDelegateRole.programmableConfigItem => 'prog_config_item_delegate',
  };
}

/// Derives the metadata delegate record PDA for a given mint, delegate
/// role, update authority, and delegate.
///
/// The metadata delegate record PDA is derived from the seeds
/// `['metadata', programId, mint, role, updateAuthority, delegate]` where
/// `role` is the string representation of the [MetadataDelegateRole]
/// (e.g. `'collection_delegate'`), matching the Rust program's
/// `find_metadata_delegate_record_account`.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
///
/// void main() async {
///   final mint = Address('So11111111111111111111111111111111111111112');
///   final updateAuthority = Address('Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS');
///   final delegate = Address('4Nd1mBQtrMJVYVfKf2PJy9NZUZdTAsp7D4xWLs4gDB4T');
///   final (record, bump) = await findMetadataDelegateRecordPda(
///     mint: mint,
///     delegateRole: MetadataDelegateRole.collection,
///     updateAuthority: updateAuthority,
///     delegate: delegate,
///   );
///   print(record); // The derived metadata delegate record PDA
/// }
/// ```
Future<ProgramDerivedAddress> findMetadataDelegateRecordPda({
  required Address mint,
  required MetadataDelegateRole delegateRole,
  required Address updateAuthority,
  required Address delegate,
}) {
  return getProgramDerivedAddress(
    programAddress: mplTokenMetadataProgramAddressObject,
    seeds: [
      Uint8List.fromList('metadata'.codeUnits),
      getAddressEncoder().encode(mplTokenMetadataProgramAddressObject),
      getAddressEncoder().encode(mint),
      Uint8List.fromList(
        _metadataDelegateRoleSeed(delegateRole).codeUnits,
      ),
      getAddressEncoder().encode(updateAuthority),
      getAddressEncoder().encode(delegate),
    ],
  );
}
