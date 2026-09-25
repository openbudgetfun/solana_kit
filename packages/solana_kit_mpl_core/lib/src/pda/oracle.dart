/// Oracle account resolution for the mpl-core Oracle external plugin.
///
/// The Oracle plugin reads its validation data from an account that is either
/// given directly (`baseAddress`) or derived from it through an
/// [ExtraAccount] configuration (`baseAddressConfig`), matching
/// `plugins/external/oracle.rs` in the mpl-core program and
/// `findOracleAccount` in the reference JavaScript client.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

import 'package:solana_kit_mpl_core/src/generated/types/extra_account.dart';
import 'package:solana_kit_mpl_core/src/pda/extra_account.dart';

/// Derives the address of the account backing an Oracle external plugin.
///
/// If [baseAddressConfig] is `null`, the oracle reads directly from
/// [baseAddress] and it is returned unchanged. Otherwise the account is
/// derived on the oracle's base program using the on-chain
/// `ExtraAccount::derive` semantics:
///
/// - `PreconfiguredProgram`: PDA with seeds `[mpl-core]`.
/// - `PreconfiguredCollection` / `PreconfiguredOwner` /
///   `PreconfiguredRecipient` / `PreconfiguredAsset`: PDA with seeds
///   `[mpl-core, <context key>]` — the matching input must be provided.
/// - `CustomPda`: PDA with the configured custom seeds, on the custom program
///   if one is configured.
/// - `Address`: the configured address, returned as-is.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_addresses/solana_kit_addresses.dart';
/// import 'package:solana_kit_mpl_core/solana_kit_mpl_core.dart';
///
/// void main() async {
///   final baseAddress = Address('G5VeVfFCLYP2WwXTb4kTWhfHecDnEuVF2qGBd9Qv7aEJ');
///   final oracleAccount = await findOracleAccount(
///     baseAddress: baseAddress,
///     baseAddressConfig: const ExtraAccountPreconfiguredProgram(
///       isSigner: false,
///       isWritable: false,
///     ),
///   );
///   print(oracleAccount); // PDA of [mpl-core] on the base program
/// }
/// ```
Future<Address> findOracleAccount({
  required Address baseAddress,
  ExtraAccount? baseAddressConfig,
  Address? asset,
  Address? collection,
  Address? owner,
  Address? recipient,
}) {
  final config = baseAddressConfig;
  if (config == null) {
    return Future.value(baseAddress);
  }
  return deriveExtraAccountAddress(
    config,
    programAddress: baseAddress,
    asset: asset,
    collection: collection,
    owner: owner,
    recipient: recipient,
  );
}
