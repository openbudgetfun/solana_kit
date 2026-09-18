import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Every Memo program address ever deployed, ordered from oldest (v1) to
/// newest (v4).
///
/// Consumers that need to detect memos should match against every address in
/// this list rather than a single program address, since a transaction may
/// carry memos emitted under any historical version of the program. The
/// newest address (v4) is [memoProgramAddress] and should be used to build
/// new memo instructions.
const List<Address> supportedMemoProgramAddresses = <Address>[
  memoLegacyProgramAddress,
  memoLegacyProgramAddressV3,
  memoProgramAddress,
];
