import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Parsed account data for an address lookup table account.
///
/// This type represents the JSON-parsed data returned by the Solana RPC for
/// address lookup table accounts.
typedef JsonParsedAddressLookupTableAccount =
    RpcParsedInfo<JsonParsedAddressLookupTableInfo>;

/// The info payload for a parsed address lookup table account.
class JsonParsedAddressLookupTableInfo {
  /// Creates a new [JsonParsedAddressLookupTableInfo].
  const JsonParsedAddressLookupTableInfo({
    required this.addresses,
    required this.deactivationSlot,
    required this.lastExtendedSlot,
    required this.lastExtendedSlotStartIndex,
    this.authority,
  });

  /// The list of addresses stored in the lookup table.
  final List<Address> addresses;

  /// The optional authority address that can modify this lookup table.
  final Address? authority;

  /// The slot at which the lookup table was deactivated.
  final StringifiedBigInt deactivationSlot;

  /// The last slot in which the lookup table was extended.
  final StringifiedBigInt lastExtendedSlot;

  /// The start index of the last extension within the slot.
  final int lastExtendedSlotStartIndex;
}
